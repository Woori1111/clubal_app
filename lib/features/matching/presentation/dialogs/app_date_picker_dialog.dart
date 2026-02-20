import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 날짜·시간 휠 피커 다이얼로그 (테마 색 적용)
class AppDatePickerDialog extends StatefulWidget {
  const AppDatePickerDialog({
    super.key,
    required this.initialDate,
    required this.minDate,
    required this.maxDate,
  });

  final DateTime initialDate;
  final DateTime minDate;
  final DateTime maxDate;

  @override
  State<AppDatePickerDialog> createState() => _AppDatePickerDialogState();
}

class _AppDatePickerDialogState extends State<AppDatePickerDialog> {
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initialDate.isBefore(widget.minDate)
        ? widget.minDate
        : widget.initialDate.isAfter(widget.maxDate)
            ? widget.maxDate
            : widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onSurface = colorScheme.onSurface;
    final availableDays = _buildDateRange(widget.minDate, widget.maxDate);
    final selectedDayIndex = availableDays.indexWhere(
      (day) =>
          day.year == _selectedDateTime.year &&
          day.month == _selectedDateTime.month &&
          day.day == _selectedDateTime.day,
    );
    final dayIndex = selectedDayIndex < 0 ? 0 : selectedDayIndex;
    final hourIndex = _selectedDateTime.hour.clamp(0, 23);

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  '날짜 선택',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: onSurface,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(_selectedDateTime),
                  child: Text(
                    '완료',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 176,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CupertinoPicker(
                      itemExtent: 38,
                      magnification: 1.06,
                      useMagnifier: true,
                      scrollController: FixedExtentScrollController(
                        initialItem: dayIndex,
                      ),
                      onSelectedItemChanged: (index) {
                        final selected = availableDays[index];
                        setState(() {
                          _selectedDateTime = DateTime(
                            selected.year,
                            selected.month,
                            selected.day,
                            _selectedDateTime.hour,
                          );
                        });
                      },
                      children: availableDays
                          .map(
                            (day) => Center(
                              child: Text(
                                '${day.month}월 ${day.day}일',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: onSurface),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 38,
                      magnification: 1.06,
                      useMagnifier: true,
                      scrollController: FixedExtentScrollController(
                        initialItem: hourIndex,
                      ),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedDateTime = DateTime(
                            _selectedDateTime.year,
                            _selectedDateTime.month,
                            _selectedDateTime.day,
                            index,
                          );
                        });
                      },
                      children: List.generate(
                        24,
                        (hour) => Center(
                          child: Text(
                            '${hour.toString().padLeft(2, '0')}시',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: onSurface),
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
    );
  }

  List<DateTime> _buildDateRange(DateTime start, DateTime end) {
    final result = <DateTime>[];
    var cursor = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    while (!cursor.isAfter(last)) {
      result.add(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }
    return result;
  }
}
