import 'package:clubal_app/features/matching/presentation/place/place_selection.dart';
import 'package:flutter/material.dart';

/// 장소 선택 페이지 (HOT/즐겨찾기/지역별 클럽)
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
          _PlaceSectionTitle(title: 'HOT🔥'),
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
          _PlaceSectionTitle(title: '즐겨찾기'),
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
          _PlaceSectionTitle(title: '지역'),
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
                  final result = await Navigator.of(context).push<ClubListResult>(
                    MaterialPageRoute<ClubListResult>(
                      builder: (_) => ClubListPage(
                        region: _selectedRegion,
                        district: district,
                        favoriteClubs: _favoriteClubs,
                      ),
                    ),
                  );
                  if (result == null) return;
                  setState(() {
                    _favoriteClubs
                      ..clear()
                      ..addAll(result.favoriteClubs);
                  });
                  if (!context.mounted || result.selectedClub == null) return;
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

/// 클럽 목록 페이지에서 돌려줄 결과
class ClubListResult {
  const ClubListResult({required this.favoriteClubs, this.selectedClub});

  final Set<String> favoriteClubs;
  final String? selectedClub;
}

class ClubListPage extends StatefulWidget {
  const ClubListPage({
    super.key,
    required this.region,
    required this.district,
    required this.favoriteClubs,
  });

  final String region;
  final String district;
  final Set<String> favoriteClubs;

  @override
  State<ClubListPage> createState() => _ClubListPageState();
}

class _ClubListPageState extends State<ClubListPage> {
  late final Set<String> _favoriteClubs = {...widget.favoriteClubs};

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

  @override
  Widget build(BuildContext context) {
    final clubs = _clubsByDistrict[widget.district] ?? const ['Moonlight Club'];
    return Scaffold(
      appBar: AppBar(title: Text('${widget.district} 클럽')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        itemCount: clubs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final club = clubs[index];
          final isFavorite = _favoriteClubs.contains(club);
          return ClubSectionCard(
            title: club,
            favorite: isFavorite,
            onTap: () {
              Navigator.of(context).pop(
                ClubListResult(
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
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final club = clubs[index];
          return ClubSectionCard(
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

class ClubSectionCard extends StatelessWidget {
  const ClubSectionCard({
    super.key,
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

class _PlaceSectionTitle extends StatelessWidget {
  const _PlaceSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
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
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF55667B),
            ),
      ),
    );
  }
}
