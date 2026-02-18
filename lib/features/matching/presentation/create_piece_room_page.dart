import 'dart:ui';

import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/features/matching/models/piece_room.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreatePieceRoomPage extends StatefulWidget {
  const CreatePieceRoomPage({super.key});

  @override
  State<CreatePieceRoomPage> createState() => _CreatePieceRoomPageState();
}

class _CreatePieceRoomPageState extends State<CreatePieceRoomPage> {
  static const Color _brandColor = Color(0xFF2ECEF2);

  final TextEditingController _titleController = TextEditingController(
    text: '별명님의 조각',
  );
  final TextEditingController _descriptionController = TextEditingController();

  late DateTime _selectedDateTime;
  int _memberCount = 4;
  PlaceSelection? _selectedPlace;
  bool _openedDateSheetInitially = false;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = _roundToHour(DateTime.now());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _openedDateSheetInitially) {
        return;
      }
      _openedDateSheetInitially = true;
      _openDatePickerBottomSheet();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  static DateTime _roundToHour(DateTime value) {
    return DateTime(value.year, value.month, value.day, value.hour);
  }

  Future<void> _openDatePickerBottomSheet() async {
    final now = _roundToHour(DateTime.now());
    final minDate = now;
    final maxDate = now.add(const Duration(days: 365));
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _DatePickerBottomSheet(
          initialDate: _selectedDateTime,
          minDate: minDate,
          maxDate: maxDate,
        );
      },
    );
    if (picked == null) {
      return;
    }
    setState(() => _selectedDateTime = picked);
  }

  Future<void> _selectPlace() async {
    final result = await Navigator.of(context).push<PlaceSelection>(
      MaterialPageRoute<PlaceSelection>(
        builder: (_) => const _PlaceSelectionPage(),
      ),
    );
    if (result == null) {
      return;
    }
    setState(() => _selectedPlace = result);
  }

  void _submit() {
    if (_selectedPlace == null) {
      return;
    }
    final title = _titleController.text.trim().isEmpty
        ? '별명님의 조각'
        : _titleController.text.trim();
    final room = PieceRoom(
      title: title,
      currentMembers: 1,
      maxMembers: _memberCount,
      creator: '별명',
      location: _selectedPlace!.clubName,
      meetingAt: _selectedDateTime,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );
    Navigator.of(context).pop(room);
  }

  @override
  Widget build(BuildContext context) {
    final readyToSubmit = _selectedPlace != null;
    final dateLabel =
        '${_selectedDateTime.month}월 ${_selectedDateTime.day}일 ${_selectedDateTime.hour.toString().padLeft(2, '0')}시';
    return Scaffold(
      body: Stack(
        children: [
          const ClubalBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '조각 방 만들기',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionCard(
                            title: '날짜 선택',
                            child: _PlainActionButton(
                              label: dateLabel,
                              onTap: _openDatePickerBottomSheet,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _SectionCard(
                            title: '장소 선택',
                            child: _PlainActionButton(
                              label: _selectedPlace == null
                                  ? '장소 선택하기'
                                  : _selectedPlace!.displayLabel,
                              onTap: _selectPlace,
                            ),
                          ),
                          AnimatedCrossFade(
                            firstChild: const SizedBox.shrink(),
                            secondChild: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                _SectionCard(
                                  title: '방 제목',
                                  child: TextField(
                                    controller: _titleController,
                                    decoration: const InputDecoration(
                                      hintText: '방 제목을 입력하세요',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _SectionCard(
                                  title: '인원',
                                  child: Row(
                                    children: [
                                      _ArrowCircleButton(
                                        icon: Icons.chevron_left_rounded,
                                        onTap: _memberCount > 4
                                            ? () => setState(() => _memberCount--)
                                            : null,
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            '$_memberCount명',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                      ),
                                      _ArrowCircleButton(
                                        icon: Icons.chevron_right_rounded,
                                        onTap: _memberCount < 6
                                            ? () => setState(() => _memberCount++)
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _SectionCard(
                                  title: '설명 (선택사항)',
                                  child: TextField(
                                    controller: _descriptionController,
                                    maxLines: 3,
                                    decoration: const InputDecoration(
                                      hintText: '분위기, 드레스코드 등을 자유롭게 작성하세요',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            crossFadeState: _selectedPlace == null
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            duration: const Duration(milliseconds: 260),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ConfirmButton(
                    enabled: readyToSubmit,
                    onTap: _submit,
                    brandColor: _brandColor,
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

class _DatePickerBottomSheet extends StatefulWidget {
  const _DatePickerBottomSheet({
    required this.initialDate,
    required this.minDate,
    required this.maxDate,
  });

  final DateTime initialDate;
  final DateTime minDate;
  final DateTime maxDate;

  @override
  State<_DatePickerBottomSheet> createState() => _DatePickerBottomSheetState();
}

class _DatePickerBottomSheetState extends State<_DatePickerBottomSheet> {
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
    final availableDays = _buildDateRange(widget.minDate, widget.maxDate);
    final selectedDayIndex = availableDays.indexWhere(
      (day) =>
          day.year == _selectedDateTime.year &&
          day.month == _selectedDateTime.month &&
          day.day == _selectedDateTime.day,
    );
    final dayIndex = selectedDayIndex < 0 ? 0 : selectedDayIndex;
    final hourIndex = _selectedDateTime.hour.clamp(0, 23);

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF6FAFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
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
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(_selectedDateTime),
                  child: const Text('완료'),
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
                                style: Theme.of(context).textTheme.titleMedium,
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
                            style: Theme.of(context).textTheme.titleMedium,
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

class PlaceSelection {
  const PlaceSelection({
    required this.region,
    required this.district,
    required this.clubName,
  });

  final String region;
  final String district;
  final String clubName;

  String get displayLabel => '$region · $district · $clubName';
}

class _PlaceSelectionPage extends StatefulWidget {
  const _PlaceSelectionPage();

  @override
  State<_PlaceSelectionPage> createState() => _PlaceSelectionPageState();
}

class _PlaceSelectionPageState extends State<_PlaceSelectionPage> {
  static const _hotClubs = [
    'Aura Seoul',
    'Club Nyx',
    'Sound Basement',
    'Pulse 808',
  ];

  static const Map<String, List<String>> _regions = {
    '서울': ['강남구', '성동구', '마포구', '용산구', '송파구', '광진구'],
    '경기': ['수원시', '성남시', '고양시', '안양시', '용인시', '부천시'],
    '인천': ['연수구', '부평구', '미추홀구'],
    '부산': ['해운대구', '수영구', '부산진구'],
  };

  String _selectedRegion = '서울';
  final Set<String> _favoriteClubs = {};

  void _toggleFavorite(String clubName) {
    setState(() {
      if (_favoriteClubs.contains(clubName)) {
        _favoriteClubs.remove(clubName);
      } else {
        _favoriteClubs.add(clubName);
      }
    });
  }

  void _selectDirectClub({
    required String region,
    required String district,
    required String clubName,
  }) {
    Navigator.of(context).pop(
      PlaceSelection(region: region, district: district, clubName: clubName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoriteList = _favoriteClubs.toList()..sort();
    return Scaffold(
      appBar: AppBar(title: const Text('장소 선택')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        children: [
          _SectionTitle(title: 'HOT🔥'),
          const SizedBox(height: 8),
          _HorizontalClubCards(
            clubs: _hotClubs,
            favorites: _favoriteClubs,
            onTap: (club) => _selectDirectClub(
              region: 'HOT',
              district: '추천',
              clubName: club,
            ),
            onLongPress: _toggleFavorite,
          ),
          const SizedBox(height: 14),
          _SectionTitle(title: '즐겨찾기'),
          const SizedBox(height: 8),
          favoriteList.isEmpty
              ? const _EmptyFavoriteCard()
              : _HorizontalClubCards(
                  clubs: favoriteList,
                  favorites: _favoriteClubs,
                  onTap: (club) => _selectDirectClub(
                    region: '즐겨찾기',
                    district: '클럽',
                    clubName: club,
                  ),
                  onLongPress: _toggleFavorite,
                ),
          const SizedBox(height: 14),
          _SectionTitle(title: '지역'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _regions.keys
                .map(
                  (region) => ChoiceChip(
                    label: Text(region),
                    selected: region == _selectedRegion,
                    onSelected: (_) => setState(() => _selectedRegion = region),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _regions[_selectedRegion]!.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.4,
            ),
            itemBuilder: (context, index) {
              final district = _regions[_selectedRegion]![index];
              return OutlinedButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push<_ClubListResult>(
                    MaterialPageRoute<_ClubListResult>(
                      builder: (_) => _ClubListPage(
                        region: _selectedRegion,
                        district: district,
                        favoriteClubs: _favoriteClubs,
                      ),
                    ),
                  );
                  if (result == null) {
                    return;
                  }
                  setState(() {
                    _favoriteClubs
                      ..clear()
                      ..addAll(result.favoriteClubs);
                  });
                  if (!context.mounted || result.selectedClub == null) {
                    return;
                  }
                  Navigator.of(context).pop(
                    PlaceSelection(
                      region: _selectedRegion,
                      district: district,
                      clubName: result.selectedClub!,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0x3B4A5F76)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(district, style: const TextStyle(fontSize: 13)),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ClubListResult {
  const _ClubListResult({required this.favoriteClubs, this.selectedClub});

  final Set<String> favoriteClubs;
  final String? selectedClub;
}

class _ClubListPage extends StatefulWidget {
  const _ClubListPage({
    required this.region,
    required this.district,
    required this.favoriteClubs,
  });

  final String region;
  final String district;
  final Set<String> favoriteClubs;

  @override
  State<_ClubListPage> createState() => _ClubListPageState();
}

class _ClubListPageState extends State<_ClubListPage> {
  late final Set<String> _favoriteClubs = {...widget.favoriteClubs};

  @override
  Widget build(BuildContext context) {
    final clubs = _clubsByDistrict[widget.district] ?? const ['Moonlight Club'];
    return Scaffold(
      appBar: AppBar(title: Text('${widget.district} 클럽')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        itemCount: clubs.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final club = clubs[index];
          final isFavorite = _favoriteClubs.contains(club);
          return _ClubSectionCard(
            title: club,
            favorite: isFavorite,
            onTap: () {
              Navigator.of(context).pop(
                _ClubListResult(
                  favoriteClubs: {..._favoriteClubs},
                  selectedClub: club,
                ),
              );
            },
            onLongPress: () {
              setState(() {
                if (isFavorite) {
                  _favoriteClubs.remove(club);
                } else {
                  _favoriteClubs.add(club);
                }
              });
            },
          );
        },
      ),
    );
  }

  static const Map<String, List<String>> _clubsByDistrict = {
    '강남구': ['Molecule', 'Club Arena', 'Club Bound'],
    '성동구': ['Seongsu Hive', 'Factory Loop', 'Electric Brick'],
    '마포구': ['Hongdae Vault', 'Retro Pulse', 'Club Prism'],
    '용산구': ['Itaewon Blend', 'Noir Stage', 'River Deck'],
    '송파구': ['Jamsil Pulse', 'Lake Night', 'Rooftop Mix'],
    '광진구': ['Kondae Drift', 'Midnight Square'],
    '수원시': ['Suwon Beat', 'Blue Halo'],
    '성남시': ['Pangyo Vibe', 'Neon Yard'],
    '고양시': ['Lake Groove', 'City Bounce'],
    '안양시': ['Anyang Echo', 'Downtown Frame'],
    '용인시': ['Yongin Wave', 'Night Farm'],
    '부천시': ['Bucheon Hall', 'Beat Cube'],
    '연수구': ['Songdo Wave', 'Triple Beat'],
    '부평구': ['Bupyeong Mix', 'Night Docks'],
    '미추홀구': ['Harbor Tone', 'Retro Pier'],
    '해운대구': ['Haeundae Rise', 'Ocean Pulse'],
    '수영구': ['Gwangan Glow', 'Bridge Beat'],
    '부산진구': ['Seomyeon Dive', 'Metro Halo'],
  };
}

class _HorizontalClubCards extends StatelessWidget {
  const _HorizontalClubCards({
    required this.clubs,
    required this.favorites,
    required this.onTap,
    required this.onLongPress,
  });

  final List<String> clubs;
  final Set<String> favorites;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onLongPress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: clubs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final club = clubs[index];
          return _ClubSectionCard(
            title: club,
            favorite: favorites.contains(club),
            onTap: () => onTap(club),
            onLongPress: () => onLongPress(club),
          );
        },
      ),
    );
  }
}

class _ClubSectionCard extends StatelessWidget {
  const _ClubSectionCard({
    required this.title,
    required this.favorite,
    required this.onTap,
    required this.onLongPress,
  });

  final String title;
  final bool favorite;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final bgColor = favorite ? const Color(0xFF111111) : const Color(0xF2FFFFFF);
    final fgColor = favorite ? Colors.white : const Color(0xFF2D3E54);
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: favorite ? const Color(0xFF111111) : const Color(0x334C6078),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x16000000),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: fgColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _EmptyFavoriteCard extends StatelessWidget {
  const _EmptyFavoriteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0x8AFFFFFF),
        border: Border.all(color: const Color(0x334A5F75), width: 1),
      ),
      child: Text(
        '클럽 카드를 길게 눌러 즐겨찾기에 추가하세요',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: const Color(0xFF55667B)),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0x2F3F5468), width: 1),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xDFFFFFFF), Color(0xCCEAF2FA)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xAA34485F),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _ArrowCircleButton extends StatelessWidget {
  const _ArrowCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onTap,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        minimumSize: const Size(42, 42),
        backgroundColor: const Color(0x66FFFFFF),
      ),
    );
  }
}

class _PlainActionButton extends StatelessWidget {
  const _PlainActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: Color(0x444B5D73)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatefulWidget {
  const _ConfirmButton({
    required this.enabled,
    required this.onTap,
    required this.brandColor,
  });

  final bool enabled;
  final VoidCallback onTap;
  final Color brandColor;

  @override
  State<_ConfirmButton> createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<_ConfirmButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final opacity = widget.enabled ? (_pressed ? 0.74 : 1.0) : 0.45;
    final scale = _pressed ? 0.96 : 1.0;
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => _setPressed(true) : null,
      onTapUp: widget.enabled ? (_) => _setPressed(false) : null,
      onTapCancel: () => _setPressed(false),
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 110),
        scale: scale,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 110),
          opacity: opacity,
          child: Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              color: widget.brandColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x332ECEF2),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '확인',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
