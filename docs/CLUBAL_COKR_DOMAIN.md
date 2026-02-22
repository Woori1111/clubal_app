# clubal.co.kr 도메인 적용

## 프로젝트 반영 내용

- **웹 타이틀**: `클러버 Clubal | clubal.co.kr`
- **canonical URL**: `https://clubal.co.kr/`
- **manifest**: 앱 이름·설명·테마색 (clubal.co.kr 기준)
- **빌드 스크립트**: `./scripts/build_web.sh` → base-href `/` (clubal.co.kr 루트용)

## 배포 순서 (clubal.co.kr 연결)

1. **빌드**
   ```bash
   ./scripts/build_web.sh
   ```

2. **Firebase Hosting 배포**
   ```bash
   firebase deploy --only hosting
   ```
   → 먼저 `https://<프로젝트ID>.web.app` 에 올라갑니다.

3. **커스텀 도메인 연결**
   - [Firebase 콘솔](https://console.firebase.google.com) → 프로젝트 **clubal** → **Hosting** → **도메인 추가**
   - `clubal.co.kr` 또는 `www.clubal.co.kr` 입력
   - 안내에 따라 **DNS 설정** (가비아 등 도메인 관리 페이지에서)
     - **A 레코드** 또는 **CNAME** 값을 Firebase가 알려준 대로 입력
   - 전파 후(수 분~48시간) Firebase가 인증하면 `https://clubal.co.kr` 로 접속 가능

## DNS 예시 (가비아)

| 유형   | 호스트 | 값/위치                          |
|--------|--------|-----------------------------------|
| A      | @      | Firebase가 안내한 IP              |
| CNAME  | www    | `<프로젝트ID>.web.app` (안내 참고) |

도메인 구매처가 가비아가 아니어도, 해당 업체 DNS 설정 화면에서 같은 방식으로 A 또는 CNAME만 추가하면 됩니다.
