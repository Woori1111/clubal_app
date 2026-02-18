import 'dart:ui';

import 'package:flutter/material.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.userName,
    required this.userProfileImageUrl,
    required this.title,
    this.minHeight,
    this.maxHeight,
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
  final double? minHeight;
  final double? maxHeight;
  final String? location;
  final String? date;
  final int? viewCount;
  final int likeCount;
  final int commentCount;
  final String? imageUrl;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.likeCount;
  }

  int _calculateTextLines(String text, double maxWidth, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: null,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: maxWidth);
    return textPainter.computeLineMetrics().length;
  }

  @override
  Widget build(BuildContext context) {
    // 텍스트 줄 수 계산
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: const Color(0xFFF5FCFF),
      fontWeight: FontWeight.w500,
    ) ?? const TextStyle();
    
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 48 - 32;
    final imageWidth = widget.imageUrl != null ? 112 : 0;
    final titleLines = _calculateTextLines(widget.title, cardWidth - imageWidth, textStyle);
    
    // 제목만으로 높이 판단 (세부정보는 우측 열로 이동)
    final shouldUseMinHeight = titleLines <= 3;
    
    final calculatedMinHeight = (widget.minHeight ?? 0);
    final safeMinHeight = calculatedMinHeight < 120 ? 120.0 : calculatedMinHeight;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          constraints: BoxConstraints(
            minHeight: shouldUseMinHeight ? safeMinHeight : 0,
            maxHeight: widget.maxHeight ?? double.infinity,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x55FFFFFF), width: 1.2),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0x4DF3FAFF), Color(0x33A7B7FF)],
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: shouldUseMinHeight
              ? _buildFixedHeightLayout(context)
              : _buildFlexibleLayout(context),
        ),
      ),
    );
  }

  Widget _buildFixedHeightLayout(BuildContext context) {
    const detailStyle = TextStyle(color: Color(0xB3DCEAFF), fontSize: 12);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        // 프로필 영역
        Row(
          children: [
            ClipOval(
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0x33FFFFFF),
                  shape: BoxShape.circle,
                ),
                child: widget.userProfileImageUrl != null
                    ? Image.network(
                        widget.userProfileImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person_rounded,
                            color: Color(0xB3DCEAFF),
                            size: 18,
                          );
                        },
                      )
                    : const Icon(
                        Icons.person_rounded,
                        color: Color(0xB3DCEAFF),
                        size: 18,
                      ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              widget.userName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFE9F6FF),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 제목 + 사진 (사진은 위쪽 정렬)
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFF5FCFF),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        maxLines: null,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.imageUrl != null) ...[
                const SizedBox(width: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 108,
                    height: 108,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0x33FFFFFF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.network(
                        widget.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_rounded,
                            color: Color(0xB3DCEAFF),
                            size: 32,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        // 하단: 좌측(위치/시간/조회수) + 우측(좋아요/댓글)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 좌측: 위치, 시간, 조회수
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.location != null) ...[
                  const Icon(Icons.location_on_rounded, size: 12, color: Color(0xB3DCEAFF)),
                  const SizedBox(width: 2),
                  Text(widget.location!, style: detailStyle, overflow: TextOverflow.ellipsis),
                  const SizedBox(width: 8),
                ],
                if (widget.date != null) ...[
                  const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xB3DCEAFF)),
                  const SizedBox(width: 2),
                  Text(widget.date!, style: detailStyle, overflow: TextOverflow.ellipsis),
                  const SizedBox(width: 8),
                ],
                if (widget.viewCount != null) ...[
                  const Icon(Icons.visibility_rounded, size: 12, color: Color(0xB3DCEAFF)),
                  const SizedBox(width: 2),
                  Text('${widget.viewCount}', style: detailStyle),
                ],
              ],
            ),
            // 우측: 좋아요, 댓글
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _likeCount++),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.favorite_border_rounded,
                        size: 18,
                        color: Color(0xB3DCEAFF),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '$_likeCount',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xB3DCEAFF),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 18,
                      color: Color(0xB3DCEAFF),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${widget.commentCount}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xB3DCEAFF),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFlexibleLayout(BuildContext context) {
    const detailStyle = TextStyle(color: Color(0xB3DCEAFF), fontSize: 12);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            ClipOval(
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0x33FFFFFF),
                  shape: BoxShape.circle,
                ),
                child: widget.userProfileImageUrl != null
                    ? Image.network(
                        widget.userProfileImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person_rounded,
                            color: Color(0xB3DCEAFF),
                            size: 18,
                          );
                        },
                      )
                    : const Icon(
                        Icons.person_rounded,
                        color: Color(0xB3DCEAFF),
                        size: 18,
                      ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              widget.userName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFE9F6FF),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFF5FCFF),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: null,
                    overflow: TextOverflow.clip,
                  ),
                ],
              ),
            ),
            if (widget.imageUrl != null) ...[
              const SizedBox(width: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 108,
                  height: 108,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0x33FFFFFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.network(
                      widget.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image_rounded,
                          color: Color(0xB3DCEAFF),
                          size: 32,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        // 하단: 좌측(위치/시간/조회수) + 우측(좋아요/댓글)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 좌측: 위치, 시간, 조회수
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.location != null) ...[
                  const Icon(Icons.location_on_rounded, size: 12, color: Color(0xB3DCEAFF)),
                  const SizedBox(width: 2),
                  Text(widget.location!, style: detailStyle, overflow: TextOverflow.ellipsis),
                  const SizedBox(width: 8),
                ],
                if (widget.date != null) ...[
                  const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xB3DCEAFF)),
                  const SizedBox(width: 2),
                  Text(widget.date!, style: detailStyle, overflow: TextOverflow.ellipsis),
                  const SizedBox(width: 8),
                ],
                if (widget.viewCount != null) ...[
                  const Icon(Icons.visibility_rounded, size: 12, color: Color(0xB3DCEAFF)),
                  const SizedBox(width: 2),
                  Text('${widget.viewCount}', style: detailStyle),
                ],
              ],
            ),
            // 우측: 좋아요, 댓글
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _likeCount++),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.favorite_border_rounded,
                        size: 18,
                        color: Color(0xB3DCEAFF),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '$_likeCount',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xB3DCEAFF),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 18,
                      color: Color(0xB3DCEAFF),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${widget.commentCount}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xB3DCEAFF),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
