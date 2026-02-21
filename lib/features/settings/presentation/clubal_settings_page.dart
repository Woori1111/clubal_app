import 'package:clubal_app/core/widgets/clubal_page_scaffold.dart';
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
    return ClubalPageScaffold(
      title: '설정',
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: InlineSettingsContent(
            controller: _notificationController,
            onNotificationSettingsChanged: () => setState(() {}),
          ),
        ),
      ),
    );
  }
}
