import 'package:clubal_app/core/utils/app_dialogs.dart';
import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/core/widgets/glass_card.dart';
import 'package:clubal_app/core/widgets/pressed_icon_action_button.dart';
import 'package:clubal_app/features/settings/presentation/account_management_pages.dart';
import 'package:clubal_app/features/settings/presentation/customer_support_pages.dart';
import 'package:clubal_app/features/settings/presentation/notification_settings_page.dart';
import 'package:clubal_app/features/settings/presentation/notification_settings_controller.dart';
import 'package:clubal_app/features/settings/presentation/settings_sub_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

/// 설정 화면 본문(알림 + 계정/기타). 메뉴 탭 프로필 아래에서도 동일 위젯 사용.
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

  void _showMessage(String text) {
    if (!mounted) return;
    showMessageDialog(context, message: text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassCard(
          child: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              final isLoggedIn = user != null;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SettingRowWithArrow(
                    title: '알림 설정',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const NotificationSettingsPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _SettingRow(
                    title: '계정/인증',
                    subtitle: isLoggedIn
                        ? '연결 계정: ${user.email ?? user.displayName ?? user.uid}'
                        : '구글 로그인으로 계정을 연결해 주세요',
                  ),
                  const SizedBox(height: 12),
                  _GoogleAuthButton(
                    busy: _isAuthBusy,
                    isLoggedIn: isLoggedIn,
                    onSignIn: _signInWithGoogle,
                    onSignOut: _signOut,
                  ),
                  const SizedBox(height: 14),
                  _SettingRow(
                    title: '결제/정산',
                    subtitle: '1/N 결제 수단 및 내역',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SettingsSubPage(
                            title: '결제/정산',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _SettingRow(
                    title: '고객지원',
                    subtitle: '문의 및 신고 접수',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SettingsSubPage(
                            title: '고객지원',
                            child: CustomerSupportBody(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _SettingRow(
                    title: '약관 및 정보',
                    subtitle: '이용약관·개인정보처리방침',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SettingsSubPage(
                            title: '약관 및 정보',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _SettingRow(
                    title: '계정 관리',
                    subtitle: '프로필·보안·연동 관리',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SettingsSubPage(
                            title: '계정 관리',
                            child: AccountManagementBody(),
                          ),
                        ),
                      );
                    },
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

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isTappable = onTap != null;

    Widget content = Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFFA7ECFF),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ],
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

    if (!isTappable) {
      return content;
    }

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

class _SettingRowWithArrow extends StatelessWidget {
  const _SettingRowWithArrow({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
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
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedToggleRow extends StatefulWidget {
  const _AnimatedToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  State<_AnimatedToggleRow> createState() => _AnimatedToggleRowState();
}

class _AnimatedToggleRowState extends State<_AnimatedToggleRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.97 : 1.0;
    final opacity = _pressed ? 0.86 : 1.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _GlassToggle(
                value: widget.value,
                onChanged: widget.onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassToggle extends StatelessWidget {
  const _GlassToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: 46,
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: value
                ? const Color(0x77A7ECFF)
                : const Color(0x55FFFFFF),
            width: 1,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: value
                ? const [Color(0x7FF3FAFF), Color(0x7FA7ECFF)]
                : const [Color(0x30FFFFFF), Color(0x1F9EBCFF)],
          ),
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.95),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
