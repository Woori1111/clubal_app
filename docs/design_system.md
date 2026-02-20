# Clubal Design System

> 마지막 업데이트: 2026-02-18  
> 기준 구현: `ios/Runner/LiquidRoot.swift` + `lib/features/navigation/widgets/clubal_jelly_bottom_nav.dart`

---

## 1. 플랫폼별 렌더링 전략

| 플랫폼 | 바텀 네비게이션 | 렌더링 주체 |
|--------|---------------|-----------|
| **iOS** | 네이티브 SwiftUI `TabView` | OS (iOS 26+에서 자동 Liquid Glass) |
| **Android** | Flutter `ClubalJellyBottomNav` | Flutter (BackdropFilter 기반 유리 효과) |

iOS에서는 Apple이 `TabView`에 Liquid Glass를 자동 적용하므로, **직접 유리 효과를 구현하지 않는다.**  
Android에서는 Flutter로 동일한 시각적 언어를 재현한다.

---

## 2. 색상 토큰

### 2.1 네비게이션 아이콘/텍스트

```
비활성(Inactive):  #A0A0A5  — 중립 회색, 블루·따뜻한 계열 없음
활성(Active):      #1C1C1E  — iOS 시스템 near-black (다크 텍스트 기준)
```

> **원칙:** 비활성 → 활성 전환은 "회색 → 검정" 느낌으로만. 파란색·브랜드색 사용 금지.

### 2.2 앱 공통 색상

| 역할 | 값 |
|------|-----|
| Scaffold 배경 | `#F4F7FB` |
| Headline 텍스트 | `#1D2630` |
| Body 텍스트 | `rgba(44,61,80, 0.80)` |
| 유리 배경 (밝은 면) | `rgba(255,255,255, 0.21)` |
| 유리 배경 (어두운 면) | `rgba(255,255,255, 0.11)` |
| 유리 테두리 | `rgba(255,255,255, 0.33)` |
| 유리 그림자 | `rgba(0,0,0, 0.095)` |

---

## 3. 타이포그래피

**폰트 패밀리: `Pretendard`**  
iOS 폴백: `SF Pro Text` → `Apple SD Gothic Neo`

```
Headline Small : Pretendard Bold (700),   #1D2630
Title Large    : Pretendard Bold (700),   #1E2732
Title Small    : Pretendard Medium (500), #243242
Body Medium    : Pretendard Regular (400), rgba(44,61,80,0.80)
Body Small     : Pretendard Regular (400), rgba(65,84,105,0.80)
Label Small    : Pretendard Medium (500), #324357
Nav Label      : Pretendard Bold/Medium (700/500 선택적), 10sp
```

> 모든 `TextStyle()`을 직접 선언할 때는 `fontFamily: 'Pretendard'`를 명시한다.  
> 테마에 전역 설정되어 있어도, 커스텀 TextStyle은 상속이 보장되지 않는다.

---

## 4. 바텀 네비게이션 스펙

### 4.1 iOS — `LiquidRoot.swift`

```
파일     : ios/Runner/LiquidRoot.swift
방식     : SwiftUI ZStack
레이어 1 : FlutterViewRepresentable (전체 화면 Flutter 콘텐츠)
레이어 2 : TabView (Color.clear 콘텐츠, 탭바 UI만 네이티브 렌더)
채널     : MethodChannel("com.clubal.app/navigation") → setTab(Int)
아이콘   : SF Symbols (house.fill / person.2.fill / bubble.fill / sparkles / line.3.horizontal)
```

iOS 26+ 에서는 `TabView`가 자동으로 Liquid Glass 스타일로 렌더링된다.  
이전 버전에서는 기본 탭바 스타일로 표시되며, 별도 분기 처리 불필요.

### 4.2 Android — `ClubalJellyBottomNav`

```
파일         : lib/features/navigation/widgets/clubal_jelly_bottom_nav.dart
높이         : 74dp
패딩         : horizontal 20dp, bottom 14dp
모양         : 캡슐 (borderRadius 37)
블러         : BackdropFilter sigmaX/Y 32
배경 그라디언트: 0x36FFFFFF → 0x1CFFFFFF (top-left → bottom-right)
테두리       : 0x55FFFFFF, 0.9px
그림자       : blur 30, spread -8, offset (0,14) / blur 6, offset (0,2)
레인보우 테두리: SweepGradient (8색, 불투명도 0x30)
```

#### 아이콘 영역

| 상태 | 아이콘 크기 | 컨테이너 패딩 | 배경 |
|------|-----------|------------|------|
| 활성 | 18dp | H:12 V:5 | `#38FFFFFF` + 테두리 |
| 비활성 | 16dp | H:9 V:4 | 투명 |

#### 애니메이션 (탭 클릭 시 스프링 바운스)

```
총 시간: 520ms
구간: 1.0 → 1.28 (22%) → 0.86 (26%) → 1.10 (30%) → 0.97 (12%) → 1.0 (10%)
```

---

## 5. 유리(Glass) 컴포넌트 공통 원칙

1. **배경이 비쳐야 디자인이 완성된다.**  
   유리 요소 뒤에는 항상 스크롤되거나 움직이는 콘텐츠가 있어야 한다.

2. **텍스트는 유리 위에서 항상 가독성 우선.**  
   반투명 컨테이너 위 텍스트는 실기기(iOS/Android 각각)에서 확인한다.

3. **블루·브랜드 색상은 유리 자체에 넣지 않는다.**  
   강조는 콘텐츠(텍스트, 배지, 이미지)로 한다.

4. **터치 타겟은 최소 44dp.**

---

## 6. 화면별 패딩 규칙

| 조건 | 하단 여백 |
|------|---------|
| iOS (네이티브 탭바) | `SafeArea` + `additionalSafeAreaInsets.bottom = 49` → 자동 처리 |
| Android (Flutter 탭바) | 콘텐츠 bottom padding `120dp` (탭바 74 + 여유 46) |

---

## 7. MethodChannel 규약

```
채널명   : com.clubal.app/navigation
방향     : iOS → Flutter
메서드   : setTab(arguments: Int)  — 0:홈 1:매칭 2:채팅 3:파티 4:메뉴
```

Flutter 측 핸들러는 `ClubalHomeShell._handleNativeNavCall`에서 처리한다.  
Android에서는 이 채널을 사용하지 않는다.

---

## 8. 확장 가이드

새 UI 컴포넌트를 추가할 때 체크리스트:

- [ ] 색상 토큰(§2)에서 값 가져오기 — 하드코딩 금지
- [ ] 폰트 `fontFamily: 'Pretendard'` 명시
- [ ] 유리 배경은 §4.2 토큰 범위 내에서 구성
- [ ] iOS/Android 실기기에서 가독성 확인
- [ ] 터치 타겟 44dp 이상
- [ ] 스크롤 중 FPS 60 유지 확인

---

## 9. 파일 구조

```
ios/Runner/
  AppDelegate.swift      — FlutterEngine 생성, 플러그인 등록
  SceneDelegate.swift    — UIHostingController<LiquidRoot> 루트 설정
  LiquidRoot.swift       — SwiftUI ZStack + 네이티브 TabView

lib/
  core/theme/app_theme.dart                         — 전역 테마 (Pretendard, 색상)
  features/navigation/
    models/nav_tab.dart                             — NavTab 모델
    widgets/clubal_jelly_bottom_nav.dart            — Android 바텀 네비게이션
  features/home/presentation/clubal_home_shell.dart — Shell (플랫폼 분기 + MethodChannel)
```
