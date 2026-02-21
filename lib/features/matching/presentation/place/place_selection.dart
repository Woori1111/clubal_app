/// 장소 선택 결과 (지역·구·클럽명). 상관없음일 때 region == '상관없음'
class PlaceSelection {
  const PlaceSelection({
    required this.region,
    required this.district,
    required this.clubName,
  });

  final String region;
  final String district;
  final String clubName;

  bool get isAny => region == '상관없음' || region.isEmpty;

  /// 화면 표시용: 상관없음 또는 "지역 • 클럽명" (가운데 점 구분)
  String get displayLabel =>
      isAny ? '상관없음' : '$region • $clubName';
}
