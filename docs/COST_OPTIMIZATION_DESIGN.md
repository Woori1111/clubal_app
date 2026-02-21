# Flutter × Firestore 커뮤니티 앱 비용 최적화 설계

## 1. 현재 문제 요약

| 문제 | 현재 상태 | 영향 |
|------|-----------|------|
| 목록/상세 실시간 스트림 | `snapshots()` 전 구간 구독 | read 비용 폭발 |
| 좋아요/댓글 중복 write | 클라이언트 연타 시 재호출 | write 비용 증가 |
| likedBy 배열 | post 문서에 배열 저장 | 문서 크기·비용 증가 |
| get() 반복 | isLiked, likeCount 개별 조회 | read 비용 증가 |
| 캐시 없음 | 매번 서버 read | read 비용 과다 |
| 트랜잭션 충돌 | 동시 요청 시 재시도 | write·CPU 증가 |

---

## 2. 전체 최적화 아키텍처

```
┌─────────────────────────────────────────────────────────────────┐
│                         UI Layer                                  │
│  CommunityTabView / PostDetailPage / CommentsCard                 │
└─────────────────────────┬───────────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────────┐
│                    Data Layer (추가)                              │
│  CommunityPostRepository  │  CommentRepository  │  LikeRepository  │
│  - 캐시 (메모리/TTL)       │  - 페이지네이션     │  - Optimistic UI  │
│  - 페이지네이션             │  - 캐시             │  - 멱등·디바운스  │
└─────────────────────────┬───────────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────────┐
│                    Firestore (직접 호출 최소화)                    │
│  get() 대신 → getDocFromCache() / getDocFromServer() 선택         │
│  snapshots() → limit + startAfterDocument + 캐시 병합             │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. 캐시 설계

### 3.1 게시글 목록 캐시 (`CommunityPostCache`)

```dart
/// 게시글 목록 캐시 (메모리, TTL)
class CommunityPostCache {
  static const _ttl = Duration(minutes: 5);
  List<PostSnapshot>? _posts;
  DateTime? _fetchedAt;
  
  bool get isValid => _fetchedAt != null && 
      DateTime.now().difference(_fetchedAt!) < _ttl;
  
  List<PostSnapshot>? get posts => isValid ? _posts : null;
  void set(List<PostSnapshot> posts) {
    _posts = posts;
    _fetchedAt = DateTime.now();
  }
  void invalidate() => _posts = null;
}
```

**전략**

- 초기 로드: `get()` 1회 (또는 페이지네이션 첫 페이지)
- 새로고침 시: `invalidate()` 후 `get()` 재호출
- 실시간 구독 사용 시: `limit(20)` + `snapshots()` 1스트림만, 캐시와 병합 표시

### 3.2 likeCount / isLiked 캐시 (`LikeStateCache`)

```dart
/// postId → (likeCount, isLiked) 캐시
class LikeStateCache {
  static const _ttl = Duration(minutes: 2);
  final Map<String, _CachedLikeState> _cache = {};
  
  LikeState? get(String postId) {
    final c = _cache[postId];
    if (c == null || DateTime.now().difference(c.at) > _ttl) return null;
    return LikeState(likeCount: c.count, isLiked: c.isLiked);
  }
  
  void set(String postId, int count, bool isLiked) {
    _cache[postId] = _CachedLikeState(count, isLiked, DateTime.now());
  }
  
