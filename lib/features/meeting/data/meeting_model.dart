/// 모임 데이터 모델.
/// 서버 연동 시 Firestore/REST API 응답 매핑용.
class Meeting {
  const Meeting({
    required this.id,
    required this.title,
    required this.date,
    required this.status,
    required this.createdBy,
  });

  final String id;
  final String title;
  final DateTime date;
  final String status;
  final String createdBy;

  Meeting copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? status,
    String? createdBy,
  }) {
    return Meeting(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
