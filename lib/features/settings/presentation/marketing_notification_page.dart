import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/core/widgets/clubal_full_body.dart';
import 'package:clubal_app/core/widgets/glass_card.dart';
import 'package:clubal_app/core/widgets/pressed_icon_action_button.dart';
import 'package:flutter/material.dart';

/// 마케팅·광고성 알림 상세 설정 (알림 설정 > 마케팅 광고성 알림)
class MarketingNotificationPage extends StatefulWidget {
  const MarketingNotificationPage({super.key});

  @override
  State<MarketingNotificationPage> createState() =>
      _MarketingNotificationPageState();
}

class _MarketingNotificationPageState extends State<MarketingNotificationPage> {
  bool _consent = false;
  bool _sms = false;
  bool _appPush = false;

  @override
  Widget build(BuildContext context) {
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
                      Text(
                        '마케팅·광고성 알림',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
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
                        _ToggleRow(
                          label: '마케팅 목적 개인정보 수집·이용 동의',
                          description: '마케팅 목적의 정보 수집·이용에 동의합니다.',
                          value: _consent,
                          onChanged: (v) => setState(() => _consent = v),
                        ),
                        const SizedBox(height: 16),
                        _ToggleRow(
                          label: 'SMS 알림',
                          description: '이벤트, 혜택, 프로모션 소식을 문자로 받아요.',
                          value: _sms,
                          onChanged: (v) => setState(() => _sms = v),
                        ),
                        const SizedBox(height: 16),
                        _ToggleRow(
                          label: '마케팅·광고성 정보 앱 푸시',
                          description: '앱 푸시로 마케팅/광고성 소식을 받아요.',
                          value: _appPush,
                          onChanged: (v) => setState(() => _appPush = v),
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
    ),
  ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    this.description,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (description != null) ...[
                const SizedBox(height: 2),
                Text(
                  description!,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        _GlassToggle(value: value, onChanged: onChanged),
      ],
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
            color: value ? const Color(0x77A7ECFF) : const Color(0x55FFFFFF),
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
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
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