  /// Optimistic UI: 서버 확정 전 임시 반영
  void setOptimistic(String postId, int delta, bool isLiked) { ... }
}
```

- 목록: Firestore post 문서의 `likeCount`, `likedBy.contains(userId)`만 사용 (추가 read 없음)
- 상세: `LikeStateCache.get(postId)` → 있으면 사용, 없으면 `getLikeState` 1회 후 캐시 저장
- 좋아요 후: `setOptimistic` 갱신 → 서버 응답 후 `set`으로 덮어쓰기

### 3.3 댓글 캐시

- 상세 진입 시: `getDocs()` 1회 (limit 적용)
- 스크롤 시: `startAfterDocument`로 다음 페이지 로드
- 실시간 구독: `limit(10).snapshots()` 1스트림 (필요 시에만)

---

## 4. 새로고침 구조

### 4.1 목록 화면 (Pull-to-Refresh)

```dart
RefreshIndicator(
  onRefresh: () async {
    _postCache.invalidate();
    await _repository.refreshPosts();
    setState(() {});
  },
  child: ListView(...),
)
```

- `refreshPosts()`: `get()` 1회 또는 `limit(N).get()`
- 실시간 스트림 사용 시: `invalidate` 후 스트림이 자동으로 최신 데이터 전달

### 4.2 상세 화면

- 뒤로가기 후 목록 복귀: 캐시 유지 (추가 read 없음)
- 상세 내 새로고침: `RefreshIndicator`로 해당 글 + 댓글 1회 재조회

### 4.3 스트림 vs get 전략

| 화면 | 권장 | 비고 |
|------|------|------|
| 목록 | `get()` + 새로고침 | 실시간성 낮으면 get만 사용 |
| 상세 | `get()` 1회 | 실시간 필요 시에만 snapshots |
| 댓글 | `get()` + 페이지네이션 | 스크롤 시 추가 로드 |

---

## 5. Optimistic UI + 롤백

### 5.1 좋아요

```dart
Future<void> toggleLike(String postId, String userId) async {
  final cached = _likeCache.get(postId);
  final currentLiked = cached?.isLiked ?? _initialIsLiked;
  final wantLiked = !currentLiked;
  final delta = wantLiked ? 1 : -1;
  
  // 1. Optimistic: 즉시 UI 반영
  _likeCache.setOptimistic(postId, 
    (cached?.likeCount ?? _initialCount) + delta, 
    wantLiked);
  setState(() {});
  
  // 2. 디바운스(300ms) 후 서버 호출 (멱등)
  final success = await LikeService().setLiked(
    postId: postId, userId: userId, wantLiked: wantLiked);
  
  if (success != null && !success && mounted) {
    // 3. 실패 시 롤백
    _likeCache.setOptimistic(postId, -delta, currentLiked);
    setState(() {});
    showMessageDialog(context, message: '네트워크 오류', isError: true);
  } else if (mounted) {
    // 4. 성공: 캐시를 서버 값으로 고정
    _likeCache.set(postId, ...);
  }
}
```

### 5.2 댓글 작성

```dart
// 1. Optimistic: 로컬 리스트에 임시 댓글 추가
final tempComment = Comment(userName: '나', content: text, isPending: true);
setState(() => _comments.insert(0, tempComment));

// 2. 서버 add + commentCount update
try {
  await _addComment(text);
  // 성공: tempComment 제거, 서버 데이터로 교체
} catch (e) {
  // 롤백: tempComment 제거
  setState(() => _comments.removeWhere((c) => c.isPending));
  showError(...);
}
```

---

## 6. Write 최적화 (멱등·중복 방지)

### 6.1 좋아요 (현재 LikeService 유지)

- `likes/{userId}` 문서 존재 여부로 토글 → 이미 멱등
- 클라이언트: **디바운스 300ms** 적용으로 연타 시 마지막 상태만 반영

```dart
Timer? _likeDebounce;
void _onLikeTap() {
  _likeDebounce?.cancel();
  _likeDebounce = Timer(Duration(milliseconds: 300), () => _doToggleLike());
}
```

### 6.2 댓글

- `add()`는 멱등이 아님 → 중복 방지는 UI에서만
  - 제출 버튼 비활성화 (`_isSubmitting`)
  - 제출 중 연타 무시
- `commentCount`는 `FieldValue.increment(1)` 사용 (댓글 1개당 1회만 호출되므로 문제 적음)

### 6.3 likedBy 배열 축소/제거 (선택)

- 현재: `likedBy`에 userId 목록 저장 → 문서 크기 증가
- 권장: `likes/{userId}` 서브컬렉션만 사용, `likedBy` 제거
- 목록에서 `isLiked`: `likes/{userId}.get()` 대신 `getLikeState` 1회 또는 캐시 사용
- 레거시 호환: 점진적 제거, 읽기 시 `likedBy`와 `likes` 병합

---

## 7. 서버 Read 최소화

### 7.1 목록 화면

| 기존 | 개선 |
|------|------|
| `snapshots()` 전체 구독 | `limit(20).get()` + 새로고침 |
| 또는 `limit(20).snapshots()` | 1스트림만 구독 |
| isLiked N회 get | post 문서의 likedBy 또는 캐시 활용 |

### 7.2 상세 화면

| 기존 | 개선 |
|------|------|
| 게시글 + 댓글 스트림 | 게시글 `get()` 1회, 댓글 `limit(20).get()` 1회 |
| likeCount/isLiked 별도 get | `getLikeState` 1회 또는 캐시 |

### 7.3 Firestore 옵션 활용

```dart
// 캐시 우선 (오프라인·비용 절감)
final doc = await ref.get(const GetOptions(source: Source.cache));

