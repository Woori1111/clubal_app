import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/core/widgets/pressed_icon_action_button.dart';
import 'package:clubal_app/features/settings/presentation/notification_settings_controller.dart';
import 'package:clubal_app/features/settings/widgets/inline_settings_content.dart';
import 'package:flutter/material.dart';

class ClubalSettingsPage extends StatefulWidget {
  const ClubalSettingsPage({super.key});

  @override
  State<ClubalSettingsPage> createState() => _ClubalSettingsPageState();
}

class _ClubalSettingsPageState extends State<ClubalSettingsPage> {
  late final NotificationSettingsController _notificationController =
      NotificationSettingsController();

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
                        '설정',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: SingleChildScrollView(
                      child: InlineSettingsContent(
                        controller: _notificationController,
                        onNotificationSettingsChanged: () => setState(() {}),
                      ),
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
