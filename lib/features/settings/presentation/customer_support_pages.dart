import 'package:clubal_app/core/widgets/glass_card.dart';
import 'package:clubal_app/features/settings/presentation/faq_page.dart';
import 'package:clubal_app/features/settings/presentation/bug_report_page.dart';
import 'package:clubal_app/features/settings/presentation/suggestion_page.dart';
import 'package:clubal_app/features/settings/presentation/one_on_one_support_page.dart';
import 'package:flutter/material.dart';

/// 고객지원 메인 목록 (고객센터, 개선할 점, 제보하기, 가장 많이 하는 질문)
class CustomerSupportBody extends StatelessWidget {
  const CustomerSupportBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _SupportGridCard(
                  title: '오류 제보',
                  subtitle: '앱의 버그나 오류를 알려주세요',
                  icon: Icons.bug_report_rounded,
                  iconColor: const Color(0xFFFF6B6B),
                  targetPage: const BugReportPage(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _SupportGridCard(
                  title: '개선 제안',
                  subtitle: '더 나은 서비스를 위한 아이디어',
                  icon: Icons.lightbulb_rounded,
                  iconColor: const Color(0xFFFFB347),
                  targetPage: const SuggestionPage(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SupportGridCard(
                  title: '자주 묻는 질문',
                  subtitle: '가장 많이 하는 질문을 모아봤어요',
                  icon: Icons.question_answer_rounded,
                  iconColor: const Color(0xFF5AB6FF),
                  targetPage: const FaqPage(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _SupportGridCard(
                  title: '1:1 문의하기',
                  subtitle: '상세한 상담이 필요하신가요?',
                  icon: Icons.headset_mic_rounded,
                  iconColor: const Color(0xFFA17FFF),
                  targetPage: const OneOnOneSupportPage(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SupportGridCard extends StatelessWidget {
  const _SupportGridCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.targetPage,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget targetPage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => targetPage,
          ),
        );
      },
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      height: 1.3,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportRow extends StatelessWidget {
  const _SupportRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.targetPage,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget targetPage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => targetPage,
          ),
        );
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF304255),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF243244),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF5C6B7A),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: Color(0xFF304255),
          ),
        ],
      ),
    );
  }
}

/// 간단한 고객지원 하위 페이지 (문구만 표시)
class SimpleSupportPage extends StatelessWidget {
  const SimpleSupportPage({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

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
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

