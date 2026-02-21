import 'package:clubal_app/features/menu/dummy/menu_dummy_data.dart';
import 'package:clubal_app/features/menu/widgets/activity_row_item.dart';
import 'package:clubal_app/features/menu/widgets/activity_section_card.dart';
import 'package:flutter/material.dart';

/// 내 커뮤니티 활동 섹션
class CommunityActivitySection extends StatelessWidget {
  const CommunityActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return ActivitySectionCard(
      title: '내 커뮤니티 활동',
      icon: Icons.forum_outlined,
      child: Column(
        children: [
          ActivityRowItem(
            label: '내가 작성한 글',
            value: '${MenuDummyData.myPosts}개',
          ),
          ActivityRowItem(
            label: '댓글 단 글',
            value: '${MenuDummyData.commentedPosts}개',
          ),
          ActivityRowItem(
            label: '좋아요 한 글',
            value: '${MenuDummyData.likedPosts}개',
          ),
        ],
      ),
    );
  }
}
