import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// iOS에서만 사용. 네이티브 SwiftUI 뷰를 임베드합니다.
/// [viewType]은 AppDelegate에 등록된 id와 일치해야 합니다.
bool get kUseIOSNativeUI =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

class IOSNativeMatchingPlusButton extends StatelessWidget {
  const IOSNativeMatchingPlusButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kUseIOSNativeUI) return const SizedBox.shrink();
    return SizedBox(
      width: 52,
      height: 52,
      child: UiKitView(
        viewType: 'ios_matching_plus',
        creationParams: <String, dynamic>{},
        creationParamsCodec: const StandardMessageCodec(),
        hitTestBehavior: PlatformViewHitTestBehavior.opaque,
      ),
    );
  }
}

class IOSNativeAutoMatchFab extends StatelessWidget {
  const IOSNativeAutoMatchFab({super.key, required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (!kUseIOSNativeUI) return const SizedBox.shrink();
    return SizedBox(
      width: compact ? 58 : 156,
      height: 58,
      child: UiKitView(
        viewType: 'ios_auto_match_fab',
        creationParams: <String, dynamic>{'compact': compact},
        creationParamsCodec: const StandardMessageCodec(),
        hitTestBehavior: PlatformViewHitTestBehavior.opaque,
      ),
    );
  }
}

class IOSNativeChatTopBar extends StatelessWidget {
  const IOSNativeChatTopBar({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    if (!kUseIOSNativeUI) return const SizedBox.shrink();
    return SizedBox(
      height: 52,
      child: UiKitView(
        viewType: 'ios_chat_top_bar',
        creationParams: <String, dynamic>{'selectedIndex': selectedIndex},
        creationParamsCodec: const StandardMessageCodec(),
        hitTestBehavior: PlatformViewHitTestBehavior.opaque,
      ),
    );
  }
}

class IOSNativeCommunityTopBar extends StatelessWidget {
  const IOSNativeCommunityTopBar({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    if (!kUseIOSNativeUI) return const SizedBox.shrink();
    return SizedBox(
      height: 50,
      child: UiKitView(
        viewType: 'ios_community_top_bar',
        creationParams: <String, dynamic>{'selectedIndex': selectedIndex},
        creationParamsCodec: const StandardMessageCodec(),
        hitTestBehavior: PlatformViewHitTestBehavior.opaque,
      ),
    );
  }
}

class IOSNativeCommunityWriteFab extends StatelessWidget {
  const IOSNativeCommunityWriteFab({super.key, this.expanded = true});

  final bool expanded;

  @override
  Widget build(BuildContext context) {
    if (!kUseIOSNativeUI) return const SizedBox.shrink();
    return SizedBox(
      width: expanded ? 120 : 56,
      height: 56,
      child: UiKitView(
        viewType: 'ios_community_write_fab',
        creationParams: <String, dynamic>{'expanded': expanded},
        creationParamsCodec: const StandardMessageCodec(),
        hitTestBehavior: PlatformViewHitTestBehavior.opaque,
      ),
    );
  }
}

/// iOS 툴바 검색창 (채팅·메뉴). 탭 시 Flutter에서 시트/검색 페이지 오픈.
class IOSNativeToolbarSearchBar extends StatelessWidget {
  const IOSNativeToolbarSearchBar({
    super.key,
    required this.placeholder,
    required this.searchType,
  });

  final String placeholder;

  /// 'chat' | 'menu'
  final String searchType;

  @override
  Widget build(BuildContext context) {
    if (!kUseIOSNativeUI) return const SizedBox.shrink();
    return SizedBox(
      height: 44,
      child: UiKitView(
        viewType: 'ios_toolbar_search_bar',
        creationParams: <String, dynamic>{
          'placeholder': placeholder,
          'type': searchType,
        },
        creationParamsCodec: const StandardMessageCodec(),
        hitTestBehavior: PlatformViewHitTestBehavior.opaque,
      ),
    );
  }
}

/// iOS 설정 토글 행 (SwiftUI Toggle)
/// [channelName]이 없으면 설정 알림용 채널, 마케팅 페이지는 'com.clubal.app/marketing_toggles' 사용.
class IOSNativeToggleRow extends StatelessWidget {
  const IOSNativeToggleRow({
    super.key,
    required this.label,
    required this.value,
    required this.settingsKey,
    this.channelName,
  });

  final String label;
  final bool value;
  final String settingsKey;
  final String? channelName;

  @override
  Widget build(BuildContext context) {
    if (!kUseIOSNativeUI) return const SizedBox.shrink();
    return SizedBox(
      height: 44,
      child: UiKitView(
        viewType: 'ios_toggle_row',
        creationParams: <String, dynamic>{
          'label': label,
          'value': value,
          'key': settingsKey,
          if (channelName != null) 'channel': channelName!,
        },
        creationParamsCodec: const StandardMessageCodec(),
        hitTestBehavior: PlatformViewHitTestBehavior.opaque,
      ),
    );
  }
}
