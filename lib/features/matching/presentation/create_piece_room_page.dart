import 'package:clubal_app/features/matching/models/piece_room.dart';
import 'package:clubal_app/features/matching/presentation/dialogs/app_date_picker_dialog.dart';
import 'package:clubal_app/features/matching/presentation/place/place_selection.dart';
import 'package:clubal_app/features/matching/presentation/place/place_selection_page.dart';
import 'package:clubal_app/features/matching/presentation/widgets/arrow_circle_button.dart';
import 'package:clubal_app/features/matching/presentation/widgets/confirm_button.dart';
import 'package:clubal_app/features/matching/presentation/widgets/matching_page_scaffold.dart';
import 'package:clubal_app/features/matching/presentation/widgets/option_chip.dart';
import 'package:flutter/material.dart';

class CreatePieceRoomPage extends StatefulWidget {
  const CreatePieceRoomPage({super.key});

  @override
  State<CreatePieceRoomPage> createState() => _CreatePieceRoomPageState();
}

class _CreatePieceRoomPageState extends State<CreatePieceRoomPage> {
  static const Color _brandColor = Color(0xFF2ECEF2);

  final TextEditingController _titleController = TextEditingController(text: '유저별명님의 조각');
  final TextEditingController _contentController = TextEditingController();

  int _memberCount = 4;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _appendContent(String info) {
    final text = _contentController.text;
    _contentController.text = text.isEmpty ? info : '$text\n$info';
  }

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
      final str = '${picked.month}월 ${picked.day}일 ${picked.hour.toString().padLeft(2, '0')}시';
      _appendContent('📅 날짜: $str');
    }
  }

  Future<void> _onTapPlace() async {
    final result = await Navigator.of(context).push<PlaceSelection>(
      MaterialPageRoute(builder: (_) => const PlaceSelectionPage()),
    );
    if (result != null) _appendContent('📍 장소: ${result.displayLabel}');
  }

  void _onTapPhoto() {
    _appendContent('📸 사진: 첨부됨');
  }

  Future<void> _onTapPrice() async {
    final price = await showDialog<String>(
      context: context,
      builder: (ctx) {
        String input = '';
        return AlertDialog(
          title: const Text('가격 입력'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: '예: 50000'),
            onChanged: (val) => input = val,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(input),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
    if (price != null && price.trim().isNotEmpty && mounted) {
      _appendContent('💰 가격: ${price.trim()}원');
    }
  }

  void _submit() {
    final title = _titleController.text.trim().isEmpty
        ? '새로운 조각 방'
        : _titleController.text.trim();
    final room = PieceRoom(
      title: title,
      currentMembers: 1,
      maxMembers: _memberCount,
      creator: '유저',
      location: '미정',
      meetingAt: DateTime.now(),
      description: _contentController.text.trim(),
    );
    Navigator.of(context).pop(room);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onSurface = colorScheme.onSurface;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    final outlineVariant = colorScheme.outlineVariant;

    return MatchingPageScaffold(
      title: '게시물 작성',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleField(context, onSurface, onSurfaceVariant),
                  const SizedBox(height: 16),
                  _buildMemberStepper(context, onSurface),
                  const SizedBox(height: 20),
                  Divider(height: 1, thickness: 2, color: outlineVariant),
                  const SizedBox(height: 20),
                  _buildOptionChips(),
                  const SizedBox(height: 24),
                  _buildContentField(context, onSurface, onSurfaceVariant, outlineVariant),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ConfirmButton(
              enabled: true,
              onTap: _submit,
              brandColor: _brandColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField(
    BuildContext context,
    Color onSurface,
    Color onSurfaceVariant,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _titleController,
        maxLength: 15,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: onSurface),
        decoration: InputDecoration(
          hintText: '제목을 입력하세요 (최대 15자)',
          hintStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: onSurfaceVariant.withValues(alpha: 0.7),
          ),
          border: InputBorder.none,
          counterText: '',
        ),
      ),
    );
  }

  Widget _buildMemberStepper(BuildContext context, Color onSurface) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            '인원수',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                ),
          ),
          const Spacer(),
          ArrowCircleButton(
            icon: Icons.chevron_left_rounded,
            onTap: _memberCount > 2 ? () => setState(() => _memberCount--) : null,
          ),
          SizedBox(
            width: 40,
            child: Center(
              child: Text(
                '$_memberCount',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: onSurface,
                    ),
              ),
            ),
          ),
          ArrowCircleButton(
            icon: Icons.chevron_right_rounded,
            onTap: _memberCount < 10 ? () => setState(() => _memberCount++) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OptionChip(icon: Icons.place_rounded, label: '장소', onTap: _onTapPlace),
          OptionChip(icon: Icons.calendar_today_rounded, label: '날짜', onTap: _onTapDate),
          OptionChip(icon: Icons.camera_alt_rounded, label: '사진', onTap: _onTapPhoto),
          OptionChip(icon: Icons.attach_money_rounded, label: '가격', onTap: _onTapPrice),
        ],
      ),
    );
  }

  Widget _buildContentField(
    BuildContext context,
    Color onSurface,
    Color onSurfaceVariant,
    Color outlineVariant,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: outlineVariant, width: 1)),
      ),
      child: TextField(
        controller: _contentController,
        maxLines: 12,
        style: TextStyle(fontSize: 15, color: onSurface, height: 1.5),
        decoration: InputDecoration(
          hintText: '내용을 자유롭게 입력하세요...',
          hintStyle: TextStyle(color: onSurfaceVariant.withValues(alpha: 0.8)),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
