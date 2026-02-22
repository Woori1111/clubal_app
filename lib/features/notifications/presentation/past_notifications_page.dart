import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/core/widgets/clubal_full_body.dart';
import 'package:clubal_app/core/widgets/glass_card.dart';
import 'package:clubal_app/core/widgets/pressed_icon_action_button.dart';
import 'package:clubal_app/features/notifications/models/notification_item.dart';
import 'package:clubal_app/features/notifications/repositories/notification_repository.dart';
import 'package:flutter/material.dart';

class PastNotificationsPage extends StatefulWidget {
  const PastNotificationsPage({super.key});

  @override
  State<PastNotificationsPage> createState() => _PastNotificationsPageState();
}

class _PastNotificationsPageState extends State<PastNotificationsPage> {
  final NotificationRepository _repository = LocalNotificationRepository.instance;
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final data = await _repository.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteItem(String id) async {
    await _repository.deleteNotification(id);
    if (mounted) {
      setState(() {
        _notifications.removeWhere((e) => e.id == id);
      });
    }
  }

  Future<void> _deleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('전체 삭제'),
        content: const Text('정말 모든 알림을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('확인', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await _repository.deleteAll();
    if (!mounted) return;

    final count = _notifications.length;
    for (var i = 0; i < count; i++) {
      if (!mounted) return;
      setState(() => _notifications.removeAt(0));
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _markAsRead(String id) async {
    await _repository.markAsRead(id);
    if (mounted) {
      setState(() {
        final index = _notifications.indexWhere((e) => e.id == id);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
        }
      });
    }
  }

  void _onNotificationTap(BuildContext context, NotificationItem item) {
    _markAsRead(item.id);
    if (item.targetTabIndex != null) {
      Navigator.of(context).pop(item.targetTabIndex);
    } else {
      _showExpandedNotification(context, item);
    }
  }

  void _showExpandedNotification(BuildContext context, NotificationItem item) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '알림',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: Center(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.body,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    height: 1.5,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              item.timeAgo,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const emptyMessage = '현재는 알림이 없습니다. 새로운 소식이 있으면 알려드리겠습니다.';

    return Scaffold(
      body: Builder(
        builder: (context) => wrapFullBody(
          context,
          Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(child: ClubalBackground()),
              ),
              SafeArea(
                child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PressedIconActionButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: '뒤로가기',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '지난 알림',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (_notifications.isNotEmpty)
                        TextButton(
                          onPressed: _deleteAll,
                          child: const Text('전체 삭제', style: TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _notifications.isEmpty
                            ? Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 320),
                                  child: Text(
                                    emptyMessage,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.grey,
                                          height: 1.45,
                                        ),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: _notifications.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item = _notifications[index];
                                  return Dismissible(
                                    key: Key(item.id),
                                    direction: DismissDirection.startToEnd,
                                    onDismissed: (_) {
                                      _deleteItem(item.id);
                                    },
                                    background: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.only(left: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(Icons.delete_rounded, color: Colors.white),
                                    ),
                                    child: GestureDetector(
                                      onTap: () => _onNotificationTap(context, item),
                                      child: _NotificationListTile(item: item),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationListTile extends StatelessWidget {
  const _NotificationListTile({required this.item});

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!item.isRead)
                  Container(
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF243244),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.body,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF5C6B7A),
                              height: 1.35,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item.timeAgo,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
