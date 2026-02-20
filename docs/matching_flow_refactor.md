# 매칭 플로우 최적화 및 통일

## 1. iOS 하단 네비 흰색 깜빡임 수정

**원인**: `setTabBarVisible(false)` 시 네이티브 탭바를 **뷰 계층에서 제거**하고, 다시 `true`로 할 때 **새 인스턴스를 만들어** 붙이고 있었음. 새 UITabBar가 한 프레임 동안 시스템 기본 배경(흰색)으로 그려진 뒤 `applyLiquidGlassAppearance()`가 적용되며 깜빡임 발생.

**수정** (`ios/Runner/LiquidRoot.swift`):
- 탭바를 **제거하지 않고** 항상 뷰 계층에 두고, **opacity**와 **allowsHitTesting**으로만 숨김/표시.
- `isTabBarVisible ? 1 : 0` opacity + `allowsHitTesting(isTabBarVisible)`.
- 다시 보일 때 뷰가 재생성되지 않아 흰색 깜빡임 제거.

---

## 2. 매칭 플로우 공통 컴포넌트

### 추가된 위젯

| 위젯 | 용도 |
|------|------|
| `MatchingAppBar` | 뒤로가기 + 제목 + 선택적 trailing (편집 등) |
| `MatchingPageScaffold` | ClubalBackground + SafeArea + 앱바 + 본문 영역 |

### 리팩터링된 화면

- **AutoMatchPage**: `MatchingPageScaffold` + 공통 앱바 사용.
- **CreatePieceRoomPage**: 동일. `_buildHeader` 제거.
- **PieceRoomDetailPage**: 동일. 편집 버튼은 `appBarTrailing`로 전달.

패딩(상단 16, 좌우 20), 앱바 스타일, 배경 구조가 세 화면에서 동일하게 맞춰짐.

---

## 3. 추가 통일 제안

### 3.0 성공/실패 색상 (적용 완료)

- **성공(진행)**: `AppColors.success` = `#3AC0A0` (모집중, 성공 메시지 등)
- **실패(경고/중단)**: `AppColors.failure` = `#ED3241` (모집완료, 꽉참, 에러 등)
- 매칭 인원수 텍스트·상태 선택 시트 아이콘에 적용됨. 앞으로 성공/실패 표현은 이 색으로 통일.

### 3.1 브랜드 색상 상수

- `AutoMatchPage`, `CreatePieceRoomPage`, `PieceRoomDetailPage`에서 `Color(0xFF2ECEF2)` 등이 반복됨.
- **제안**: `lib/core/theme/app_colors.dart`(또는 기존 테마)에 `brandPrimary` 등으로 정의 후 전역 사용.

### 3.2 장소 카드 위젯 공개

- `PieceRoomDetailPage`의 `_LocationCard`는 글라스 + 장소 아이콘 + 텍스트.
- **제안**: `lib/features/matching/presentation/widgets/location_card.dart`로 분리해 목록/상세/다른 플로우에서 재사용. (이미 목록 카드에는 `_MatchingInfoChip`으로 비슷한 역할 존재.)

### 3.3 하단 시트 스타일 통일

- `_showRecruitmentStatusSheet`에서 `Container` + `surface` + `borderRadius`로 시트 구성.
- **제안**: `MatchingBottomSheet` 같은 래퍼를 두어, 제목 + 리스트 타일 + 패딩/모서리를 통일. (다른 모달에서도 재사용 가능.)

### 3.4 상세 하단 버튼 (상태변경 / 삭제)

- 조각 상세의 "상태변경", "삭제" 버튼이 인라인으로 길게 정의됨.
- **제안**: 글라스 스타일의 `MatchingActionButton`(primary / destructive)로 추출해, ConfirmButton과 비슷하게 한 곳에서 스타일 관리.

### 3.5 사용처 없는 위젯

- `matching_room_grid_card.dart`: 현재 매칭 탭은 `MatchingRoomListItem` + 2열 Wrap만 사용. 그리드 카드가 다른 경로에서 쓰이지 않으면 제거 또는 deprecated 표시 후 정리.

### 3.6 PlaceSelection / DatePicker

- `PlaceSelectionPage`, `AppDatePickerDialog`는 자동매치와 조각 만들기에서 공통 사용 중. 유지하고, 필요 시 "매칭 플로우 공통 다이얼로그"로 문서화하면 됨.

---

## 4. 매칭 관련 파일 목록 (참고)

```
lib/features/matching/
├── models/
│   └── piece_room.dart
├── presentation/
│   ├── auto_match_page.dart      ← MatchingPageScaffold 사용
│   ├── create_piece_room_page.dart
│   ├── matching_tab_view.dart
│   ├── piece_room_detail_page.dart
│   ├── dialogs/
│   │   └── app_date_picker_dialog.dart
│   ├── place/
│   │   ├── place_selection.dart
│   │   └── place_selection_page.dart
│   └── widgets/
│       ├── matching_app_bar.dart       (신규)
│       ├── matching_page_scaffold.dart (신규)
│       ├── auto_match_fab.dart
│       ├── matching_glass_card.dart
│       ├── matching_room_list_item.dart
│       ├── matching_room_grid_card.dart
│       ├── matching_section_label.dart
│       ├── confirm_button.dart
│       ├── option_chip.dart
│       ├── arrow_circle_button.dart
│       └── ...
```
