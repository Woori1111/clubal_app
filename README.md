# 클러버 Clubal 앱

동성 유저끼리 클럽 동행을 매칭하고, 테이블 비용을 1/N으로 분담할 수 있도록 돕는 Flutter 앱입니다.

## 디자인 가이드

- 팀/AI 공통 기준 문서: `DESIGN_GUIDE.md`
- 핵심 키워드: `Liquid Lens`, `Droplet Geometry`, `Elastic Motion`

## 현재 기본 구현

- `lib/main.dart`
  - 클러버 브랜드 홈 스캐폴드
  - iOS 26.3 감성의 글래스/렌즈 배경
  - 하단 5탭(홈/매칭/채팅/파티/메뉴) 플로팅 젤리 네비게이션

## 실행

```bash
flutter pub get
flutter run
```

## Firebase 연결 준비

- `pubspec.yaml`에 `firebase_core`가 추가되어 있습니다.
- 현재 `lib/main.dart`에서 앱 시작 시 `Firebase.initializeApp()`을 시도합니다.
- 실제 연결을 위해 아래 파일/설정이 필요합니다.
  - iOS: `ios/Runner/GoogleService-Info.plist`
  - Android: `android/app/google-services.json`
  - 필요 시 `flutterfire configure`로 플랫폼 설정 자동 생성
