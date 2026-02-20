class PieceRoom {
  const PieceRoom({
    required this.title,
    required this.currentMembers,
    required this.maxMembers,
    required this.creator,
    required this.location,
    required this.meetingAt,
    this.description,
  });

  final String title;
  final int currentMembers;
  final int maxMembers;
  final String creator;
  final String location;
  final DateTime meetingAt;
  final String? description;

  String get capacityLabel => '$currentMembers/$maxMembers';
}
