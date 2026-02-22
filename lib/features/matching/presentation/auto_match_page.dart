import 'package:clubal_app/core/theme/app_colors.dart';
import 'package:clubal_app/core/utils/app_dialogs.dart';
import 'package:clubal_app/core/firestore/piece_room_service.dart';
import 'package:clubal_app/features/chat/chat_dependencies.dart';
import 'package:clubal_app/features/matching/presentation/dialogs/app_date_picker_dialog.dart';
import 'package:clubal_app/features/matching/presentation/place/place_selection.dart';
import 'package:clubal_app/features/matching/presentation/place/place_selection_page.dart';
import 'package:clubal_app/features/matching/presentation/widgets/confirm_button.dart';
import 'package:clubal_app/features/matching/presentation/widgets/matching_page_scaffold.dart';
import 'package:clubal_app/features/matching/presentation/widgets/option_chip.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AutoMatchPage extends StatefulWidget {
  const AutoMatchPage({super.key, this.pieceRoomService});

  final PieceRoomService? pieceRoomService;

  @override
  State<AutoMatchPage> createState() => _AutoMatchPageState();
}

class _AutoMatchPageState extends State<AutoMatchPage> {
  String _selectedDate = '';
  String _selectedPlace = '';
  DateTime? _selectedDateTime;
  String _selectedPlaceLabel = '';
  bool _isSubmitting = false;

  PieceRoomService get _pieceRoomService =>
      widget.pieceRoomService ?? PieceRoomService();

  Future<void> _onTapDate() async {
    final now = DateTime.now();
    final minDate = DateTime(now.year, now.month, now.day);
    final maxDate = minDate.add(const Duration(days: 365));
    final picked = await AppDatePickerDialog.showModal(
      context,
      initialDate: minDate,
      minDate: minDate,
      maxDate: maxDate,
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = '${picked.month}월 ${picked.day}일';
        _selectedDateTime = picked;
      });
    }
  }

  Future<void> _onTapPlace() async {
    final result = await Navigator.of(context).push<PlaceSelection>(
      MaterialPageRoute(builder: (_) => const PlaceSelectionPage()),
    );
    if (result != null && mounted) {
      setState(() {
        _selectedPlace = result.displayLabel;
        _selectedPlaceLabel = result.displayLabel;
      });
    }
  }

  String _dateToKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _submit() async {
    if (_selectedPlace.isEmpty || _selectedDate.isEmpty || _selectedDateTime == null) {
      showMessageDialog(context, message: '장소와 날짜를 선택해주세요.', isError: true);
      return;
    }
    setState(() => _isSubmitting = true);
    final dateKey = _dateToKey(_selectedDateTime!);
    final userName = FirebaseAuth.instance.currentUser?.displayName ?? '참여자';
    final result = await _pieceRoomService.findOrCreateAutoMatchRoom(
      placeLabel: _selectedPlaceLabel,
      meetingAt: _selectedDateTime!,
      dateKey: dateKey,
      userName: userName,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result.error != null) {
      showMessageDialog(context, message: result.error!, isError: true);
      return;
    }

    final room = result.room;
    if (room == null) return;

    if (result.isNewlyCompleted &&
        result.memberIds != null &&
        result.memberIds!.length >= 6) {
      await getChatRepository().createGroupRoom(
        pieceRoomId: room.id!,
        participantIds: result.memberIds!,
        roomName: room.title,
        locationTag: room.location,
        meetingDate: room.meetingAt,
      );
    }
    if (!mounted) return;
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
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      '매칭중에 카드가 만들어지고, 6명이 모이면 매칭완료·채팅방이 자동 생성돼요.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              enabled: _selectedPlace.isNotEmpty &&
                  _selectedDate.isNotEmpty &&
                  !_isSubmitting,
              onTap: _submit,
              brandColor: AppColors.brandPrimary,
            ),
          ),
          if (_isSubmitting) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}
