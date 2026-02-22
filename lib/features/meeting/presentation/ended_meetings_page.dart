import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/core/widgets/clubal_full_body.dart';
import 'package:clubal_app/core/widgets/glass_card.dart';
import 'package:clubal_app/core/widgets/pressed_icon_action_button.dart';
import 'package:clubal_app/features/meeting/data/meeting_model.dart';
import 'package:clubal_app/features/meeting/data/mock_meeting_repository.dart';
import 'package:flutter/material.dart';

/// 종료된 모임 목록 페이지.
/// status == "ended" 모임만 표시. 카드 오른쪽에 날짜 표시.
class EndedMeetingsPage extends StatelessWidget {
  const EndedMeetingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = MockMeetingRepository.instance;

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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          PressedIconActionButton(
                            icon: Icons.arrow_back_rounded,
                            tooltip: '뒤로가기',
                            onTap: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '종료된 모임',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: FutureBuilder<List<Meeting>>(
                          future: repository.fetchMeetingsByStatus('ended'),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  '목록을 불러올 수 없습니다.',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.error,
                                      ),
                                ),
                              );
                            }
                            final list = snapshot.data ?? [];
                            if (list.isEmpty) {
                              return Center(
                                child: Text(
                                  '종료된 모임이 없습니다.',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              );
                            }
                            return ListView.separated(
                              itemCount: list.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final m = list[index];
                                return _EndedMeetingListTile(
                                  title: m.title,
                                  date: m.date,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EndedMeetingListTile extends StatelessWidget {
  const _EndedMeetingListTile({
    required this.title,
    required this.date,
  });

  final String title;
  final DateTime date;

  String _formatDate(DateTime d) {
    return '${d.month}월 ${d.day}일';
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
            Text(
              _formatDate(date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
