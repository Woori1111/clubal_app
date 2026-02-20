/// 장소 선택 결과 (지역·구·클럽명)
class PlaceSelection {
  const PlaceSelection({
    required this.region,
    required this.district,
    required this.clubName,
  });

  final String region;
  final String district;
  final String clubName;

  String get displayLabel => '$region · $district · $clubName';
}
