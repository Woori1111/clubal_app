import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// iOS에서 시트 형태(하단에서 올라오는 모달, 둥근 상단)로 표시하는 페이지 라우트.
/// Android/Web에서는 일반 풀스크린으로 표시.
class ClubalSheetPageRoute<T> extends PageRouteBuilder<T> {
  ClubalSheetPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(
         settings: settings,
         opaque: false,
         barrierDismissible: true,
         fullscreenDialog: true,
         transitionDuration: const Duration(milliseconds: 350),
         reverseTransitionDuration: const Duration(milliseconds: 300),
         pageBuilder: (context, animation, secondaryAnimation) =>
             builder(context),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
             const curve = Curves.easeOutCubic;
             final tween = Tween(
               begin: const Offset(0, 1),
               end: Offset.zero,
             ).chain(CurveTween(curve: curve));
             final offset = animation.drive(tween);
             final opacity = animation.drive(
               Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve)),
             );
             return ClipRRect(
               borderRadius: const BorderRadius.vertical(
                 top: Radius.circular(20),
               ),
               child: SlideTransition(
                 position: offset,
                 child: FadeTransition(opacity: opacity, child: child),
               ),
             );
           }
           return FadeTransition(opacity: animation, child: child);
         },
       );
}
