import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/core/widgets/glass_card.dart';
import 'package:clubal_app/core/widgets/pressed_icon_action_button.dart';
import 'package:clubal_app/features/settings/presentation/marketing_notification_page.dart';
import 'package:clubal_app/features/settings/presentation/notification_settings_controller.dart';
import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key, this.highlightItem});

  final String? highlightItem;

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  late final NotificationSettingsController _controller =
      NotificationSettingsController();
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _itemKeys = {
    'chat': GlobalKey(),
    'matching': GlobalKey(),
    'sound': GlobalKey(),
    'vibration': GlobalKey(),
    'postActivity': GlobalKey(),
    'postLikes': GlobalKey(),
    'commentsReplies': GlobalKey(),
    'recommendedPosts': GlobalKey(),
    'recommendation': GlobalKey(),
    'promotion': GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    if (widget.highlightItem != null && _itemKeys.containsKey(widget.highlightItem)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final key = _itemKeys[widget.highlightItem];
        if (key != null && key.currentContext != null) {
          Scrollable.ensureVisible(
            key.currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: 0.5,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = _controller.settings;

    return Scaffold(
      body: Stack(
        children: [
          const ClubalBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: SingleChildScrollView(
                controller: _scrollController,
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
                        Text(
                          '알림',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '새로운 알림',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _AnimatedToggleRow(
                            key: _itemKeys['chat'],
                            label: '채팅 알림',
                            value: settings.chat,
                            onChanged: (v) {
                              setState(
                                () => _controller.update(
                                  settings.copyWith(chat: v),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _AnimatedToggleRow(
                            key: _itemKeys['matching'],
                            label: '매칭 알림',
                            value: settings.matching,
                            onChanged: (v) {
                              setState(
                                () => _controller.update(
                                  settings.copyWith(matching: v),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _AnimatedToggleRow(
                            key: _itemKeys['sound'],
                            label: '소리',
                            value: settings.sound,
                            onChanged: (v) {
                              setState(
                                () => _controller.update(
                                  settings.copyWith(sound: v),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _AnimatedToggleRow(
                            key: _itemKeys['vibration'],
                            label: '진동',
                            value: settings.vibration,
                            onChanged: (v) {
                              setState(
                                () => _controller.update(
                                  settings.copyWith(vibration: v),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '커뮤니티',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _AnimatedToggleRow(
                            key: _itemKeys['postActivity'],
                            label: '게시물 및 활동',
                            value: settings.postActivity,
                            onChanged: (v) {
                              setState(
                                () => _controller.update(
                                  settings.copyWith(postActivity: v),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _AnimatedToggleRow(
                            key: _itemKeys['postLikes'],
                            label: '내 게시물에 좋아요',
                            value: settings.postLikes,
                            onChanged: (v) {
                              setState(
                                () => _controller.update(
                                  settings.copyWith(postLikes: v),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _AnimatedToggleRow(
                            key: _itemKeys['commentsReplies'],
                            label: '댓글과 답글',
                            value: settings.commentsReplies,
                            onChanged: (v) {
                              setState(
                                () => _controller.update(
                                  settings.copyWith(commentsReplies: v),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _AnimatedToggleRow(
                            key: _itemKeys['recommendedPosts'],
                            label: '추천 게시물',
                            value: settings.recommendedPosts,
                            onChanged: (v) {
                              setState(
                                () => _controller.update(
                                  settings.copyWith(recommendedPosts: v),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '추천 알림',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _AnimatedToggleRow(
                            key: _itemKeys['recommendation'],
                            label: '정기 추천 알림',
                            value: settings.recommendation,
                            onChanged: (v) {
                              setState(
                                () => _controller.update(
                                  settings.copyWith(recommendation: v),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _AnimatedToggleRow(
                            key: _itemKeys['promotion'],
                            label: '각종 프로모션',
                            value: settings.promotion,
                            onChanged: (v) {
                              setState(
                                () => _controller.update(
                                  settings.copyWith(promotion: v),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    GlassCard(
                      child: _SettingRowWithArrow(
                        title: '마케팅·광고성 알림',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const MarketingNotificationPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingRowWithArrow extends StatelessWidget {
  const _SettingRowWithArrow({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedToggleRow extends StatefulWidget {
  const _AnimatedToggleRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  State<_AnimatedToggleRow> createState() => _AnimatedToggleRowState();
}

class _AnimatedToggleRowState extends State<_AnimatedToggleRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.97 : 1.0;
    final opacity = _pressed ? 0.86 : 1.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _GlassToggle(
                value: widget.value,
                onChanged: widget.onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassToggle extends StatelessWidget {
  const _GlassToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: 46,
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: value
                ? const Color(0x77A7ECFF)
                : const Color(0x55FFFFFF),
            width: 1,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: value
                ? const [Color(0x7FF3FAFF), Color(0x7FA7ECFF)]
                : const [Color(0x30FFFFFF), Color(0x1F9EBCFF)],
          ),
        ),
        child: Align(
          alignment:
              value ? Alignment.centerRight : Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.95),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
