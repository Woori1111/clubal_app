import 'dart:ui';

import 'package:clubal_app/core/theme/app_glass_styles.dart';
import 'package:clubal_app/features/home/widgets/post_card.dart';
import 'package:flutter/material.dart';

/// 커뮤니티 인기글 목록 (커뮤니티 탭과 동일한 구조)
const List<Map<String, Object?>> _popularPostsData = [
  {
    'userName': '김민수',
    'userProfileImageUrl': null,
    'title': '오늘 클럽 가실 분 구해요!',
    'location': '강남',
    'date': '2시간 전',
    'viewCount': 24,
    'likeCount': 3,
    'commentCount': 5,
    'imageUrl': null,
  },
  {
    'userName': '이지은',
    'userProfileImageUrl': null,
    'title': '주말에 함께 갈 사람 있나요? 정말 재밌는 클럽이에요!',
    'location': '홍대',
    'date': '5시간 전',
    'viewCount': 48,
    'likeCount': 7,
    'commentCount': 12,
    'imageUrl': 'https://picsum.photos/200/200?random=1',
  },
  {
    'userName': '박준호',
    'userProfileImageUrl': null,
    'title': '클럽 테이블비 1/N으로 나눠요',
    'location': '압구정',
    'date': '1일 전',
    'viewCount': 67,
    'likeCount': 2,
    'commentCount': 8,
    'imageUrl': null,
  },
];

class HomeTabView extends StatefulWidget {
  const HomeTabView({
    super.key,
    this.scrollController,
    this.onMatchTap,
    this.onChatTap,
    this.onExtra1Tap,
    this.onExtra2Tap,
    this.userName = '유저별명',
    this.profileImageUrl,
    this.hasChatNotification = false,
    this.chatRoomName,
    this.chatRoomImageUrl,
  });

