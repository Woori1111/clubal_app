import 'package:flutter/foundation.dart';

import '../models/notification_settings.dart';

class NotificationSettingsController extends ChangeNotifier {
  NotificationSettingsController({
    NotificationSettings? initial,
  }) : _settings = initial ?? const NotificationSettings();

  NotificationSettings _settings;

  NotificationSettings get settings => _settings;

  void update(NotificationSettings value) {
    _settings = value;
    notifyListeners();
  }

  void updateField(NotificationSettings Function(NotificationSettings) updater) {
    _settings = updater(_settings);
    notifyListeners();
  }
}

