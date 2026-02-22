import 'package:clubal_app/core/theme/app_colors.dart';
import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/core/widgets/clubal_full_body.dart';
import 'package:clubal_app/core/widgets/glass_card.dart';
import 'package:clubal_app/core/widgets/pressed_icon_action_button.dart';
import 'package:clubal_app/features/meeting/data/meeting_model.dart';
import 'package:clubal_app/features/meeting/data/mock_meeting_repository.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// 예정된 모임 페이지.
/// status == "scheduled" 모임만 캘린더에 날짜별 표시.
/// 날짜 클릭 시 해당 날짜 모임 리스트 하단 표시.
class ScheduledMeetingsPage extends StatefulWidget {
  const ScheduledMeetingsPage({super.key});

  @override
  State<ScheduledMeetingsPage> createState() => _ScheduledMeetingsPageState();
}

class _ScheduledMeetingsPageState extends State<ScheduledMeetingsPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Meeting> _scheduledMeetings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadMeetings();
  }

  Future<void> _loadMeetings() async {
    final repo = MockMeetingRepository.instance;
    final list = await repo.fetchMeetingsByStatus('scheduled');
    if (mounted) {
      setState(() {
        _scheduledMeetings = list;
        _loading = false;
      });
    }
  }

  List<Meeting> _meetingsForDay(DateTime day) {
    return _scheduledMeetings.where((m) {
      return m.date.year == day.year &&
          m.date.month == day.month &&
          m.date.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedMeetings = _selectedDay != null
        ? _meetingsForDay(_selectedDay!)
        : <Meeting>[];

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
                              '예정된 모임',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: (isDark
                                    ? AppColors.glassBorderDark
                                    : AppColors.glassBorderLight)
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: (isDark
                                      ? AppColors.glassBorderDark
                                      : AppColors.glassBorderLight)
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          child: TableCalendar<Meeting>(
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: _focusedDay,
                            currentDay: DateTime.now(),
                            selectedDayPredicate: (day) =>
                                isSameDay(_selectedDay, day),
                            eventLoader: (day) => _meetingsForDay(day),
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                            },
                            onPageChanged: (focusedDay) {
                              setState(() => _focusedDay = focusedDay);
                            },
                            calendarStyle: CalendarStyle(
                              markerDecoration: BoxDecoration(
                                color: AppColors.brandPrimary,
                                shape: BoxShape.circle,
                              ),
                              todayDecoration: BoxDecoration(
                                color: AppColors.brandPrimary.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: BoxDecoration(
                                color: AppColors.brandPrimary,
                                shape: BoxShape.circle,
                              ),
                              outsideDaysVisible: false,
                            ),
                            headerStyle: HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _selectedDay != null
                            ? '${_selectedDay!.month}월 ${_selectedDay!.day}일 모임'
                            : '날짜를 선택하세요',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _loading
                            ? const Center(child: CircularProgressIndicator())
                            : selectedMeetings.isEmpty
                                ? Center(
                                    child: Text(
                                      _selectedDay != null
                                          ? '해당 날짜에 예정된 모임이 없습니다.'
                                          : '날짜를 선택해주세요.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: selectedMeetings.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final m = selectedMeetings[index];
                                      return _ScheduledMeetingTile(
                                        title: m.title,
                                        date: m.date,
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

class _ScheduledMeetingTile extends StatelessWidget {
  const _ScheduledMeetingTile({
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
