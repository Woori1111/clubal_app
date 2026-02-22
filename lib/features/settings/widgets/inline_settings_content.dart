import 'dart:convert';
import 'dart:math' show Random;

import 'package:clubal_app/core/kakao/kakao_config.dart';
import 'package:clubal_app/core/utils/app_dialogs.dart';
import 'package:clubal_app/core/widgets/glass_card.dart';
import 'package:clubal_app/features/settings/presentation/account_management_pages.dart';
import 'package:clubal_app/features/settings/presentation/customer_support_pages.dart';
import 'package:clubal_app/features/settings/presentation/notification_settings_page.dart';
import 'package:clubal_app/features/settings/presentation/notification_settings_controller.dart';
import 'package:clubal_app/features/settings/presentation/safety_block_body.dart';
import 'package:clubal_app/features/settings/presentation/settings_sub_page.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// 설정 화면 본문(알림 + 계정/기타). 메뉴 탭 프로필 아래와 설정 페이지에서 공통 사용.
class InlineSettingsContent extends StatefulWidget {
  const InlineSettingsContent({
    super.key,
    required this.controller,
    this.onNotificationSettingsChanged,
  });

  final NotificationSettingsController controller;
  final VoidCallback? onNotificationSettingsChanged;

  @override
  State<InlineSettingsContent> createState() => _InlineSettingsContentState();
}

class _InlineSettingsContentState extends State<InlineSettingsContent> {
  bool _isAuthBusy = false;
  bool _googleInitialized = false;

