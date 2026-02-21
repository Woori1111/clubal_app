import 'package:clubal_app/core/utils/app_dialogs.dart';
import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/core/widgets/clubal_full_body.dart';
import 'package:clubal_app/core/widgets/glass_card.dart';
import 'package:clubal_app/core/widgets/pressed_icon_action_button.dart';
import 'package:flutter/material.dart';

class SuggestionPage extends StatefulWidget {
  const SuggestionPage({super.key});

  @override
  State<SuggestionPage> createState() => _SuggestionPageState();
}

class _SuggestionPageState extends State<SuggestionPage> {
  final TextEditingController _problemController = TextEditingController();
  final TextEditingController _suggestionController = TextEditingController();
  final FocusNode _problemFocusNode = FocusNode();
  final FocusNode _suggestionFocusNode = FocusNode();
  
  String? _selectedCategory;
  bool _isSubmitting = false;

  final List<String> _categories = [
    '사용성 불편',
    '기능 부족',
    'UI/디자인',
    '흐름/구조',
    '있으면 좋겠는 기능',
    '기타',
  ];

  // 이미지 첨부 (UI 전용 Mock 데이터)
  final List<String> _mockImages = [];

  @override
  void dispose() {
    _problemController.dispose();
    _suggestionController.dispose();
    _problemFocusNode.dispose();
    _suggestionFocusNode.dispose();
    super.dispose();
  }

  void _submitSuggestion() async {
    // 최소 검증: 유형 선택
    if (_selectedCategory == null) {
      showMessageDialog(context, message: '개선 유형을 선택해주세요.', isError: true);
      return;
    }

    // 둘 중 하나라도 작성되었는지 확인
    if (_problemController.text.trim().isEmpty && _suggestionController.text.trim().isEmpty) {
      showMessageDialog(context, message: '불편했던 점이나 제안할 내용을 한 가지 이상 작성해주세요.', isError: true);
      FocusScope.of(context).requestFocus(_suggestionFocusNode);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // 서버 전송을 가정하여 1.5초 딜레이
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white.withOpacity(0.95),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFFFF7A8A),
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '소중한 의견 감사합니다!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF243244),
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                '보내주신 의견을 귀담아듣고\n더 멋진 클러벌을 만들어 갈게요.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5C6B7A),
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF243244),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop(); // 다이얼로그 닫기
                    Navigator.of(context).pop(); // 이전 페이지로 돌아가기
                  },
                  child: Text(
                    '확인',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addMockImage() {
    if (_mockImages.length >= 3) {
      showMessageDialog(context, message: '참고 이미지는 최대 3장까지 첨부할 수 있습니다.', isError: true);
      return;
    }
    setState(() {
      _mockImages.add('suggestion_image_${DateTime.now().millisecondsSinceEpoch}');
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) => wrapFullBody(
          context,
          Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(child: ClubalBackground()),
              ),
              SafeArea(
                child: Column(
              children: [
                // 1. 헤더 (고정)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Row(
                    children: [
                      PressedIconActionButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: '뒤로가기',
                        onTap: () {
                          // 작성 중인 내용이 있으면 경고 표시, 없으면 바로 닫기
                          if ((_problemController.text.trim().isNotEmpty || 
                               _suggestionController.text.trim().isNotEmpty) && !_isSubmitting) {
                            showDialog<void>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('작성을 취소하시겠어요?'),
                                content: const Text('작성 중인 내용은 저장되지 않습니다.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('아니오'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('네, 나갈게요', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '개선할 점',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),

                // 2. 폼 영역 (스크롤)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 상단 안내 문구 (자유롭고 긍정적인 톤)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.8)),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                '💡',
                                style: TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '이런 기능이 있다면 어떨까?\n이 부분이 조금 바뀌면 편할 텐데!\n회원님의 멋진 아이디어를 편하게 들려주세요.',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: const Color(0xFF243244),
                                        fontWeight: FontWeight.w600,
                                        height: 1.5,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // 개선 유형 선택 (ChoiceChip)
                        Row(
                          children: [
                            Text(
                              '어떤 점에 대해 이야기하고 싶으신가요?',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF243244),
                                  ),
                            ),
                            const Text(
                              ' *',
                              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _categories.map((category) {
                            final isSelected = _selectedCategory == category;
                            return ChoiceChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = selected ? category : null;
                                });
                              },
                              backgroundColor: Colors.white.withOpacity(0.5),
                              selectedColor: const Color(0xFF8BB5FF).withOpacity(0.8),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF304255),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected ? Colors.transparent : Colors.black12,
                                ),
                              ),
                              showCheckmark: false,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),

                        // 입력 필드 1: 불편했던 점
                        Text(
                          '앱을 쓰면서 불편했던 점이 있었나요?',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF243244),
                              ),
                        ),
                        const SizedBox(height: 12),
                        GlassCard(
                          child: TextField(
                            controller: _problemController,
                            focusNode: _problemFocusNode,
                            maxLines: 4,
                            minLines: 3,
                            style: const TextStyle(
                              color: Color(0xFF243244),
                              height: 1.5,
                            ),
                            decoration: InputDecoration(
                              hintText: '예) 글을 쓸 때 사진이 여러 장이면 순서 바꾸기가 너무 힘들어요.',
                              hintStyle: TextStyle(
                                color: const Color(0xFF304255).withOpacity(0.4),
                                height: 1.5,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 입력 필드 2: 이렇게 바뀌면 좋겠어요
                        Text(
                          '이렇게 바뀌면 더 좋을 것 같아요!',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF243244),
                              ),
                        ),
                        const SizedBox(height: 12),
                        GlassCard(
                          child: TextField(
                            controller: _suggestionController,
                            focusNode: _suggestionFocusNode,
                            maxLines: 4,
                            minLines: 3,
                            style: const TextStyle(
                              color: Color(0xFF243244),
                              height: 1.5,
                            ),
                            decoration: InputDecoration(
                              hintText: '예) 사진을 꾹 눌러서 드래그 앤 드롭으로 순서를 바꿀 수 있으면 훨씬 편할 것 같아요!',
                              hintStyle: TextStyle(
                                color: const Color(0xFF304255).withOpacity(0.4),
                                height: 1.5,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 참고 이미지 첨부
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '참고 이미지 (선택)',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF243244),
                                  ),
                            ),
                            Text(
                              '${_mockImages.length} / 3',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF304255).withOpacity(0.6),
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 80,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              // 첨부 버튼
                              if (_mockImages.length < 3)
                                GestureDetector(
                                  onTap: _addMockImage,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFF304255).withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate_rounded,
                                          color: const Color(0xFF304255).withOpacity(0.6),
                                          size: 28,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '추가하기',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: const Color(0xFF304255).withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              
                              // 첨부된 이미지 목록 (Mock)
                              ...List.generate(_mockImages.length, (index) {
                                return Stack(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Icon(Icons.image, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 16,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _mockImages.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.close_rounded,
                                            color: Theme.of(context).colorScheme.onSurface,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 60), // 하단 여백
                      ],
                    ),
                  ),
                ),

                // 3. 하단 제출 버튼
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF243244),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _isSubmitting ? null : _submitSuggestion,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              '개선 제안 보내기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
    );
  }
}
