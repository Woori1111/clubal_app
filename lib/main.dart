import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:clubal_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ClubalApp());
}

class ClubalApp extends StatelessWidget {
  const ClubalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '클러버 Clubal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080A13),
        useMaterial3: true,
        fontFamilyFallback: const [
          'SF Pro Text',
          'Pretendard',
          'Apple SD Gothic Neo',
        ],
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8ED9FF),
          brightness: Brightness.dark,
        ),
      ),
      home: const ClubalHomeShell(),
    );
  }
}

class ClubalHomeShell extends StatefulWidget {
  const ClubalHomeShell({super.key});

  @override
  State<ClubalHomeShell> createState() => _ClubalHomeShellState();
}

class _ClubalHomeShellState extends State<ClubalHomeShell> {
  int _selectedIndex = 0;

  final List<_NavTab> _tabs = const [
    _NavTab(label: '홈', icon: Icons.home_rounded),
    _NavTab(label: '매칭', icon: Icons.people_alt_rounded),
    _NavTab(label: '채팅', icon: Icons.chat_bubble_rounded),
    _NavTab(label: '파티', icon: Icons.celebration_rounded),
    _NavTab(label: '메뉴', icon: Icons.menu_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final selected = _tabs[_selectedIndex];

    return Scaffold(
      body: Stack(
        children: [
          const _ClubalBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 120),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      '클러버 Clubal',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFE9F6FF),
                          ),
                    ),
                  ),
                  if (selected.label == '메뉴')
                    _PressedIconActionButton(
                      icon: Icons.settings_rounded,
                      tooltip: '설정',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ClubalSettingsPage(),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 86, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    '동성 친구들과 클럽 테이블비를 1/N으로,\n가볍게 매칭하고 안전하게 함께 가요.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xCCDEEFFF),
                      height: 1.4,
                    ),
                  ),
                  const Spacer(),
                  _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selected.label,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _tabDescription(selected.label),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: const Color(0xD9EAF6FF)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ClubalJellyBottomNav(
        tabs: _tabs,
        selectedIndex: _selectedIndex,
        onChanged: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  String _tabDescription(String label) {
    switch (label) {
      case '홈':
        return '오늘의 클럽 조각 현황과 추천 모임을 확인합니다.';
      case '매칭':
        return '함께 갈 인원을 찾고 1/N 조건을 맞춰 매칭합니다.';
      case '채팅':
        return '매칭된 인원과 입장 시간, 복장, 비용을 조율합니다.';
      case '파티':
        return '진행 중인 파티와 인기 클럽 일정을 탐색합니다.';
      case '메뉴':
        return '내 프로필, 인증, 결제, 알림 설정을 관리합니다.';
      default:
        return '';
    }
  }
}