// 서버 강제 (새로고침)
final doc = await ref.get(const GetOptions(source: Source.server));

// 캐시 있으면 캐시, 없으면 서버 (기본)
final doc = await ref.get();
```

---

## 8. 트랜잭션 재시도 최소화

### 8.1 원인

- 동시에 같은 post에 like/unlike → 트랜잭션 충돌 → 재시도
- 많은 트랜잭션이 같은 post 문서를 read/update

### 8.2 대응

1. **디바운스**: 클라이언트에서 300ms 디바운스로 동시 요청 감소
2. **현재 설계 유지**: `likes/{userId}` 기반 멱등 → 재시도 시에도 write 1회만
3. **트랜잭션 범위 축소**: `postRef.get()` 대신 `likeRef.get()`만으로 판단 가능하면, post read 생략 검토 (likeCount 갱신이 필요하면 post read는 유지)

### 8.3 트랜잭션 실패 시

```dart
try {
  return await _firestore.runTransaction(...);
} on FirebaseException catch (e) {
  if (e.code == 'transaction-failed' || e.code == 'aborted') {
    // 1회 재시도 후 사용자에게 실패 표시
    await Future.delayed(Duration(milliseconds: 100));
    return await _firestore.runTransaction(...);
  }
  rethrow;
}
```

---

## 9. 구현 우선순위

| 순서 | 항목 | 예상 효과 | 난이도 |
|------|------|-----------|--------|
| 1 | 목록 snapshots → get + limit + 새로고침 | Read 대폭 감소 | 중 |
| 2 | 댓글 snapshots → get + limit + 페이지네이션 | Read 감소 | 중 |
| 3 | 좋아요 디바운스 300ms | Write/트랜잭션 감소 | 하 |
| 4 | LikeStateCache (상세 진입 시 1회) | Read 감소 | 하 |
| 5 | Optimistic UI + 롤백 (좋아요/댓글) | UX 개선 | 중 |
| 6 | CommunityPostCache (목록) | Read 감소 | 중 |
| 7 | likedBy 배열 제거 (선택) | 문서 크기 감소 | 상 |

---

## 10. 요약

- **캐시**: 목록·상세·likeCount/isLiked용 메모리 캐시 + TTL
- **새로고침**: Pull-to-Refresh + `get()` 기반 로드
- **Optimistic UI**: 즉시 반영 후 실패 시 롤백
- **Write**: 디바운스 + 기존 멱등 구조 유지
- **Read**: snapshots 최소화, limit·페이지네이션, `GetOptions(source: ...)` 활용
- **트랜잭션**: 디바운스로 동시 요청 감소, 재시도 1회 제한

이 설계를 단계적으로 적용하면 Firestore 비용을 크게 줄일 수 있습니다.
