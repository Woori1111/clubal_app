import 'package:clubal_app/core/theme/app_theme.dart';
import 'package:clubal_app/core/utils/url_util.dart';
import 'package:clubal_app/features/home/presentation/clubal_home_shell.dart';
import 'package:clubal_app/features/profile/presentation/user_profile_scope.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

class ClubalApp extends StatefulWidget {
  const ClubalApp({super.key});

  @override
  State<ClubalApp> createState() => _ClubalAppState();
}

class _ClubalAppState extends State<ClubalApp> {
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _handleKakaoRedirect();
    }
  }

  /// 웹: 카카오 로그인 리다이렉트 복귀 시 URL의 code로 Firebase Custom Token 발급 후 로그인.
  Future<void> _handleKakaoRedirect() async {
    final code = Uri.base.queryParameters['code'];
    if (code == null || code.isEmpty) return;

    try {
      final token = await _getKakaoFirebaseToken(code);
      if (token != null && token.isNotEmpty) {
        await _signInWithCustomToken(token);
      }
    } catch (_) {
      // 실패 시 그냥 넘어감 (토스트 등은 설정 화면에서 처리)
    } finally {
      clearWebQueryParams();
    }
  }

  Future<String?> _getKakaoFirebaseToken(String code) async {
    final callable = FirebaseFunctions.instance.httpsCallable('getKakaoFirebaseToken');
    final result = await callable.call({'code': code});
    final data = result.data;
    if (data is! Map) return null;
    final token = data['customToken'];
    return token is String ? token : null;
  }

  Future<void> _signInWithCustomToken(String token) async {
    await FirebaseAuth.instance.signInWithCustomToken(token);
  }

  @override
  Widget build(BuildContext context) {
    return UserProfileScope(
      controller: UserProfileController(),
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: '클러버 Clubal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: ClubalHomeShell(navigatorKey: _navigatorKey),
      ),
    );
  }
}

