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
    final currentText = _contentController.text;
    if (currentText.isEmpty) {
      _contentController.text = info;
    } else {
      _contentController.text = '$currentText\n$info';
    }
  }

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
      _appendContent('📅 날짜: $text');
    }
  }

  Future<void> _onTapPlace() async {
    final result = await Navigator.of(context).push<PlaceSelection>(
      MaterialPageRoute<PlaceSelection>(
        builder: (_) => const PlaceSelectionPage(),
      ),
    );
    if (result != null) {
      _appendContent('📍 장소: ${result.displayLabel}');
    }
  }

  void _onTapPhoto() {
    // 사진 선택 모의 동작
    _appendContent('📸 사진: 첨부됨');
  }

  Future<void> _onTapPrice() async {
    final price = await showDialog<String>(
      context: context,
      builder: (context) {
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(input),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
    if (price != null && price.trim().isNotEmpty) {
      _appendContent('💰 가격: $price원');
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
      location: '미정', // 본래는 selectedPlace에서 가져와야 하지만 요구사항상 본문에 추가됨
      meetingAt: DateTime.now(),
      description: _contentController.text.trim(),
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
                          '게시물 작성',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 제목 입력
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextField(
                              controller: _titleController,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF253445),
                              ),
                              decoration: const InputDecoration(
                                hintText: '제목을 입력하세요',
                                hintStyle: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0x66253445),
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // 인원수 스텝퍼
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Text(
                                  '인원수',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF253445),
                                  ),
                                ),
                                const Spacer(),
                                _ArrowCircleButton(
                                  icon: Icons.remove_rounded,
                                  onTap: _memberCount > 2
                                      ? () => setState(() => _memberCount--)
                                      : null,
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Center(
                                    child: Text(
                                      '$_memberCount',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF253445),
                                      ),
                                    ),
                                  ),
                                ),
                                _ArrowCircleButton(
                                  icon: Icons.add_rounded,
                                  onTap: _memberCount < 10
                                      ? () => setState(() => _memberCount++)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // 카드 섹션들 (장소, 날짜, 사진, 가격)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                            children: [
                              OptionChip(
                                icon: Icons.place_rounded,
                                label: '장소',
                                onTap: _onTapPlace,
                              ),
                              OptionChip(
                                icon: Icons.calendar_today_rounded,
                                label: '날짜',
                                onTap: _onTapDate,
                              ),
                              OptionChip(
                                icon: Icons.camera_alt_rounded,
                                label: '사진',
                                onTap: _onTapPhoto,
                              ),
                              OptionChip(
                                icon: Icons.attach_money_rounded,
                                label: '가격',
                                onTap: _onTapPrice,
                              ),
                            ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // 내용 입력
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Color(0x334B5D73), width: 1),
                              ),
                            ),
                            child: TextField(
                              controller: _contentController,
                              maxLines: 12,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF253445),
                                height: 1.5,
                              ),
                              decoration: const InputDecoration(
                                hintText: '내용을 자유롭게 입력하세요...',
                                hintStyle: TextStyle(
                                  color: Color(0x88253445),
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                  
                  // 확인 버튼
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
            ),
          ),
        ],
      ),
    );
  }
}

class OptionChip extends StatelessWidget {
  const OptionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0x66FFFFFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x4DFFFFFF), width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: const Color(0xFF253445)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF253445),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// 아래는 기존의 DatePickerBottomSheet, PlaceSelection 등 재사용 컴포넌트들
// ----------------------------------------------------------------------

class DatePickerBottomSheet extends StatefulWidget {
  const DatePickerBottomSheet({
    super.key,
    required this.initialDate,
    required this.minDate,
    required this.maxDate,
  });

  final DateTime initialDate;
  final DateTime minDate;
  final DateTime maxDate;

  @override
  State<DatePickerBottomSheet> createState() => _DatePickerBottomSheetState();
}

class _DatePickerBottomSheetState extends State<DatePickerBottomSheet> {
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

class PlaceSelectionPage extends StatefulWidget {
  const PlaceSelectionPage({super.key});

  @override
  State<PlaceSelectionPage> createState() => _PlaceSelectionPageState();
}

class _PlaceSelectionPageState extends State<PlaceSelectionPage> {
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

class ConfirmButton extends StatefulWidget {
  const ConfirmButton({
    super.key,
    required this.enabled,
    required this.onTap,
    required this.brandColor,
  });

  final bool enabled;
  final VoidCallback onTap;
  final Color brandColor;

  @override
  State<ConfirmButton> createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<ConfirmButton> {
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  color: widget.brandColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0x66FFFFFF),
                    width: 1.5,
                  ),
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
        ),
      ),
    );
  }
}
