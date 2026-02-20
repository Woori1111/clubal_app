import 'package:clubal_app/features/notifications/models/notification_item.dart';

abstract class NotificationRepository {
  Future<List<NotificationItem>> getNotifications();
  Future<void> deleteNotification(String id);
  Future<void> deleteAll();
  Future<void> markAsRead(String id);
}

class LocalNotificationRepository implements NotificationRepository {
  final List<NotificationItem> _items = [
    NotificationItem(
      id: '1',
      title: '매칭 요청이 들어왔어요',
      body: '클럽 A 조각 방에 초대되었습니다. 수락하시겠어요?',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationItem(
      id: '2',
      title: '채팅 메시지',
      body: '김클럽님이 메시지를 보냈습니다.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationItem(
      id: '3',
      title: '예약 확정',
      body: '오늘 22:00 클럽 B 입장이 확정되었습니다.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Future<List<NotificationItem>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_items);
  }

  @override
  Future<void> deleteNotification(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _items.removeWhere((item) => item.id == id);
  }

  @override
  Future<void> deleteAll() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _items.clear();
  }

  @override
  Future<void> markAsRead(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(isRead: true);
    }
  }
}
