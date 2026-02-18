import 'package:clubal_app/core/widgets/glass_card.dart';
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
          GlassCard(
            child: Column(
              children: const [
                _SupportRow(
                  title: '고객센터',
                  subtitle: '문의 및 상담을 남겨요',
                  targetPage: _SimpleSupportPage(
                    title: '고객센터',
                    description: '고객센터로 문의를 남길 수 있는 화면입니다.',
                  ),
                ),
                SizedBox(height: 14),
                _SupportRow(
                  title: '개선할 점',
                  subtitle: '더 좋은 서비스를 위해 의견을 보내주세요',
                  targetPage: _SimpleSupportPage(
                    title: '개선할 점',
                    description: '서비스 개선을 위한 의견을 남길 수 있는 화면입니다.',
                  ),
                ),
                SizedBox(height: 14),
                _SupportRow(
                  title: '제보하기',
                  subtitle: '이상 행동·버그 등을 제보해요',
                  targetPage: _SimpleSupportPage(
                    title: '제보하기',
                    description: '문제 상황을 제보할 수 있는 화면입니다.',
                  ),
                ),
                SizedBox(height: 14),
                _SupportRow(
                  title: '가장 많이 하는 질문',
                  subtitle: '자주 묻는 질문을 모아봤어요',
                  targetPage: _SimpleSupportPage(
                    title: '가장 많이 하는 질문',
                    description: '자주 묻는 질문을 모아둔 화면입니다.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportRow extends StatelessWidget {
  const _SupportRow({
    required this.title,
    required this.subtitle,
    required this.targetPage,
  });

  final String title;
  final String subtitle;
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
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}

/// 간단한 고객지원 하위 페이지 (문구만 표시)
class _SimpleSupportPage extends StatelessWidget {
  const _SimpleSupportPage({
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
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

