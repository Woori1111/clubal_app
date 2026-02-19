import 'dart:ui';

import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/core/widgets/pressed_icon_action_button.dart';
import 'package:flutter/material.dart';

/// 커뮤니티 포스트 상세 정보를 보여주는 페이지.
class PostDetailPage extends StatefulWidget {
  const PostDetailPage({
    super.key,
    required this.userName,
    this.userProfileImageUrl,
    required this.title,
    this.content,
    this.location,
    this.date,
    this.viewCount,
    this.likeCount = 0,
    this.commentCount = 0,
    this.imageUrl,
  });

  final String userName;
  final String? userProfileImageUrl;
  final String title;
  final String? content;
  final String? location;
  final String? date;
  final int? viewCount;
  final int likeCount;
  final int commentCount;
  final String? imageUrl;

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.likeCount;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    const detailStyle = TextStyle(color: Color(0xFF2D3E54), fontSize: 14);

    return Scaffold(
      body: Stack(
        children: [
          const ClubalBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
                  child: Row(
                    children: [
                      PressedIconActionButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        tooltip: '뒤로가기',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '글 상세',
                          style: theme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0x55FFFFFF),
                              width: 1.2,
                            ),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0x4DF3FAFF),
                                Color(0x33A7B7FF),
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 작성자
                              Row(
                                children: [
                                  ClipOval(
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        color: Color(0x33FFFFFF),
                                        shape: BoxShape.circle,
                                      ),
                                      child: widget.userProfileImageUrl != null
                                          ? Image.network(
                                              widget.userProfileImageUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                Icons.person_rounded,
                                                color: Colors.black,
                                                size: 22,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.person_rounded,
                                              color: Colors.black,
                                              size: 22,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    widget.userName,
                                    style: theme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // 제목
                              Text(
                                widget.title,
                                style: theme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // 본문 (있으면 표시, 없으면 제목으로 대체)
                              Text(
                                widget.content ?? widget.title,
                                style: theme.bodyLarge?.copyWith(
                                  color: const Color(0xFF2D3E54),
                                  height: 1.5,
                                ),
                              ),
                              if (widget.imageUrl != null) ...[
                                const SizedBox(height: 16),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: AspectRatio(
                                    aspectRatio: 3 / 4,
                                    child: Image.network(
                                      widget.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: const Color(0x33FFFFFF),
                                        child: const Icon(
                                          Icons.image_rounded,
                                          size: 48,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              // 위치, 날짜, 조회수
                              Wrap(
                                spacing: 16,
                                runSpacing: 8,
                                children: [
                                  if (widget.location != null)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.location_on_rounded,
                                          size: 18,
                                          color: Color(0xFF2D3E54),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          widget.location!,
                                          style: detailStyle,
                                        ),
                                      ],
                                    ),
                                  if (widget.date != null)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.calendar_today_rounded,
                                          size: 18,
                                          color: Color(0xFF2D3E54),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          widget.date!,
                                          style: detailStyle,
                                        ),
                                      ],
                                    ),
                                  if (widget.viewCount != null)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.visibility_rounded,
                                          size: 18,
                                          color: Color(0xFF2D3E54),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '조회 ${widget.viewCount}',
                                          style: detailStyle,
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(height: 1),
                              const SizedBox(height: 12),
                              // 좋아요, 댓글
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () =>
                                        setState(() => _likeCount++),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.favorite_border_rounded,
                                          size: 22,
                                          color: Color(0xFF2D3E54),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '$_likeCount',
                                          style: detailStyle.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        size: 22,
                                        color: Color(0xFF2D3E54),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${widget.commentCount}',
                                        style: detailStyle.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
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
