/// 클럽 데이터 모델.
class Club {
  const Club({
    required this.id,
    required this.name,
    required this.location,
    required this.genre,
    this.todayMatchCount = 0,
  });

  final String id;
  final String name;
  final String location;
  final String genre;
  final int todayMatchCount;
}