  final ScrollController? scrollController;
  final VoidCallback? onMatchTap;
  final VoidCallback? onChatTap;
  final VoidCallback? onExtra1Tap;
  final VoidCallback? onExtra2Tap;
  final String userName;
  final String? profileImageUrl;
  final bool hasChatNotification;
  final String? chatRoomName;
  final String? chatRoomImageUrl;

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView(
        controller: widget.scrollController,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 100),
        children: [
          // 상단: 왼쪽 유저 프로필(정사각) | 오른쪽 버튼 4개(프로필 4등분 크기, 2x2)
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 10.0;
              const innerGap = 8.0;
              final w = constraints.maxWidth;
              final profileSide = (w - gap) / 2;
              final btnSide = (profileSide - innerGap) / 2;
              return SizedBox(
                height: profileSide,
                child: Row(
                  children: [
                    // 왼쪽: 유저 프로필 카드 (정사각)
                    SizedBox(
                      width: profileSide,
                      height: profileSide,
                      child: _HomeGlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(flex: 1),
                            CircleAvatar(
                              radius: profileSide * 0.34,
                              backgroundColor: colorScheme.surfaceContainerHighest,
                              foregroundColor: colorScheme.onSurface,
                              backgroundImage: widget.profileImageUrl != null &&
                                      widget.profileImageUrl!.isNotEmpty
                                  ? NetworkImage(widget.profileImageUrl!)
                                  : null,
                              child: widget.profileImageUrl == null ||
                                      widget.profileImageUrl!.isEmpty
                                  ? Text(
                                      widget.userName.isNotEmpty
                                          ? widget.userName[0].toUpperCase()
                                          : '?',
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    )
                                  : null,
                            ),
                            const Spacer(flex: 2),
                            Text(
                              widget.userName,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            const Spacer(flex: 1),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: gap),
                    // 오른쪽: 매치·채팅·버튼1·버튼2 (2x2, 각 프로필 4등분 크기)
                    SizedBox(
                      width: profileSide,
                      height: profileSide,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: btnSide,
                                height: btnSide,
                                child: _HomeGlassCard(
                                  padding: const EdgeInsets.all(6),
                                  onTap: widget.onMatchTap,
                                  child: Center(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.people_alt_rounded,
                                            size: 22,
                                            color: colorScheme.onSurface,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '매치',
                                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: colorScheme.onSurface,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: innerGap),
                              SizedBox(
                                width: btnSide,
                                height: btnSide,
                                child: _HomeGlassCard(
                                  padding: const EdgeInsets.all(6),
                                  onTap: widget.onChatTap,
                                  child: widget.hasChatNotification &&
                                          widget.chatRoomName != null &&
                                          widget.chatRoomName!.isNotEmpty
                                      ? Center(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CircleAvatar(
                                                  radius: btnSide * 0.22,
                                                  backgroundColor: colorScheme.surfaceContainerHighest,
                                                  foregroundColor: colorScheme.onSurface,
                                                  backgroundImage: widget.chatRoomImageUrl != null &&
                                                          widget.chatRoomImageUrl!.isNotEmpty
                                                      ? NetworkImage(widget.chatRoomImageUrl!)
                                                      : null,
                                                  child: widget.chatRoomImageUrl == null ||
                                                          widget.chatRoomImageUrl!.isEmpty
                                                      ? Text(
                                                          widget.chatRoomName![0].toUpperCase(),
                                                          style: TextStyle(
                                                            fontSize: btnSide * 0.22,
                                                            fontWeight: FontWeight.w700,
                                                          ),
                                                        )
                                                      : null,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  widget.chatRoomName!,
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                        fontWeight: FontWeight.w600,
                                                        color: colorScheme.onSurface,
                                                      ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Center(
                                          child: Icon(
                                            Icons.chat_bubble_outline_rounded,
                                            size: 22,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: innerGap),
                          Row(
                            children: [
                              SizedBox(
                                width: btnSide,
                                height: btnSide,
                                child: _HomeGlassCard(
                                  padding: const EdgeInsets.all(6),
                                  onTap: widget.onExtra1Tap,
                                  child: Center(
                                    child: Icon(
                                      Icons.notifications_outlined,
                                      size: 22,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: innerGap),
                              SizedBox(
                                width: btnSide,
                                height: btnSide,
                                child: _HomeGlassCard(
                                  padding: const EdgeInsets.all(6),
                                  onTap: widget.onExtra2Tap,
                                  child: Center(
                                    child: Icon(
                                      Icons.settings_outlined,
                                      size: 22,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          // 광고배너 (흔히 쓰는 비율: 5:2)
          AspectRatio(
            aspectRatio: 5 / 2,
            child: _HomeGlassCard(
              padding: EdgeInsets.zero,
              child: Center(
                child: Text(
                  '광고배너',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // 공지: 왼쪽 이모티콘 + 텍스트 (외곽선·배경 투명)
          _HomeGlassCard(
            showBorder: false,
            transparentBackground: true,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Icon(
                  Icons.campaign_rounded,
                  size: 22,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '공지 내용을 입력하세요.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.3,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // 커뮤니티 인기글 (커뮤니티 탭과 동일한 PostCard 사용)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              '커뮤니티 인기글',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(height: 10),
          ..._popularPostsData.map((post) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PostCard(
                  userName: post['userName'] as String,
                  userProfileImageUrl: post['userProfileImageUrl'] as String?,
                  title: post['title'] as String,
                  location: post['location'] as String?,
                  date: post['date'] as String?,
                  viewCount: post['viewCount'] as int?,
                  likeCount: post['likeCount'] as int? ?? 0,
                  commentCount: post['commentCount'] as int? ?? 0,
                  imageUrl: post['imageUrl'] as String?,
                ),
              )),
        ],
      ),
    );
  }
}

/// 홈 전용 글라스 카드 (매칭 화면 스타일 통일)
class _HomeGlassCard extends StatelessWidget {
  const _HomeGlassCard({
    required this.child,
    this.padding,
    this.onTap,
    this.showBorder = true,
    this.transparentBackground = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool showBorder;
  final bool transparentBackground;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final BoxDecoration decoration;
    if (transparentBackground) {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
      );
    } else if (showBorder) {
      decoration = AppGlassStyles.card(radius: 16, isDark: isDark);
    } else {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0x1AFFFFFF), Color(0x0DFFFFFF)]
              : const [Color(0x99FFFFFF), Color(0x33FFFFFF)],
        ),
      );
    }
    Widget inner = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: decoration,
      child: child,
    );
    if (!transparentBackground) {
      inner = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: inner,
      );
    }
    final content = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: inner,
    );
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }
    return content;
  }
}
