import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/core/widgets/glass_card.dart';
import 'package:clubal_app/core/widgets/pressed_icon_action_button.dart';
import 'package:flutter/material.dart';

class OneOnOneSupportPage extends StatefulWidget {
  const OneOnOneSupportPage({super.key});

  @override
  State<OneOnOneSupportPage> createState() => _OneOnOneSupportPageState();
}

class _OneOnOneSupportPageState extends State<OneOnOneSupportPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _quickHelpCategories = [
    {'icon': Icons.lock_person_rounded, 'label': '계정 / 로그인', 'color': Color(0xFF5AB6FF)},
    {'icon': Icons.receipt_long_rounded, 'label': '결제 / 환불', 'color': Color(0xFFFFB347)},
    {'icon': Icons.favorite_rounded, 'label': '모임 / 매칭', 'color': Color(0xFFFF6B6B)},
    {'icon': Icons.gavel_rounded, 'label': '신고 / 차단', 'color': Color(0xFFA17FFF)},
    {'icon': Icons.more_horiz_rounded, 'label': '기타 문의', 'color': Color(0xFF42E695)},
  ];

  final List<Map<String, String>> _topFaqs = [
    {'q': '로그인이 갑자기 안 돼요', 'a': '앱을 완전히 종료 후 다시 실행해 보시거나, 비밀번호 재설정을 진행해 주세요.'},
    {'q': '결제 환불은 어떻게 하나요?', 'a': '1:1 문의를 통해 결제 영수증 번호를 남겨주시면 환불 규정에 따라 처리해 드립니다.'},
    {'q': '모임 매칭이 잘 안 잡혀요', 'a': '프로필 사진이나 자기소개를 상세히 적어주시면 매칭 확률이 훨씬 올라갑니다.'},
    {'q': '상대방을 차단하고 싶어요', 'a': '상대방 프로필 우측 상단의 [:] 메뉴에서 차단하기를 선택하실 수 있습니다.'},
    {'q': '탈퇴는 어떻게 하나요?', 'a': '설정 > 계정 관리 > 계정 삭제 메뉴를 통해 탈퇴하실 수 있습니다.'},
  ];

  void _showInquiryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _InquiryBottomSheet(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const ClubalBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroSection(context),
                          const SizedBox(height: 32),
                          _buildQuickHelpSection(context),
                          const SizedBox(height: 32),
                          _buildAiHelpSection(context),
                          const SizedBox(height: 32),
                          _buildTopFaqSection(context),
                          const SizedBox(height: 120), // Bottom padding for CTA
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Sticky CTA
          Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: _buildStickyCta(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                '고객센터',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          // 이전 문의 내역 버튼
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('이전 문의 내역을 불러옵니다.')),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '나의 문의 내역',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '무엇을 도와드릴까요?',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: '예: "로그인이 안 돼요", "환불은 어떻게 하나요?"',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontSize: 14,
              ),
              prefixIcon: Icon(Icons.search_rounded, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickHelpSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 도움말',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _quickHelpCategories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final cat = _quickHelpCategories[index];
              return _QuickHelpCard(
                icon: cat['icon'] as IconData,
                label: cat['label'] as String,
                color: cat['color'] as Color,
                onTap: () {
                  // 해당 카테고리 FAQ로 스크롤/이동 로직 등 (현재는 안내용)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${cat['label']} 도움말로 이동합니다.')),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAiHelpSection(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI 챗봇에게 바로 물어보기',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '간단한 질문은 AI가 3초 안에 답변해 드립니다.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onSurface),
          ],
        ),
      ),
    );
  }

  Widget _buildTopFaqSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '자주 묻는 질문',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            TextButton(
              onPressed: () {}, // 전체 FAQ 페이지로 이동
              child: Text(
                '더 보기',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._topFaqs.map((faq) => _FaqAccordionItem(question: faq['q']!, answer: faq['a']!)).toList(),
      ],
    );
  }

  Widget _buildStickyCta(BuildContext context) {
    return GestureDetector(
      onTap: _showInquiryModal,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Theme.of(context).colorScheme.primary,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.edit_document, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Text(
              '해결되지 않았나요? 1:1 문의하기',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickHelpCard extends StatelessWidget {
  const _QuickHelpCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqAccordionItem extends StatelessWidget {
  const _FaqAccordionItem({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: Theme.of(context).colorScheme.onSurface,
          collapsedIconColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          title: Text(
            'Q. $question',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  answer,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                        height: 1.5,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 1:1 문의 폼을 담은 BottomSheet
class _InquiryBottomSheet extends StatefulWidget {
  const _InquiryBottomSheet();

  @override
  State<_InquiryBottomSheet> createState() => _InquiryBottomSheetState();
}

class _InquiryBottomSheetState extends State<_InquiryBottomSheet> {
  final TextEditingController _contentController = TextEditingController();
  String? _selectedCategory;
  final List<String> _categories = ['계정/로그인', '결제/환불', '매칭 문제', '신고/차단', '기타'];
  bool _isSubmitting = false;

  void _submit() async {
    if (_selectedCategory == null || _contentController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1)); // Mock Network Call
    if (!mounted) return;

    setState(() => _isSubmitting = false);
    Navigator.of(context).pop(); // Close BottomSheet
    
    // Show success dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('문의가 접수되었습니다 🎉'),
        content: const Text('담당자가 확인 후 영업일 기준 24시간 내에 답변해 드리겠습니다. 이전 문의 내역에서 상태를 확인할 수 있습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                '1:1 문의 접수',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '예상 답변 시간: 약 2~4시간 이내',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: '문의 유형',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),
              const SizedBox(height: 16),
              // Content Input
              TextField(
                controller: _contentController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: '자세한 문제 상황을 알려주시면 더욱 빠르게 도움을 드릴 수 있습니다.',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Image Attach Mock
              Row(
                children: [
                  Icon(Icons.image_outlined, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                  const SizedBox(width: 8),
                  Text(
                    '스크린샷 첨부 (선택)',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Submit Button
              ElevatedButton(
                onPressed: (_selectedCategory != null && _contentController.text.trim().isNotEmpty && !_isSubmitting)
                    ? _submit
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('문의 보내기', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
