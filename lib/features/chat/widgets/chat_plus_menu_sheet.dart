import 'package:flutter/material.dart';

void showChatPlusMenuSheet(
  BuildContext context, {
  required VoidCallback onGallery,
  required VoidCallback onCamera,
  required VoidCallback onCalendar,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => _ChatPlusMenuSheet(
      onGallery: () {
        Navigator.of(context).pop();
        onGallery();
      },
      onCamera: () {
        Navigator.of(context).pop();
        onCamera();
      },
      onCalendar: () {
        Navigator.of(context).pop();
        onCalendar();
      },
    ),
  );
}

class _ChatPlusMenuSheet extends StatelessWidget {
  const _ChatPlusMenuSheet({
    required this.onGallery,
    required this.onCamera,
    required this.onCalendar,
  });

  final VoidCallback onGallery;
  final VoidCallback onCamera;
  final VoidCallback onCalendar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: 24 + MediaQuery.of(context).viewPadding.bottom,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PlusMenuItem(
                  icon: Icons.camera_alt_rounded,
                  label: '카메라',
                  onTap: onCamera,
                ),
                _PlusMenuItem(
                  icon: Icons.photo_library_rounded,
                  label: '갤러리',
                  onTap: onGallery,
                ),
                _PlusMenuItem(
                  icon: Icons.calendar_month_rounded,
                  label: '캘린더',
                  onTap: onCalendar,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlusMenuItem extends StatelessWidget {
  const _PlusMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 28, color: colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
