import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';

/// iOS에서 하단 safe area까지 body가 그려지도록 래핑.
/// 홈/매칭과 동일하게 모든 화면에서 하단 여백이 검게 보이지 않게 함.
bool get isIOSFullBody =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

Widget wrapFullBody(BuildContext context, Widget child) {
  if (!isIOSFullBody) return child;
  return MediaQuery.removePadding(
    context: context,
    removeBottom: true,
    child: child,
  );
}