class ClubalJellyBottomNav extends StatefulWidget {
  const ClubalJellyBottomNav({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<_NavTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  State<ClubalJellyBottomNav> createState() => _ClubalJellyBottomNavState();
}

class _ClubalJellyBottomNavState extends State<ClubalJellyBottomNav> {
  int? _interactionIndex;
  double? _interactionDx;
  bool _isInteracting = false;
  double _travelDirection = 0; // -1: left, 1: right

  int _indexFromLocalDx(double dx, double width) {
    final clampedDx = dx.clamp(0.0, width - 0.001);
    final itemWidth = width / widget.tabs.length;
    final index = (clampedDx / itemWidth).floor();
    return index.clamp(0, widget.tabs.length - 1);
  }

  double _centerDxForIndex(int index, double itemWidth) {
    return (itemWidth * index) + (itemWidth / 2);
  }

  void _startInteraction(int index, double itemWidth) {
    final previous = _interactionIndex ?? widget.selectedIndex;
    final direction = (index - previous).toDouble().sign;
    setState(() {
      _interactionIndex = index;
      _interactionDx = _centerDxForIndex(index, itemWidth);
      _isInteracting = true;
      _travelDirection = direction;
    });
    widget.onChanged(index);
  }

  void _updateInteractionByDx(double dx, double width) {
    final index = _indexFromLocalDx(dx, width);
    if (_interactionIndex == index && _isInteracting) {
      return;
    }
    final previous = _interactionIndex ?? widget.selectedIndex;
    final direction = (index - previous).toDouble().sign;
    setState(() {
      _interactionIndex = index;
      _interactionDx = dx.clamp(0.0, width);
      _isInteracting = true;
      _travelDirection = direction;
    });
    widget.onChanged(index);
  }

  void _endInteraction() {
    setState(() {
      _isInteracting = false;
      _interactionIndex = null;
      _interactionDx = null;
      _travelDirection = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const sidePadding = 8.0;
    final activeIndex = _interactionIndex ?? widget.selectedIndex;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottomInset),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            height: 74,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              border: Border.all(color: const Color(0x55FFFFFF), width: 1.2),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0x4DF3FAFF), Color(0x33A7B7FF)],
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final navWidth = constraints.maxWidth - (sidePadding * 2);
                final itemWidth = navWidth / widget.tabs.length;
                final lensWidth = itemWidth * 0.96;
                final restingLensLeft =
                    sidePadding +
                    (itemWidth * activeIndex) +
                    (itemWidth - lensWidth) / 2;
                final dragLensLeft =
                    sidePadding +
                    ((_interactionDx ??
                                _centerDxForIndex(activeIndex, itemWidth)) -
                            (lensWidth / 2))
                        .clamp(0.0, navWidth - lensWidth);
                final lensLeft = _isInteracting
                    ? dragLensLeft
                    : restingLensLeft;

                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: _isInteracting
                          ? Duration.zero
                          : const Duration(milliseconds: 520),
                      curve: _isInteracting ? Curves.linear : Curves.elasticOut,
                      left: lensLeft,
                      top: 6,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOutCubic,
                        scale: _isInteracting ? 1.08 : 1.0,
                        child: _NavLens(
                          width: lensWidth,
                          isInteracting: _isInteracting,
                          travelDirection: _travelDirection,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      left: sidePadding,
                      right: sidePadding,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onHorizontalDragStart: (details) =>
                            _updateInteractionByDx(
                              details.localPosition.dx,
                              navWidth,
                            ),
                        onHorizontalDragUpdate: (details) =>
                            _updateInteractionByDx(
                              details.localPosition.dx,
                              navWidth,
                            ),
                        onHorizontalDragEnd: (_) => _endInteraction(),
                        onHorizontalDragCancel: _endInteraction,
                        child: Row(
                          children: [
                            for (int i = 0; i < widget.tabs.length; i++)
                              Expanded(
                                child: _NavItemButton(
                                  tab: widget.tabs[i],
                                  selected: i == widget.selectedIndex,
                                  onTapDown: () =>
                                      _startInteraction(i, itemWidth),
                                  onTap: () {
                                    widget.onChanged(i);
                                    _endInteraction();
                                  },
                                  onTapCancel: _endInteraction,
                                  onTapUp: _endInteraction,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemButton extends StatelessWidget {
  const _NavItemButton({
    required this.tab,
    required this.selected,
    required this.onTapDown,
    required this.onTap,
    required this.onTapUp,
    required this.onTapCancel,
  });

  final _NavTab tab;
  final bool selected;
  final VoidCallback onTapDown;
  final VoidCallback onTap;
  final VoidCallback onTapUp;
  final VoidCallback onTapCancel;

  @override
  Widget build(BuildContext context) {
    final fgColor = selected
        ? const Color(0xFFF5FCFF)
        : const Color(0xB3DCEAFF);
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => onTapDown(),
        onTapUp: (_) => onTapUp(),
        onTapCancel: onTapCancel,
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(tab.icon, color: fgColor, size: 21),
              const SizedBox(height: 4),
              SizedBox(
                height: 14,
                child: Center(
                  child: Text(
                    tab.label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: fgColor,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLens extends StatelessWidget {
  const _NavLens({
    required this.width,
    required this.isInteracting,
    required this.travelDirection,
  });

  final double width;
  final bool isInteracting;
  final double travelDirection;

  @override
  Widget build(BuildContext context) {
    if (!isInteracting) {
      return Container(
        width: width,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF9AE1FF), Color(0xFF69C6F6)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x5522B8FF),
              blurRadius: 16,
              spreadRadius: -8,
              offset: Offset(0, 7),
            ),
          ],
        ),
      );
    }

    final leadingBoost = travelDirection < 0 ? 1.0 : 0.56;
    final trailingBoost = travelDirection > 0 ? 1.0 : 0.56;

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        // 인터랙션 중에만 뒤 배경을 살짝 굴절/확산시키는 느낌.
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            // 외곽선 없이 중심은 투명에 가깝게 유지.
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x35FFFFFF), Color(0x10FFFFFF)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0x30000000),
                blurRadius: 18,
                spreadRadius: -8,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 상단에만 아주 얇은 광택.
              Positioned(
                top: 2,
                left: width * 0.18,
                right: width * 0.18,
                child: Container(
                  height: 1.2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0x00FFFFFF),
                        Colors.white.withValues(alpha: 0.52),
                        const Color(0x00FFFFFF),
                      ],
                    ),
                  ),
                ),
              ),
              // 왼쪽 끝 돋보기 하이라이트 (이동 방향에 따라 가변 강화).
              Positioned(
                left: -8,
                top: 8,
                child: _LensEdgeGlow(
                  size: 42,
                  strength: leadingBoost,
                  isInteracting: true,
                ),
              ),
              // 오른쪽 끝 돋보기 하이라이트 (이동 방향에 따라 가변 강화).
              Positioned(
                right: -8,
                top: 8,
                child: _LensEdgeGlow(
                  size: 42,
                  strength: trailingBoost,
                  isInteracting: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LensEdgeGlow extends StatelessWidget {
  const _LensEdgeGlow({
    required this.size,
    required this.strength,
    required this.isInteracting,
  });

  final double size;
  final double strength;
  final bool isInteracting;

  @override
  Widget build(BuildContext context) {
    final alpha = (isInteracting ? 0.42 : 0.24) * strength;
    final coreAlpha = (isInteracting ? 0.34 : 0.18) * strength;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: coreAlpha),
            const Color(0x66DDF6FF).withValues(alpha: alpha),
            Colors.transparent,
          ],
          stops: const [0.12, 0.52, 1.0],
        ),
      ),
    );
  }
}

class _PressedIconActionButton extends StatefulWidget {
  const _PressedIconActionButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  State<_PressedIconActionButton> createState() =>
      _PressedIconActionButtonState();
}

class _PressedIconActionButtonState extends State<_PressedIconActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.92 : 1.0;
    final opacity = _pressed ? 0.72 : 1.0;

    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: opacity,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0x66FFFFFF),
                      width: 1,
                    ),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0x4FFFFFFF), Color(0x269EBCFF)],
                    ),
                  ),
                  child: Icon(widget.icon, color: Color(0xFFE9F6FF), size: 22),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ClubalSettingsPage extends StatefulWidget {
  const ClubalSettingsPage({super.key});

  @override
  State<ClubalSettingsPage> createState() => _ClubalSettingsPageState();
}

