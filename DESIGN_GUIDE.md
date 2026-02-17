# Clubal Design Guide v1

## 1) 제품 개요
- 앱 이름: `클러버` (국문), `Clubal` (영문)
- 제품 정의: 동성 유저끼리 클럽 동행을 매칭해 테이블 비용을 `1/N`으로 분담하도록 돕는 소셜 매칭 앱
- 플랫폼: `Flutter` 기반 `iOS + Android` 동시 개발
- 디자인 목표: iOS 26.3 감성의 반투명 렌즈, 물방울, 둥근 윤곽, 부드러운 탄성 모션을 핵심 시그니처로 통일

## 2) 비주얼 컨셉 정의
### 컨셉 키워드
- `Liquid Lens`: 반투명 유리 렌즈가 화면 위에 떠 있는 듯한 레이어
- `Droplet Geometry`: 모서리가 둥근 캡슐/물방울 형태의 컴포넌트
- `Soft Depth`: 강한 그림자 대신 퍼지는 글로우와 얕은 깊이
- `Elastic Motion`: 탭 전환/선택 시 젤리 같은 탄성 이동

### 감성 원칙
- 모든 주요 표면은 각진 직사각형 대신 `radius 20+` 사용
- 불투명 단색 블록 대신 `blur + alpha + gradient` 조합 우선
- 인터랙션은 즉시 반응하되, 과장되지 않은 `스프링/탄성` 커브 적용
- 정보 계층은 "색 대비"보다 "투명도 + 레이어 깊이"로 표현

## 3) 컬러 시스템 (초안 토큰)
### Base
- `bg.base`: `#080A13`
- `bg.top`: `#0F172B`
- `surface.glass.1`: `#3AFFFFFF`
- `surface.glass.2`: `#1F9EBCFF`

### Accent
- `accent.cyan`: `#8ED9FF`
- `accent.mint`: `#5CFFD7`
- `accent.violet`: `#5E86FF`

### Text
- `text.primary`: `#E9F6FF`
- `text.secondary`: `#CCDEEFFF`
- `text.tertiary`: `#B3DCEAFF`

### Effect
- `stroke.glass`: `#55FFFFFF`
- `lens.highlight`: `#A0FFFFFF`
- `glow.primary`: `#8022B8FF`

## 4) 타이포그래피
- 권장 폰트 우선순위: `SF Pro Text` -> `Pretendard` -> `Apple SD Gothic Neo`
- Heading: 700 weight, line-height 1.2
- Body: 400~500 weight, line-height 1.4~1.5
- Caption/Label: 500~700 weight, line-height 1.2

## 5) 공간/모서리/블러 규칙
- 기본 radius 스케일: `12 / 20 / 28 / 34`
- 핵심 컴포넌트(카드/네비/모달): `radius 28+`
- 유리면 블러: `sigma 18~26`
- 경계선: `1.0~1.2px`, 흰색 저알파(`~35%`)

## 6) 핵심 컴포넌트 가이드
### Glass Card
- 구성: 배경 블러 + 반투명 그라데이션 + 얇은 흰색 스트로크
- 사용처: 매칭 카드, 파티 요약, 채팅 프리뷰

### Primary Pill Button
- 형태: 캡슐형, 높이 48~56
- 상태: Normal / Press / Disabled
- Press 시 밝기 +4%, scale 0.98, 80~140ms

### Status Chip
- 형태: 작은 물방울 캡슐
- 상태 컬러는 직접 채우지 않고, `accent` + 투명도 조절로 통일

## 7) 모션 원칙
- 기본 duration: `180~260ms`
- 강조 전환(탭 렌즈 이동): `420~560ms`
- 추천 curve:
  - 일반 전환: `easeOutCubic`
  - 렌즈/젤리: `elasticOut` 또는 약한 spring
- 햅틱:
  - 탭 선택: light impact
  - 매칭 완료/확정: medium impact

## 8) 하단 네비게이션 명세 (필수)
### 구조
- 탭: `홈`, `매칭`, `채팅`, `파티`, `메뉴` (총 5개)
- 배치: 화면 하단에서 살짝 띄운 `floating capsule bar`
- 좌/우 끝: 완전 둥근 캡슐 모양 (`radius 34` 권장)

### 비주얼
- 바 본체: 반투명 유리 + 얇은 흰색 경계선 + 약한 내부 광택
- 선택 인디케이터: `물방울 렌즈`가 선택 탭 위치로 이동
- 아이콘/텍스트:
  - 선택: `text.primary`
  - 비선택: `text.tertiary`

### 인터랙션
- `onTapDown`: 렌즈가 즉시 해당 탭 쪽으로 반응 시작
- `onTap`: 선택 상태 확정
- `onLongPress`: 렌즈 하이라이트와 미세 scale 변화(옵션)
- 이동 애니메이션: 500ms 전후, elastic 계열

## 9) 접근성/사용성 규칙
- 탭 터치 영역 최소: `44x44` 이상
- 텍스트 대비: 실제 배경 기준 WCAG AA를 목표
- 색상 외 구분 제공: 선택 탭은 weight/명도/렌즈 위치로 중복 표현

## 10) 브랜드 카피 톤
- 톤: 안전하고 믿을 수 있는 친구 매칭
- 금지 톤: 과도한 선정성, 위험 행동 조장
- 추천 문구 예시:
  - "함께 가면 가볍고, 같이 놀면 더 안전해요"
  - "클러버에서 오늘의 클럽 메이트를 찾아보세요"

## 11) 개발 핸드오프 규칙 (AI/팀 공통)
- 새 화면 추가 시 아래 체크리스트를 모두 충족해야 함
  1. 배경은 단색이 아닌 `base gradient` 또는 글로우 레이어 사용
  2. 주요 액션은 `pill` 또는 `glass` 형태 유지
  3. 카드/바/모달 모서리는 `radius 20+`
  4. 탭 이동/선택에는 즉시 반응 + 부드러운 탄성 모션 포함
  5. 텍스트는 `국문(클러버)`와 `영문(Clubal)` 병기 정책 준수

## 12) Flutter 기준 레퍼런스
- 실제 기본 구현 파일: `lib/main.dart`
- 구현 포함 항목:
  - 클러버 브랜드 헤더/카피
  - Liquid Lens 스타일 배경
  - 5탭 플로팅 젤리 하단 네비게이션
  - 탭 터치 즉시 렌즈 이동 (`onTapDown`) + 선택 확정 (`onTap`)

---
이 문서는 `Clubal` 디자인 의사결정의 기준 문서다. 신규 기능/화면 작업 시 본 문서를 우선 참조하고, 규칙 변경 시 반드시 버전 업데이트(`v1 -> v2`)와 변경 이력을 남긴다.
