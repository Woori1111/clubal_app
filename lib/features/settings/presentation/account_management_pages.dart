import 'package:clubal_app/core/utils/app_dialogs.dart';
import 'package:clubal_app/core/widgets/glass_card.dart';
import 'package:flutter/material.dart';

/// 계정 관리 메인 목록 (계정 관리 하위)
class AccountManagementBody extends StatelessWidget {
  const AccountManagementBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            child: Column(
              children: [
                _AccountActionRow(
                  title: '계정 비활성화',
                  subtitle: '일시적으로 계정을 중지해요',
                  onTap: () => _showDeactivateDialog(context),
                ),
                const SizedBox(height: 14),
                _AccountActionRow(
                  title: '이전 계정 찾기',
                  subtitle: '이전에 사용하던 계정을 찾아요',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PreviousAccountFindPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                _AccountActionRow(
                  title: '로그아웃',
                  subtitle: '현재 계정에서 로그아웃해요',
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          title: const Text('로그아웃 하시겠어요?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('아니오'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                Navigator.of(context).popUntil(
                                  (route) => route.isFirst,
                                );
                              },
                              child: const Text('네'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 14),
                _AccountActionRow(
                  title: '계정 삭제',
                  subtitle: '계정을 완전히 삭제할 수 있어요',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AccountDeletePage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('계정을 비활성화 하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('아니오'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AccountDeactivatedPage(),
                  ),
                );
              },
              child: const Text('네'),
            ),
          ],
        );
      },
    );
  }
}

class _AccountActionRow extends StatelessWidget {
  const _AccountActionRow({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ],
      ),
    );
  }
}

/// 계정 비활성화 완료 화면
class AccountDeactivatedPage extends StatelessWidget {
  const AccountDeactivatedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '계정 비활성화 상태',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                '계정을 다시 활성화하면 모든 서비스를 이용할 수 있어요.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const Spacer(),
              GlassCard(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '계정 활성화',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ],
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

/// 이전 계정 찾기 화면
class PreviousAccountFindPage extends StatefulWidget {
  const PreviousAccountFindPage({super.key});

  @override
  State<PreviousAccountFindPage> createState() =>
      _PreviousAccountFindPageState();
}

class _PreviousAccountFindPageState extends State<PreviousAccountFindPage> {
  final _currentPhoneController = TextEditingController();
  final _previousPhoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _currentPhoneError = false;
  bool _previousPhoneError = false;
  bool _emailError = false;

  @override
  void dispose() {
    _currentPhoneController.dispose();
    _previousPhoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    final current = _currentPhoneController.text.trim();
    final previous = _previousPhoneController.text.trim();
    final email = _emailController.text.trim();

    final phoneReg = RegExp(r'^01[0-9]{8,9}$');
    final emailReg = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

    final currentError = !phoneReg.hasMatch(current);
    final previousError = !phoneReg.hasMatch(previous);
    final emailError = !emailReg.hasMatch(email);

    setState(() {
      _currentPhoneError = currentError;
      _previousPhoneError = previousError;
      _emailError = emailError;
    });

    if (currentError || previousError || emailError) {
      return;
    }

    showMessageDialog(context, message: '제출이 완료되었습니다.');
  }

  @override
  Widget build(BuildContext context) {
    final errorFillColor = const Color(0xFFFFE5EC);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '문제 해결을 위해\n아래에 정보를 남겨주세요.',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '입력하신 정보는 계정을 찾는 용도로만 사용돼요.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LabeledTextField(
                        label: '현재 사용 중인 전화번호',
                        hintText: '예: 01012345678',
                        controller: _currentPhoneController,
                        errorText: _currentPhoneError
                            ? '올바른 전화번호를 입력해주세요.'
                            : null,
                        fillColor:
                            _currentPhoneError ? errorFillColor : Colors.white,
                      ),
                      const SizedBox(height: 18),
                      _LabeledTextField(
                        label: '이전에 가입했던 전화번호',
                        hintText: '예: 01098765432',
                        controller: _previousPhoneController,
                        errorText: _previousPhoneError
                            ? '올바른 전화번호를 입력해주세요.'
                            : null,
                        fillColor:
                            _previousPhoneError ? errorFillColor : Colors.white,
                      ),
                      const SizedBox(height: 18),
                      _LabeledTextField(
                        label: '답변 받으실 이메일 주소',
                        hintText: '예: example@clubal.com',
                        controller: _emailController,
                        errorText: _emailError
                            ? '올바른 이메일을 입력해주세요.'
                            : null,
                        fillColor:
                            _emailError ? errorFillColor : Colors.white,
                      ),
                      const SizedBox(height: 32),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: _validateAndSubmit,
                          child: GlassCard(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Text(
                                '다음',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _LabeledTextField extends StatelessWidget {
  const _LabeledTextField({
    required this.label,
    required this.hintText,
    required this.controller,
    this.errorText,
    this.fillColor,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final String? errorText;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0x22000000)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText == null
                    ? const Color(0x22000000)
                    : const Color(0xFFFF9BB9),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText == null
                    ? const Color(0xFF9EBCFF)
                    : const Color(0xFFFF9BB9),
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFFF4B8A),
                ),
          ),
        ],
      ],
    );
  }
}

/// 계정 삭제 화면 (UI 전용)
class AccountDeletePage extends StatelessWidget {
  const AccountDeletePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '계정 삭제',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                '계정을 삭제하면 일부 정보는 복구가 어려울 수 있어요.\n정말 삭제를 원하실 때에만 진행해 주세요.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const Spacer(),
              GlassCard(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    showMessageDialog(context, message: '계정 삭제 요청이 접수되었습니다.');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '계정 삭제 진행',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        Icon(
                          Icons.delete_outline_rounded,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ],
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

