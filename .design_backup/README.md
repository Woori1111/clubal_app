# 디자인 백업

이 디렉토리는 커뮤니티 화면의 현재 디자인 상태를 백업한 파일들입니다.

## 백업된 파일들

- `community_tab_view.dart.backup` - 커뮤니티 탭 뷰
- `post_card.dart.backup` - 포스트 카드 위젯
- `clubal_top_tab_bar.dart.backup` - 탑 탭 바 위젯

## 현재 디자인 상태

### 주요 특징:
1. **텍스트 색상**: 모든 텍스트가 검정색(`Colors.black`)으로 설정됨
2. **스크롤 동작**: `ClampingScrollPhysics()` 적용으로 스크롤 끝에서 카드가 늘어나지 않음
3. **카드 레이아웃**: `maxHeight` 제약 제거, `Expanded` 위젯 제거로 고정 높이 문제 해결

### 변경된 파일:
- `lib/features/home/presentation/community_tab_view.dart`
- `lib/features/home/widgets/post_card.dart`
- `lib/features/navigation/widgets/clubal_top_tab_bar.dart`

## 롤백 방법

롤백이 필요할 경우, 백업 파일들을 원본 위치로 복사하면 됩니다:

```bash
Copy-Item ".design_backup\community_tab_view.dart.backup" "lib\features\home\presentation\community_tab_view.dart"
Copy-Item ".design_backup\post_card.dart.backup" "lib\features\home\widgets\post_card.dart"
Copy-Item ".design_backup\clubal_top_tab_bar.dart.backup" "lib\features\navigation\widgets\clubal_top_tab_bar.dart"
```

또는 "롤백해줘"라고 요청하면 자동으로 복원됩니다.
