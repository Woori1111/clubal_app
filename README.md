# 클러버 Clubal 앱

동성 유저끼리 클럽 동행을 매칭하고, 테이블 비용을 1/N으로 분담할 수 있도록 돕는 Flutter 앱입니다.

## 디자인 가이드

- 팀/AI 공통 기준 문서: `DESIGN_GUIDE.md`
- 핵심 키워드: `Liquid Lens`, `Droplet Geometry`, `Elastic Motion`

## 현재 기본 구현

- `lib/features/home/presentation/clubal_home_shell.dart`
  - 클러버 브랜드 홈 스캐폴드
  - 메뉴 탭에서 설정 화면 진입
- `lib/features/settings/presentation/clubal_settings_page.dart`
  - 구글 로그인/로그아웃
- `lib/features/navigation/widgets/clubal_jelly_bottom_nav.dart`
  - 하단 5탭 플로팅 젤리 네비게이션

## 파일 구조

```text
lib/
  app/
    clubal_app.dart
  core/
    theme/
      app_theme.dart
    widgets/
      clubal_background.dart
      glass_card.dart
      pressed_icon_action_button.dart
  features/
    home/presentation/clubal_home_shell.dart
    settings/presentation/clubal_settings_page.dart
    navigation/
      models/nav_tab.dart
      widgets/clubal_jelly_bottom_nav.dart
  firebase_options.dart
  main.dart
```

## Pretendard 폰트

- 현재 테마는 `Pretendard`를 기본 폰트로 사용하며 weight `400/500/700` 기준으로 스타일링되어 있습니다.
- 실제 Pretendard 파일을 앱에 번들하려면 `pubspec.yaml`에 폰트 assets를 추가해 주세요.

## 실행

```bash
flutter pub get
flutter run
```

## Firebase 연결 준비

- `pubspec.yaml`에 `firebase_core`가 추가되어 있습니다.
- `lib/main.dart`에서 `DefaultFirebaseOptions.currentPlatform` 기반으로 초기화합니다.
- 실제 연결을 위해 아래 파일/설정이 필요합니다.
  - iOS: `ios/Runner/GoogleService-Info.plist`
  - Android: `android/app/google-services.json`
  - 필요 시 `flutterfire configure`로 플랫폼 설정 자동 생성
