import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/features/matching/models/piece_room.dart';
import 'package:clubal_app/features/matching/presentation/create_piece_room_page.dart';
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

    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DatePickerBottomSheet(
          initialDate: minDate,
          minDate: minDate,
          maxDate: maxDate,
        );
      },
    );
    if (picked != null) {
      final text = '${picked.month}월 ${picked.day}일 ${picked.hour.toString().padLeft(2, '0')}시';
      setState(() => _selectedDate = text);
    }
  }

  Future<void> _onTapPlace() async {
    final result = await Navigator.of(context).push<PlaceSelection>(
      MaterialPageRoute<PlaceSelection>(
        builder: (_) => const PlaceSelectionPage(),
      ),
    );
    if (result != null) {
      setState(() => _selectedPlace = result.displayLabel);
    }
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
      meetingAt: DateTime.now(), // dummy
      description: '$_selectedDate 자동 매칭 중인 조각입니다.',
    );
    Navigator.of(context).pop(room);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const ClubalBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '자동 매치',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
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
                                    color: const Color(0xFF253445),
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
            ),
          ),
        ],
      ),
    );
  }
}
