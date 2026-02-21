import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 날짜(월·일) 휠 피커 하단 시트. 시간 선택 없음.
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

  /// 하단 시트로 열어서 선택한 날짜(시간 0:00) 반환
  static Future<DateTime?> showModal(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime minDate,
    required DateTime maxDate,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AppDatePickerDialog(
        initialDate: initialDate,
        minDate: minDate,
        maxDate: maxDate,
      ),
    );
  }

  @override
  State<AppDatePickerDialog> createState() => _AppDatePickerDialogState();
}

class _AppDatePickerDialogState extends State<AppDatePickerDialog> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final initial = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
    );
    final min = DateTime(widget.minDate.year, widget.minDate.month, widget.minDate.day);
    final max = DateTime(widget.maxDate.year, widget.maxDate.month, widget.maxDate.day);
    if (initial.isBefore(min)) {
      _selectedDate = min;
    } else if (initial.isAfter(max)) {
      _selectedDate = max;
    } else {
      _selectedDate = initial;
    }
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onSurface = colorScheme.onSurface;
    final availableDays = _buildDateRange(widget.minDate, widget.maxDate);
    final selectedIndex = availableDays.indexWhere(
      (d) =>
          d.year == _selectedDate.year &&
          d.month == _selectedDate.month &&
          d.day == _selectedDate.day,
    );
    final index = selectedIndex < 0 ? 0 : selectedIndex;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
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
                    onPressed: () => Navigator.of(context).pop(
                      DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day),
                    ),
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
                height: 200,
                child: CupertinoPicker(
                  itemExtent: 44,
                  magnification: 1.08,
                  useMagnifier: true,
                  scrollController: FixedExtentScrollController(initialItem: index),
                  onSelectedItemChanged: (i) {
                    final d = availableDays[i];
                    setState(() => _selectedDate = d);
                  },
                  children: availableDays
                      .map(
                        (day) => Center(
                          child: Text(
                            '${day.month}월 ${day.day}일',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: onSurface,
                                ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
