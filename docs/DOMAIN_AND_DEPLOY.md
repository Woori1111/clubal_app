# 도메인 생성 및 Flutter 웹 적용 가이드

## 1단계: 도메인 구매(생성)

도메인은 "이름"을 사는 것입니다. 아래 중 하나에서 구매합니다.

| 서비스 | 특징 | 대략 비용 |
|--------|------|-----------|
| **가비아** | 국내 대표, 한글 지원 | .com 약 1.5만 원/년 |
| **Cloudflare** | DNS·보안 좋음, 원가 판매 | .com 약 1.2만 원/년 |
| **Namecheap** | 해외, 저렴 | .com 약 1만 원/년 |
| **AWS Route 53** | AWS 쓰는 경우 편함 | .com 약 1.2만 원/년 |

### 예시: 가비아에서 구매

1. [가비아](https://www.gabia.com) 접속 → **도메인** 메뉴
2. 원하는 이름 검색 (예: `clubal`)
3. `.com`, `.kr` 등 선택 후 **결제** → 구매 완료 시 "도메인 소유" 상태가 됨

---

## 2단계: 도메인과 서버(호스팅) 연결 개요

- **도메인**: 주소 이름 (예: `app.clubal.com`)
- **호스팅**: 실제 파일(Flutter 웹 빌드 결과)을 두는 곳

둘을 **DNS**로 연결합니다.

```
사용자 → app.clubal.com (도메인)
           ↓ DNS 조회
        실제 서버 IP 또는 호스팅 URL
           ↓
        Flutter 웹 파일 제공
```

---

## 3단계: 웹 호스팅 선택 및 배포

Flutter 웹은 **정적 파일**(HTML, JS, CSS)이므로 아래 중 하나를 쓰면 됩니다.

### A) Firebase Hosting (추천 – Flutter와 궁합 좋음)

- 이미 Firebase 쓰는 프로젝트에 적합
- 무료 용량 넉넉, HTTPS 자동, CDN 기본 적용

**설정 순서:**

1. **Firebase CLI 설치**
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

2. **프로젝트에서 Firebase 초기화**
   ```bash
   cd /Users/woori/flutter/clubal_app
   firebase init hosting
   ```
   - Public directory: `build/web` 입력
   - Single-page app: Yes
   - GitHub 자동 배포 원하면 설정, 아니면 No

3. **Flutter 빌드 후 배포**
   ```bash
   flutter build web --base-href /
   firebase deploy --only hosting
   ```
   배포 끝나면 `https://<프로젝트ID>.web.app` 주소가 생깁니다.

### B) Vercel

- GitHub 연동 시 푸시만 해도 자동 빌드·배포
- 무료 플랜으로 도메인 연결 가능

1. [vercel.com](https://vercel.com) 가입 → New Project → GitHub 저장소 연결
2. Build Command: `flutter build web --base-href /`  
   Output Directory: `build/web`
3. Deploy 후 Vercel이 준 주소(예: `clubal.vercel.app`)에 접속해 확인

### C) Netlify

- 드래그앤드롭 또는 Git 연동 배포
- 무료 플랜에서 커스텀 도메인 연결 가능

1. [netlify.com](https://netlify.com) 가입
2. Sites → Add new site → Deploy manually  
   또는 Git 연결 후 Build command: `flutter build web --base-href /`, Publish directory: `build/web`
3. 배포 후 `xxx.netlify.app` 형태 주소 부여

---

## 4단계: 커스텀 도메인 연결 (예: app.clubal.com)

호스팅 서비스에서 "커스텀 도메인"을 추가한 뒤, **도메인 등록처(가비아 등)에서 DNS만 수정**하면 됩니다.

### Firebase Hosting 기준 예시

1. **Firebase 콘솔**
   - 프로젝트 → Hosting → 도메인 추가
   - `app.clubal.com` 입력 후 안내에 따라 **A 레코드** 또는 **CNAME** 확인

2. **가비아(도메인 등록처) DNS 설정**
   - 가비아 → My가비아 → 도메인 → DNS 설정/관리
   - **호스트**: `app` (또는 안내한 대로)
   - **유형**: A 또는 CNAME
   - **값**: Firebase가 알려준 IP 또는 `xxx.web.app` 형태 주소
   - 저장 후 수 분~최대 48시간 내 전파

3. **Firebase에서 인증 완료**
   - Firebase가 "도메인 소유 확인" 후 HTTPS 인증서 자동 발급
   - 이후 `https://app.clubal.com` 로 접속 가능

### Vercel / Netlify

- 각 대시보드에서 **Domain** 또는 **Custom domain** 메뉴로 들어가
- `app.clubal.com` 추가 후 화면에 나오는 **CNAME** 또는 **A 레코드** 값을
- 가비아(또는 사용 중인 DNS)에 그대로 입력하면 됩니다.

---

## 5단계: Flutter 빌드에 도메인(경로) 반영

- **도메인 루트**에 둘 때 (예: `https://app.clubal.com/`):
  ```bash
  flutter build web --base-href /
  ```
- **서브경로**에 둘 때 (예: `https://clubal.com/app/`):
  ```bash
  flutter build web --base-href /app/
  ```

프로젝트에는 `scripts/build_web.sh` 를 두었으므로, 빌드할 때마다 아래처럼 사용하면 됩니다.

```bash
# 루트 도메인용
./scripts/build_web.sh

# 서브경로용
./scripts/build_web.sh /app/
```

---

## 요약 순서

| 순서 | 할 일 |
|------|--------|
| 1 | 도메인 구매 (가비아/Cloudflare 등) |
| 2 | 호스팅 선택 (Firebase Hosting 권장) |
| 3 | Flutter 빌드: `flutter build web --base-href /` |
| 4 | 호스팅에 배포 (firebase deploy / Vercel / Netlify) |
| 5 | 호스팅 대시보드에서 "커스텀 도메인" 추가 (예: app.clubal.com) |
| 6 | 도메인 등록처 DNS에서 A 또는 CNAME 설정 |
| 7 | 전파 후 https://app.clubal.com 접속 확인 |

이후 빌드·배포할 때마다 같은 `scripts/build_web.sh` 로 빌드하면 도메인에 맞게 적용됩니다.
