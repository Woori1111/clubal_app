# 좋아요 기능 설계: 멱등·동시성 안전·데이터 무결성

## 1. Firestore 컬렉션 구조

### 1.1 게시글 문서 (기존 확장)

```
community_posts / {postId}
  - title, content, userName, createdAt, ...
  - likeCount: number     // 좋아요 수 (트랜잭션 내 read-modify-write로만 갱신)
  - likedBy: string[]    // (선택) 목록/피드 조회 시 isLiked 판단용 캐시, 트랜잭션과 동기 유지
```

### 1.2 좋아요 서브컬렉션 (문서 기반, 배열 아님)

```
community_posts / {postId} / likes / {userId}
  - createdAt: Timestamp   // 서버 타임스탬프 (감사/디버깅용)
```

- **문서 존재** = 해당 사용자가 좋아요한 상태  
- **문서 없음** = 좋아요 안 함  
- 문서 ID를 `userId`로 두어, 한 사용자당 최대 1개 문서만 존재 (자연스럽게 멱등)

---

## 2. likeCount를 increment() 없이 안전하게 처리

- **사용하지 않는 것**: `FieldValue.increment(1)` / `increment(-1)`  
  - 연타/봇 시 같은 문서에 increment만 반복되면 likeCount가 비정상 증가할 수 있음.

- **사용하는 방식**: 트랜잭션 안에서  
  1. `likes/{userId}` 문서 존재 여부로 “지금 좋아요할지/해제할지” 결정  
  2. **post 문서의 likeCount를 한 번 읽고**,  
  3. 그 결과에 따라 **한 번만** `likeCount + 1` 또는 `likeCount - 1`을 **직접 설정**

즉, “증가/감소 연산”이 아니라 **“현재 값 읽기 → 새 값 계산 → 한 번 쓰기”**로 처리해,  
연타/동시 요청이 와도 트랜잭션 재시도와 “존재 기반 토글”로 **최종적으로 likeCount가 한 번만 반영**되게 한다.

---

## 3. 트랜잭션 기반 멱등 토글

### 3.1 좋아요 (Like)

1. 트랜잭션 시작  
2. `likes/{userId}` 문서 **get**  
3. **이미 존재** → 아무 쓰기 하지 않고 커밋 (멱등: 여러 번 호출해도 결과 동일)  
4. **존재하지 않음** →  
   - `community_posts/{postId}` **get** → 현재 `likeCount` 읽기  
   - `likes/{userId}` **set** (생성)  
   - `community_posts/{postId}` **update**:  
     - `likeCount = (방금 읽은 값) + 1`  
     - (선택) `likedBy = arrayUnion(userId)`  
5. 커밋

### 3.2 좋아요 해제 (Unlike)

1. 트랜잭션 시작  
2. `likes/{userId}` 문서 **get**  
3. **존재하지 않음** → 아무 쓰기 하지 않고 커밋 (멱등)  
4. **존재함** →  
   - `community_posts/{postId}` **get** → 현재 `likeCount` 읽기  
   - `likes/{userId}` **delete**  
   - `community_posts/{postId}` **update**:  
     - `likeCount = (방금 읽은 값) - 1`  
     - (선택) `likedBy = arrayRemove(userId)`  
5. 커밋

---

## 4. 연타/동시성에서 왜 안전한지

| 상황 | 동작 | 결과 |
|------|------|------|
| 같은 사용자가 0.1초에 100번 like 요청 | 트랜잭션 100번 실행. 첫 번째만 “likes/{userId} 없음”으로 보고 생성 + likeCount+1. 나머지는 “이미 존재”로 쓰기 없이 커밋. | like 1번만 반영, likeCount 1만 증가. |
| 같은 사용자가 동시에 like / unlike 여러 번 | 각 트랜잭션이 “likes/{userId} 존재 여부”만 보고 진행. 최종 상태는 “마지막 성공한 트랜잭션” 하나와 일치. | 일관된 최종 상태만 남음. |
| 봇이 같은 userId로 초당 수백 번 like | 매 요청이 “likes/{userId} 이미 있음”을 보고 쓰기 생략. | likeCount 추가 증가 없음. |
| 서로 다른 사용자 A, B가 동시에 like | A 트랜잭션: likes/A 생성 + likeCount+1. B 트랜잭션: likes/B 생성 + likeCount+1. 서로 다른 문서를 쓰므로 충돌 없이 커밋 가능 (재시도 시 일부만 “이미 존재”로 스킵). | likeCount는 정확히 2 증가. |

- Firestore 트랜잭션은 **직렬화**되어, 같은 문서를 읽고 쓰는 연산이 겹치면 일부는 재시도된다.  
- “likes/{userId}가 없을 때만 생성 + likeCount 갱신”으로 설계했기 때문에,  
  **같은 like/unlike 의도를 여러 번 보내도 “실제 상태 변경”은 한 번만 적용**되고, likeCount는 항상 “likes 서브컬렉션 문서 수”와 일치하도록 유지된다.

---

## 5. 비용(Write/Read) 영향

- **Like 1번 (실제로 반영되는 경우)**  
  - 트랜잭션 내: `likes/{userId}` get 1회, post get 1회 → **2 read**  
  - 쓰기: like 문서 1개 set, post 문서 1개 update → **2 write**

- **Like 1번 (이미 좋아요한 상태, 멱등으로 스킵)**  
  - 트랜잭션: `likes/{userId}` get 1회 → **1 read**, write 0

- **Unlike 1번 (실제로 반영되는 경우)**  
  - read 2 (like doc + post), write 2 (delete + post update)

- **연타/봇**  
  - 첫 요청만 2 read + 2 write, 나머지는 1 read + 0 write로 스킵되므로,  
    **비정상적인 likeCount 증가나 write 폭증이 발생하지 않음.**

- **기존 arrayUnion/arrayRemove + increment 방식과 비교**  
  - 기존: 연타 시 요청마다 update 1회 → write 수 = 요청 수.  
  - 현재: 연타 시 실제 반영은 1번만 → write 수 = 1 (멱등으로 비용 상한이 보장됨).

---

## 6. Auth / Rules / App Check 의존성

- **데이터 모델만으로** “한 사용자당 like 문서 1개”와 “존재 여부 기반 토글”을 보장한다.  
- Auth/Rules/App Check는 **누가 요청하는지, 어떤 조건에서 허용할지**를 정하는 계층이고,  
  이 설계는 **“같은 요청이 여러 번 와도 likeCount와 likes 문서가 일관되게 유지된다”**는 **데이터 무결성**을 트랜잭션과 문서 구조로 해결한다.  
- 실제 서비스에서는 Auth(누가 userId인지) + Rules(해당 userId만 likes/{userId} 접근 등)와 함께 쓰는 것을 권장한다.

---

## 7. 레거시 데이터 (likedBy만 있고 likes 서브컬렉션 없는 경우)

- `LikeService._unlike`에서 `likes/{userId}`가 없어도 **post 문서의 likedBy에 userId가 있으면** 한 번만 `arrayRemove` + `likeCount` 감소로 정리한다.
- 따라서 예전에 배열만 쓰던 게시글도, 사용자가 좋아요 해제를 한 번 하면 서버 상태가 정리되고, 이후부터는 likes 문서 기반과 일치하게 동작한다.
