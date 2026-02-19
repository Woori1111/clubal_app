import 'package:flutter/widgets.dart';

import '../models/user_profile.dart';

class UserProfileController extends ChangeNotifier {
  UserProfileController({
    UserProfile? initial,
  }) : _profile = initial ??
            const UserProfile(
              displayName: '주지훈',
              bio: '나는 주지훈 입니다. 1000만 영화배우입니다!!',
            );

  UserProfile _profile;

  UserProfile get profile => _profile;

  void update(UserProfile value) {
    _profile = value;
    notifyListeners();
  }

  void updatePartial({
    String? displayName,
    String? bio,
  }) {
    _profile = _profile.copyWith(
      displayName: displayName,
      bio: bio,
    );
    notifyListeners();
  }
}

class UserProfileScope extends InheritedNotifier<UserProfileController> {
  const UserProfileScope({
    super.key,
    required UserProfileController controller,
    required Widget child,
  }) : super(notifier: controller, child: child);

  static UserProfileController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<UserProfileScope>();
    assert(scope != null, 'UserProfileScope is not found in the widget tree.');
    return scope!.notifier!;
  }
}

