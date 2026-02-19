# Clubal Liquid Glass Design System

이 문서는 Clubal 앱의 리퀴드 글래스 UI를 일관되게 확장하기 위한 기준 문서입니다.  
현재 구현된 하단 네비게이션/자동매치 FAB를 기준으로, 이후 카드/시트/모달/필터 칩까지 같은 문법으로 확장합니다.

## 1) 목표

- 단순 블러(Glassmorphism)가 아니라 **굴절(refraction) 기반 Liquid Glass**를 기본 표현으로 사용한다.
- 브랜드 포인트 컬러 의존을 줄이고, **중성(Neutral) 유리 톤**으로 시스템을 통일한다.
- 예쁜 효과보다 우선순위는 다음과 같다.
  - 가독성
  - 터치 정확도
  - 스크롤 성능
  - 모션 일관성

## 2) 사용 패키지와 기본 원칙

- 패키지: `liquid_glass_easy`
- 핵심 원칙:
  - 모든 리퀴드 컴포넌트는 `LiquidGlassView` 안에서 구성한다.
  - `backgroundWidget`은 렌즈 뒤에서 왜곡될 레이어를 포함해야 한다.
  - 렌즈 내부 콘텐츠(`child`)는 기능/텍스트 가독성을 위해 과도한 투명도를 피한다.

## 3) 레이어 구조 (Global)

리퀴드 글래스 UI는 아래 5계층으로 쌓는다.

1. **Scene Layer**  
   앱 배경, 리스트, 카드, 텍스처 등 실제 콘텐츠.

2. **Capture Layer (`LiquidGlassView.backgroundWidget`)**  
   렌즈가 왜곡할 대상. 필요한 하이라이트/소프트 블롭 포함.

3. **Lens Layer (`LiquidGlass`)**  
   굴절, 왜곡, 색수차, border lighting이 적용되는 핵심 유리 면.

4. **Content Layer (`LiquidGlass.child`)**  
   아이콘/텍스트/상태 배지 등 인터랙션 정보.

5. **Interaction Layer**  
   탭/드래그/프레스 제스처, 접근성 semantics, 피드백 모션.

## 4) 토큰 (권장 범위)

아래 수치는 Clubal 현재 화면 밀도 기준 권장 범위입니다.

### 4.1 렌즈 형태

- `cornerRadius`
  - Nav: `32 ~ 38`
  - FAB: `24 ~ 28`
  - Card/Sheet: `20 ~ 32`
- `borderWidth`: `0.9 ~ 1.4`
- `borderSoftness`: `2.0 ~ 3.0`

### 4.2 광학 효과

- `distortion`: `0.10 ~ 0.26`
- `distortionWidth`: `20 ~ 36`
- `magnification`: `1.00 ~ 1.03`
- `chromaticAberration`: `0.0008 ~ 0.0018`
- `saturation`: `0.90 ~ 0.98`
- `blur.sigmaX/Y`: `1.2 ~ 2.6`

### 4.3 조명 토큰

- `lightIntensity`: `1.3 ~ 1.8`
- `oneSideLightIntensity`: `1.0 ~ 1.7`
- `lightDirection`: `285 ~ 320`
- `lightColor`: `0xB2FFFFFF` 계열
- `shadowColor`: `0x1A000000` 계열

## 5) 현재 적용 컴포넌트 스펙

## 5.1 Bottom Navigation

- 파일: `lib/features/navigation/widgets/clubal_jelly_bottom_nav.dart`
- 구조:
  - 바 전체 렌즈 1개 + 이동 캡슐 렌즈 1개
  - 탭 선택 시 `_currentT` 기반으로 캡슐 위치 보간
  - 아이콘/텍스트는 선택 근접도(`emphasis`)로 반응
- 렌더링:
  - `LiquidGlassView` + `refreshRate: medium`
  - 중성 유리 톤(브랜드 블루 미사용)

## 5.2 Auto Match FAB

- 파일: `lib/features/matching/presentation/matching_tab_view.dart`
- 구조:
  - 단일 캡슐 렌즈 + 내부 `InkWell` 인터랙션
  - compact/expanded 전환 시 `AnimatedSwitcher`
- 렌더링:
  - `LiquidGlassView` + 단일 `LiquidGlass`
  - 가독성을 위해 텍스트/아이콘은 짙은 중성색 사용

## 6) 앞으로 전체 화면을 리퀴드로 확장하는 방식

“전체 디자인 구조를 리퀴드글래스로” 전환할 때는 아래 순서 권장.

1. **Navigation/FAB (완료)**  
   고정 UI 먼저 안정화.

2. **Surface Card 계층 통합**  
   `GlassCard`, 리스트 카드, 섹션 카드의 스타일 파편화 제거.

3. **Modal/BottomSheet 계층 통합**  
   시트 경계와 배경 왜곡을 동일 토큰으로 맞춤.

4. **Filter/Chip/Segmented Control 적용**  
   작은 인터랙션 컴포넌트에 미세 왜곡/라이트 적용.

5. **Page-level Capture 설계**  
   페이지 단위 `LiquidGlassView` 도입 여부를 성능 기준으로 판단.

## 7) 성능 가이드

리퀴드 글래스는 GPU 비용이 있으므로 아래를 기본값으로 사용한다.

- 기본:
  - `pixelRatio: 0.70 ~ 0.82`
  - `refreshRate: medium`
  - `useSync: true`
- 스크롤/애니메이션 많은 화면:
  - `pixelRatio`를 먼저 낮춘다.
  - 렌즈 수를 줄이고 큰 렌즈 하나로 묶는다.
- 정적 화면:
  - `realTimeCapture: false` + 수동 캡처 전략 고려.

## 8) 접근성/가독성 가이드

- 텍스트는 최소 대비를 확보한다.
  - 라벨/바디: `#1F2B38` 또는 그에 준하는 진한 중성색
- 반투명 레이어 위 텍스트는 항상 실기기에서 확인한다.
- 터치 타겟 최소 44dp를 유지한다.
- “예쁨”보다 상태 전달(활성/비활성/로딩/오류) 가독성을 우선한다.

## 9) QA 체크리스트

- [ ] 스크롤 중 FPS 급락 없음
- [ ] 탭 전환 시 렌즈 점프/깜빡임 없음
- [ ] 라이트/그림자가 다크 배경에서도 과장되지 않음
- [ ] iOS/Android/Web에서 최소 동일한 구조 인지 가능
- [ ] 작은 글자(12~14sp) 가독성 유지

## 10) 구현/리뷰 규칙

- 신규 UI 컴포넌트는 아래 항목을 PR에 반드시 명시한다.
  - `distortion`, `distortionWidth`, `blur`, `pixelRatio`
  - 렌즈 개수
  - 성능 영향 추정(저/중/고)
- “브랜드색 포인트 렌즈”는 특별한 프로모션 화면 외에는 금지한다.
- 중성 유리 톤을 기본값으로 사용하고, 강조는 콘텐츠로 해결한다.

## 11) 추천 다음 작업

- `core/theme`에 Liquid token 객체를 만들어 숫자 하드코딩을 제거한다.
- `GlassCard`/`PressedIconActionButton`도 동일 토큰 체계로 리팩터링한다.
- 화면 단위로 “리퀴드 강도 프리셋(soft/default/vivid)”를 도입한다.
