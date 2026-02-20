import 'package:clubal_app/core/utils/app_dialogs.dart';
import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/core/widgets/glass_card.dart';
import 'package:clubal_app/core/widgets/pressed_icon_action_button.dart';
import 'package:flutter/material.dart';

class BugReportPage extends StatefulWidget {
  const BugReportPage({super.key});

  @override
  State<BugReportPage> createState() => _BugReportPageState();
}

class _BugReportPageState extends State<BugReportPage> {
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _contentFocusNode = FocusNode();
  
  String? _selectedCategory;
  bool _isSubmitting = false;

  final List<String> _categories = [
    '앱 멈춤 / 강제 종료',
    '화면 오류',
    '기능 미작동',
    '로그인/인증 문제',
    '기타',
  ];

  // 이미지 첨부 (UI 전용 Mock 데이터 - 실제 구현 시 이미지 피커 사용)
  final List<String> _mockImages = [];

  @override
  void dispose() {
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _submitReport() async {
    // 최소 검증: 유형 선택 + 내용 10자 이상
    if (_selectedCategory == null) {
      showMessageDialog(context, message: '제보 유형을 선택해주세요.', isError: true);
      return;
    }
    if (_contentController.text.trim().length < 10) {
      showMessageDialog(context, message: '제보 내용을 10자 이상 입력해주세요.', isError: true);
      FocusScope.of(context).requestFocus(_contentFocusNode);
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
                  color: const Color(0xFFE8F3FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF5D90F5),
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '제보가 완료되었습니다',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF243244),
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                '소중한 제보 감사합니다.\n빠르게 확인 후 개선하도록 하겠습니다.',
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
      showMessageDialog(context, message: '이미지는 최대 3장까지 첨부할 수 있습니다.', isError: true);
      return;
    }
    setState(() {
      _mockImages.add('mock_image_${DateTime.now().millisecondsSinceEpoch}');
    });
  }

  void _removeMockImage(int index) {
    setState(() {
      _mockImages.removeAt(index);
    });
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
                          if (_contentController.text.trim().isNotEmpty && !_isSubmitting) {
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
                        '제보하기',
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
                        // 안내 문구
                        Text(
                          '앱 사용 중 겪으신 불편함을 알려주세요.\n버그나 오류 현상을 상세히 적어주시면 큰 도움이 됩니다.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF455568),
                                height: 1.5,
                              ),
                        ),
                        const SizedBox(height: 24),

                        // 제보 유형 선택 (ChoiceChip)
                        Row(
                          children: [
                            Text(
                              '어떤 문제가 발생했나요?',
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
                              selectedColor: const Color(0xFF243244),
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

                        // 내용 입력 필드
                        Row(
                          children: [
                            Text(
                              '상세 내용을 적어주세요',
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
                        GlassCard(
                          child: TextField(
                            controller: _contentController,
                            focusNode: _contentFocusNode,
                            maxLines: 8,
                            minLines: 5,
                            maxLength: 500,
                            style: const TextStyle(
                              color: Color(0xFF243244),
                              height: 1.5,
                            ),
                            decoration: InputDecoration(
                              hintText: '예) 프로필 수정 화면에서 저장 버튼을 누르면 앱이 강제로 종료됩니다. 아이폰 15 프로를 사용 중입니다.',
                              hintStyle: TextStyle(
                                color: const Color(0xFF304255).withOpacity(0.4),
                                height: 1.5,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(12),
                              counterStyle: TextStyle(
                                color: const Color(0xFF304255).withOpacity(0.6),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 이미지 첨부
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '스크린샷 첨부 (선택)',
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
                                          _removeMockImage(index);
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
                      onPressed: _isSubmitting ? null : _submitReport,
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
                              '제보 보내기',
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
    );
  }
}