class _ClubalSettingsPageState extends State<ClubalSettingsPage> {
  bool _isAuthBusy = false;
  bool _googleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) {
      return;
    }
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
      if (mounted) {
        setState(() => _isAuthBusy = false);
      }
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
      if (mounted) {
        setState(() => _isAuthBusy = false);
      }
    }
  }

  void _showMessage(String text) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _ClubalBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      _PressedIconActionButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: '뒤로가기',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '설정',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFFE9F6FF),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _GlassCard(
                    child: StreamBuilder<User?>(
                      stream: FirebaseAuth.instance.authStateChanges(),
                      builder: (context, snapshot) {
                        final user = snapshot.data;
                        final isLoggedIn = user != null;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SettingRow(
                              title: '알림 설정',
                              subtitle: '매칭/채팅 알림 관리',
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
                            ),
                            const SizedBox(height: 14),
                            _SettingRow(title: '고객지원', subtitle: '문의 및 신고 접수'),
                          ],
                        );
                      },
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
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
                      const Icon(Icons.g_mobiledata_rounded, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFFF4FBFF),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
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
                  color: const Color(0xFFF3FAFF),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xCCE2F2FF)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0x55FFFFFF), width: 1),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0x3AFFFFFF), Color(0x1F9EBCFF)],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ClubalBackground extends StatelessWidget {
  const _ClubalBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F172B), Color(0xFF080A13)],
        ),
      ),
      child: Stack(
        children: const [
          Positioned(
            left: -70,
            top: -40,
            child: _GlowBubble(size: 230, color: Color(0xAA66C8FF)),
          ),
          Positioned(
            right: -110,
            top: 220,
            child: _GlowBubble(size: 280, color: Color(0x665E86FF)),
          ),
          Positioned(
            left: 40,
            bottom: 150,
            child: _GlowBubble(size: 180, color: Color(0x885CFFD7)),
          ),
        ],
      ),
    );
  }
}

class _GlowBubble extends StatelessWidget {
  const _GlowBubble({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

class _NavTab {
  const _NavTab({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
