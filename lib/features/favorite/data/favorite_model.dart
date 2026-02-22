/// 즐겨찾기 데이터 모델.
class Favorite {
  const Favorite({
    required this.id,
    required this.userId,
    required this.clubId,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String clubId;
  final DateTime createdAt;
}