  bool get _showAppleSignIn =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  bool get _showKakaoSignIn => kIsWeb && KakaoConfig.isWebEnabled;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await GoogleSignIn.instance.initialize();
    _googleInitialized = true;
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isAuthBusy = true);
    try {
      await _ensureGoogleInitialized();
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        _showMessage('현재 플랫폼에서 Google 인증 버튼이 지원되지 않습니다.');
        return;
      }
      final googleUser = await GoogleSignIn.instance.authenticate();
      final authentication = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: authentication.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      _showMessage('로그인 실패: ${e.message ?? e.code}');
    } catch (e) {
      _showMessage('로그인 처리 중 오류가 발생했습니다: $e');
    } finally {
      if (mounted) setState(() => _isAuthBusy = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _isAuthBusy = true);
    try {
      await GoogleSignIn.instance.signOut();
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      _showMessage('로그아웃 처리 중 오류가 발생했습니다: $e');
    } finally {
      if (mounted) setState(() => _isAuthBusy = false);
    }
  }

  /// iOS용 Apple 로그인 (Firebase 연동). nonce는 재전송 공격 방지용.
  Future<void> _signInWithApple() async {
    setState(() => _isAuthBusy = true);
    try {
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256(rawNonce);
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
      final idToken = credential.identityToken;
      if (idToken == null || idToken.isEmpty) {
        _showMessage('Apple 로그인: ID 토큰을 받지 못했습니다.');
        return;
      }
      final oauthCredential = AppleAuthProvider.credentialWithIDToken(
        idToken,
        rawNonce,
        AppleFullPersonName(
          givenName: credential.givenName,
          familyName: credential.familyName,
        ),
      );
      await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    } on SignInWithAppleAuthorizationException catch (e) {
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          break;
        case AuthorizationErrorCode.notHandled:
          _showMessage('Apple 로그인이 처리되지 않았습니다.');
          break;
        case AuthorizationErrorCode.failed:
          _showMessage('Apple 로그인에 실패했습니다.');
          break;
        case AuthorizationErrorCode.invalidResponse:
          _showMessage('Apple 응답이 올바르지 않습니다.');
          break;
        case AuthorizationErrorCode.notInteractive:
          _showMessage('로그인 화면을 표시할 수 없습니다.');
          break;
        default:
          _showMessage('Apple 로그인 오류: ${e.message}');
      }
    } on FirebaseAuthException catch (e) {
      _showMessage('로그인 실패: ${e.message ?? e.code}');
    } catch (e) {
      _showMessage('로그인 처리 중 오류가 발생했습니다: $e');
    } finally {
      if (mounted) setState(() => _isAuthBusy = false);
    }
  }

  static String _generateNonce() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  static String _sha256(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// 웹용 카카오 로그인. 리다이렉트 후 콜백에서 code로 Firebase Custom Token 발급·로그인 처리.
  Future<void> _signInWithKakao() async {
    if (!KakaoConfig.isWebEnabled) {
      _showMessage('카카오 로그인이 설정되지 않았습니다.');
      return;
    }
    setState(() => _isAuthBusy = true);
    try {
      final redirectUri = '${Uri.base.origin}/';
      final talkInstalled = await kakao.isKakaoTalkInstalled();
      if (talkInstalled) {
        await kakao.AuthCodeClient.instance.authorizeWithTalk(redirectUri: redirectUri);
      } else {
        await kakao.AuthCodeClient.instance.authorize(redirectUri: redirectUri);
      }
      // 성공 시 페이지가 카카오로 리다이렉트되므로 여기 도달하지 않음.
    } catch (e) {
      if (mounted) _showMessage('카카오 로그인 시작 실패: $e');
    } finally {
      if (mounted) setState(() => _isAuthBusy = false);
    }
  }

  void _showMessage(String text) {
    if (!mounted) return;
    showMessageDialog(context, message: text);
  }

  void _pushNotificationSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const NotificationSettingsPage(),
      ),
    );
  }

  void _pushSubPage(String title, {Widget? child}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsSubPage(title: title, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassCard(
          child: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final isLoggedIn = snapshot.data != null;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SettingRow(title: '알림 설정', onTap: _pushNotificationSettings),
                  const SizedBox(height: 14),
                  const _SettingRow(title: '계정/인증'),
                  const SizedBox(height: 12),
                  _GoogleAuthButton(
                    busy: _isAuthBusy,
                    isLoggedIn: isLoggedIn,
                    onSignIn: _signInWithGoogle,
                    onSignOut: _signOut,
                  ),
                  if (_showAppleSignIn) ...[
                    const SizedBox(height: 10),
                    _AppleAuthButton(
                      busy: _isAuthBusy,
                      isLoggedIn: isLoggedIn,
                      onSignIn: _signInWithApple,
                      onSignOut: _signOut,
                    ),
                  ],
                  if (_showKakaoSignIn) ...[
                    const SizedBox(height: 10),
                    _KakaoAuthButton(
                      busy: _isAuthBusy,
                      isLoggedIn: isLoggedIn,
                      onSignIn: _signInWithKakao,
                      onSignOut: _signOut,
                    ),
                  ],
                  const SizedBox(height: 14),
                  _SettingRow(
                    title: '안전 & 차단 관리',
                    onTap: () => _pushSubPage('안전 & 차단 관리', child: const SafetyBlockBody()),
                  ),
                  const SizedBox(height: 14),
                  _SettingRow(
                    title: '고객지원',
                    onTap: () => _pushSubPage('고객지원', child: const CustomerSupportBody()),
                  ),
                  const SizedBox(height: 14),
                  _SettingRow(
                    title: '약관 및 정보',
                    onTap: () => _pushSubPage('약관 및 정보'),
                  ),
                  const SizedBox(height: 14),
                  _SettingRow(
                    title: '계정 관리',
                    onTap: () => _pushSubPage('계정 관리', child: const AccountManagementBody()),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _GoogleAuthButton extends StatefulWidget {
  const _GoogleAuthButton({
    required this.busy,
    required this.isLoggedIn,
    required this.onSignIn,
    required this.onSignOut,
  });

  final bool busy;
  final bool isLoggedIn;
  final VoidCallback onSignIn;
  final VoidCallback onSignOut;

  @override
  State<_GoogleAuthButton> createState() => _GoogleAuthButtonState();
}

class _GoogleAuthButtonState extends State<_GoogleAuthButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.97 : 1.0;
    final opacity = _pressed ? 0.78 : 1.0;
    final label = widget.busy
        ? '처리 중...'
        : widget.isLoggedIn
            ? 'Google 로그아웃'
            : 'Google로 로그인';

    return GestureDetector(
      onTapDown: widget.busy ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.busy ? null : (_) => setState(() => _pressed = false),
      onTapCancel: widget.busy ? null : () => setState(() => _pressed = false),
      onTap: widget.busy
          ? null
          : () => widget.isLoggedIn ? widget.onSignOut() : widget.onSignIn(),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOutCubic,
          child: Container(
            height: 48,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0x66FFFFFF), width: 1),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0x52FFFFFF), Color(0x269EBCFF)],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.busy)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(Icons.g_mobiledata_rounded, size: 26),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppleAuthButton extends StatefulWidget {
  const _AppleAuthButton({
    required this.busy,
    required this.isLoggedIn,
    required this.onSignIn,
    required this.onSignOut,
  });

  final bool busy;
  final bool isLoggedIn;
  final VoidCallback onSignIn;
  final VoidCallback onSignOut;

  @override
  State<_AppleAuthButton> createState() => _AppleAuthButtonState();
}

class _AppleAuthButtonState extends State<_AppleAuthButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.97 : 1.0;
    final opacity = _pressed ? 0.78 : 1.0;
    final label = widget.busy
        ? '처리 중...'
        : widget.isLoggedIn
            ? 'Apple 로그아웃'
            : 'Apple로 로그인';

    return GestureDetector(
      onTapDown: widget.busy ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.busy ? null : (_) => setState(() => _pressed = false),
      onTapCancel: widget.busy ? null : () => setState(() => _pressed = false),
      onTap: widget.busy
          ? null
          : () => widget.isLoggedIn ? widget.onSignOut() : widget.onSignIn(),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOutCubic,
          child: Container(
            height: 48,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Theme.of(context).colorScheme.onSurface,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.busy)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  Icon(
                    Icons.apple_rounded,
                    size: 26,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.surface,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KakaoAuthButton extends StatefulWidget {
  const _KakaoAuthButton({
    required this.busy,
    required this.isLoggedIn,
    required this.onSignIn,
    required this.onSignOut,
  });

  final bool busy;
  final bool isLoggedIn;
  final VoidCallback onSignIn;
  final VoidCallback onSignOut;

  @override
  State<_KakaoAuthButton> createState() => _KakaoAuthButtonState();
}

class _KakaoAuthButtonState extends State<_KakaoAuthButton> {
  bool _pressed = false;

  static const Color _kakaoYellow = Color(0xFFFEE500);
  static const Color _kakaoBrown = Color(0xFF191919);

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.97 : 1.0;
    final opacity = _pressed ? 0.78 : 1.0;
    final label = widget.busy
        ? '처리 중...'
        : widget.isLoggedIn
            ? '카카오 로그아웃'
            : '카카오로 로그인';

    return GestureDetector(
      onTapDown: widget.busy ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.busy ? null : (_) => setState(() => _pressed = false),
      onTapCancel: widget.busy ? null : () => setState(() => _pressed = false),
      onTap: widget.busy
          ? null
          : () => widget.isLoggedIn ? widget.onSignOut() : widget.onSignIn(),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOutCubic,
          child: Container(
            height: 48,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: _kakaoYellow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.busy)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _kakaoBrown,
                    ),
                  )
                else
                  Icon(Icons.chat_bubble_rounded, size: 22, color: _kakaoBrown),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: _kakaoBrown,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.title,
    this.onTap,
  });

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isTappable = onTap != null;

    Widget content = Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        if (isTappable) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ],
      ],
    );

    if (!isTappable) return content;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: content,
      ),
    );
  }
}
