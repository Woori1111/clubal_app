import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/core/widgets/glass_card.dart';
import 'package:clubal_app/core/widgets/pressed_icon_action_button.dart';
import 'package:flutter/material.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

  final List<String> _categories = ['전체', '계정/로그인', '매칭', '결제/정산', '커뮤니티', '이용제재'];

  final List<Map<String, String>> _faqs = [
    {
      'category': '계정/로그인',
      'question': '비밀번호를 잊어버렸어요. 어떻게 찾나요?',
      'answer': '로그인 화면 하단의 "비밀번호 찾기"를 누르신 후, 가입하신 이메일 또는 휴대전화 번호를 입력하시면 비밀번호 재설정 안내를 보내드립니다.'
    },
    {
      'category': '계정/로그인',
      'question': '회원 탈퇴는 어떻게 진행하나요?',
      'answer': '설정 > 계정 관리 > 계정 삭제 메뉴를 통해 직접 탈퇴하실 수 있습니다. 탈퇴 시 일부 데이터는 복구할 수 없으니 유의해주세요.'
    },
    {
      'category': '매칭',
      'question': '매칭이 너무 안 잡혀요. 팁이 있나요?',
      'answer': '프로필 사진을 선명한 것으로 교체하고, 자기소개 글을 성의 있게 작성해 보세요. 또한 원하는 매칭 조건을 조금 넓게 설정하시면 매칭 확률이 올라갑니다.'
    },
    {
      'category': '매칭',
      'question': '매칭을 취소하면 패널티가 있나요?',
      'answer': '매칭 성사 후 10분 이내에 취소하는 경우에는 패널티가 없으나, 반복적인 취소 시 일시적인 매칭 제한이 발생할 수 있습니다.'
    },
    {
      'category': '결제/정산',
      'question': 'N분의 1 결제 내역은 어디서 볼 수 있나요?',
      'answer': '설정 > 결제/정산 메뉴로 이동하시면 최근 모임의 결제 및 정산 내역을 한눈에 확인하실 수 있습니다.'
    },
    {
      'category': '결제/정산',
      'question': '결제 수단은 어떻게 추가/변경하나요?',
      'answer': '결제/정산 화면에서 "결제 수단 관리" 버튼을 눌러 카드를 추가하거나 삭제하실 수 있습니다.'
    },
    {
      'category': '결제/정산',
      'question': '환불 규정이 궁금해요.',
      'answer': '이용 약관에 명시된 대로 결제 후 7일 이내, 유료 서비스를 이용하지 않으셨다면 전액 환불이 가능합니다. 고객센터로 문의해주세요.'
    },
    {
      'category': '커뮤니티',
      'question': '불쾌한 게시물이나 댓글을 발견했어요.',
      'answer': '해당 게시물 또는 댓글 우측의 [점 세 개(더보기)] 아이콘을 눌러 "신고하기"를 선택해 주시면 관리자가 검토 후 조치합니다.'
    },
    {
      'category': '이용제재',
      'question': '계정이 정지되었다고 나옵니다.',
      'answer': '운영 정책 위반 또는 다수의 신고 누적으로 인해 계정이 일시/영구 정지될 수 있습니다. 자세한 사유는 이메일로 안내해 드렸습니다.'
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 검색어 및 카테고리 필터링
    final filteredFaqs = _faqs.where((faq) {
      final matchesSearch = _searchQuery.isEmpty ||
          faq['question']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          faq['answer']!.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == null ||
          _selectedCategory == '전체' ||
          faq['category'] == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          const ClubalBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 헤더
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Row(
                    children: [
                      PressedIconActionButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: '뒤로가기',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '가장 많이 하는 질문',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
                
                // 검색창
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: '궁금한 점을 검색해보세요',
                        hintStyle: TextStyle(
                          color: const Color(0xFF243244).withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.6),
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: const Color(0xFF304255).withOpacity(0.8),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.cancel_rounded,
                                  size: 20,
                                  color: const Color(0xFF304255).withOpacity(0.6),
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 카테고리 칩
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category ||
                          (_selectedCategory == null && category == '전체');
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          backgroundColor: Colors.white.withOpacity(0.5),
                          selectedColor: const Color(0xFF8BB5FF),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF304255),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Colors.transparent),
                          ),
                          showCheckmark: false,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                
                // FAQ 리스트
                Expanded(
                  child: filteredFaqs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: const Color(0xFF304255).withOpacity(0.4),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '검색 결과가 없습니다.',
                                style: TextStyle(
                                  color: const Color(0xFF304255).withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          itemCount: filteredFaqs.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final faq = filteredFaqs[index];
                            return _FaqCard(
                              question: faq['question']!,
                              answer: faq['answer']!,
                              category: faq['category']!,
                            );
                          },
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

class _FaqCard extends StatefulWidget {
  final String question;
  final String answer;
  final String category;

  const _FaqCard({
    required this.question,
    required this.answer,
    required this.category,
  });

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          childrenPadding: const EdgeInsets.only(left: 12, right: 12, bottom: 16),
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '[${widget.category}]',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF5D90F5),
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.question,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF243244),
                    ),
              ),
            ],
          ),
          trailing: AnimatedRotation(
            turns: _isExpanded ? 0.5 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF304255),
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.55),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.answer,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF455568),
                      height: 1.5,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
