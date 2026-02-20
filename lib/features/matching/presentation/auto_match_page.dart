import 'package:clubal_app/features/matching/models/piece_room.dart';
import 'package:clubal_app/features/matching/presentation/dialogs/app_date_picker_dialog.dart';
import 'package:clubal_app/features/matching/presentation/place/place_selection.dart';
import 'package:clubal_app/features/matching/presentation/place/place_selection_page.dart';
import 'package:clubal_app/features/matching/presentation/widgets/confirm_button.dart';
import 'package:clubal_app/features/matching/presentation/widgets/matching_page_scaffold.dart';
import 'package:clubal_app/features/matching/presentation/widgets/option_chip.dart';
import 'package:flutter/material.dart';

class AutoMatchPage extends StatefulWidget {
  const AutoMatchPage({super.key});

  @override
  State<AutoMatchPage> createState() => _AutoMatchPageState();
}

class _AutoMatchPageState extends State<AutoMatchPage> {
  static const Color _brandColor = Color(0xFF2ECEF2);

  String _selectedDate = '';
  String _selectedPlace = '';

  Future<void> _onTapDate() async {
    final now = DateTime.now();
    final minDate = DateTime(now.year, now.month, now.day, now.hour);
    final maxDate = minDate.add(const Duration(days: 365));
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (_) => AppDatePickerDialog(
        initialDate: minDate,
        minDate: minDate,
        maxDate: maxDate,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate =
            '${picked.month}월 ${picked.day}일 ${picked.hour.toString().padLeft(2, '0')}시';
      });
    }
  }

  Future<void> _onTapPlace() async {
    final result = await Navigator.of(context).push<PlaceSelection>(
      MaterialPageRoute(builder: (_) => const PlaceSelectionPage()),
    );
    if (result != null && mounted) setState(() => _selectedPlace = result.displayLabel);
  }

  void _submit() {
    if (_selectedPlace.isEmpty || _selectedDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('장소와 날짜를 선택해주세요.')),
      );
      return;
    }
    final room = PieceRoom(
      title: '자동 매칭 중...',
      currentMembers: 1,
      maxMembers: 4,
      creator: '유저별명',
      location: _selectedPlace,
      meetingAt: DateTime.now(),
      description: '$_selectedDate 자동 매칭 중인 조각입니다.',
    );
    Navigator.of(context).pop(room);
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return MatchingPageScaffold(
      title: '자동 매치',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      '어디서 언제 놀까요?',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: onSurface,
                          ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        OptionChip(
                          icon: Icons.place_rounded,
                          label: _selectedPlace.isEmpty ? '장소 선택' : _selectedPlace,
                          onTap: _onTapPlace,
                        ),
                        OptionChip(
                          icon: Icons.calendar_today_rounded,
                          label: _selectedDate.isEmpty ? '날짜 선택' : _selectedDate,
                          onTap: _onTapDate,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ConfirmButton(
              enabled: _selectedPlace.isNotEmpty && _selectedDate.isNotEmpty,
              onTap: _submit,
              brandColor: _brandColor,
            ),
          ),
        ],
      ),
    );
  }
}
