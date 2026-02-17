import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/core/widgets/glass_card.dart';
import 'package:clubal_app/core/widgets/pressed_icon_action_button.dart';
import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _chat = true;
  bool _service = true;
  bool _marketing = false;
  bool _recommendation = true;
  bool _matching = true;
  bool _reservation = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const ClubalBackground(),
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
                      Text(
                        '알림',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: const Color(0xFFE9F6FF),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AnimatedToggleRow(
                          label: '채팅 알림',
                          description: '매칭된 클러버와의 새 채팅을 알려드려요.',
                          value: _chat,
                          onChanged: (v) => setState(() => _chat = v),
                        ),
                        const SizedBox(height: 12),
                        _AnimatedToggleRow(
                          label: '서비스 알림',
                          description: '서비스 이용에 필요한 중요 알림이에요.',
                          value: _service,
                          onChanged: (v) => setState(() => _service = v),
                        ),
                        const SizedBox(height: 12),
                        _AnimatedToggleRow(
                          label: '마케팅·광고성 알림',
                          description: '이벤트, 혜택, 프로모션 소식을 받아요.',
                          value: _marketing,
                          onChanged: (v) => setState(() => _marketing = v),
                        ),
                        const SizedBox(height: 12),
                        _AnimatedToggleRow(
                          label: '정기 추천 알림',
                          description: '주기적으로 클럽/모임 추천을 보내드려요.',
                          value: _recommendation,
                          onChanged: (v) => setState(() => _recommendation = v),
                        ),
                        const SizedBox(height: 12),
                        _AnimatedToggleRow(
                          label: '매칭 알림',
                          description: '매칭 요청, 수락/거절 상태를 알려드려요.',
                          value: _matching,
                          onChanged: (v) => setState(() => _matching = v),
                        ),
                        const SizedBox(height: 12),
                        _AnimatedToggleRow(
                          label: '예약 알림',
                          description: '입장 시간, 취소/변경 등 예약 상태를 안내해요.',
                          value: _reservation,
                          onChanged: (v) => setState(() => _reservation = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedToggleRow extends StatefulWidget {
  const _AnimatedToggleRow({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String description;
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
                  children: [
                    Text(
                      widget.label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: const Color(0xFFF3FAFF),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.description,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: const Color(0xCCE2F2FF)),
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

class _GlassToggle extends StatefulWidget {
  const _GlassToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  State<_GlassToggle> createState() => _GlassToggleState();
}

class _GlassToggleState extends State<_GlassToggle> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: 46,
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.value
                ? const Color(0x77A7ECFF)
                : const Color(0x55FFFFFF),
            width: 1,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.value
                ? const [Color(0x7FF3FAFF), Color(0x7FA7ECFF)]
                : const [Color(0x30FFFFFF), Color(0x1F9EBCFF)],
          ),
        ),
        child: Align(
          alignment:
              widget.value ? Alignment.centerRight : Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.95),
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

