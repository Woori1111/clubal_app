import 'dart:async';

import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/core/widgets/pressed_icon_action_button.dart';
import 'package:flutter/material.dart';

/// 요즘 앱처럼 상단 검색바 + 실시간(디바운스) 필터링 검색 화면
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _queryController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';
  Timer? _debounce;

  /// 실시간 검색을 위한 디바운스 (입력 멈춘 뒤 300ms 후 반영)
  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  @override
  void initState() {
    super.initState();
    _queryController.addListener(() => _onQueryChanged(_queryController.text));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const ClubalBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      PressedIconActionButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: '뒤로가기',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SearchBar(
                          controller: _queryController,
                          focusNode: _focusNode,
                          hint: '사람, 모임, 게시물 검색',
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _SearchBody(query: _query),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.hint,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant _SearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        autofocus: true,
        textInputAction: TextInputAction.search,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF243244),
              fontWeight: FontWeight.w500,
            ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(
            color: const Color(0xFF243244).withOpacity(0.5),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: const Color(0xFF304255).withOpacity(0.8),
            size: 24,
          ),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.cancel_rounded,
                    color: const Color(0xFF304255).withOpacity(0.6),
                    size: 20,
                  ),
                  onPressed: () {
                    widget.controller.clear();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.6),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

/// 검색어에 따라 실시간으로 보여줄 콘텐츠 (추후 API/로컬 데이터 연동 가능)
class _SearchBody extends StatelessWidget {
  const _SearchBody({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return _EmptyState();
    }
    return _SearchResultsList(query: query);
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 56,
            color: const Color(0xFF304255).withOpacity(0.35),
          ),
          const SizedBox(height: 16),
          Text(
            '검색어를 입력하세요',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF304255).withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '사람, 모임, 게시물을 찾아보세요',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF304255).withOpacity(0.5),
                ),
          ),
        ],
      ),
    );
  }
}

/// 디바운스된 검색어로 필터링된 결과 리스트 (샘플 데이터)
class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({required this.query});

  final String query;

  static const List<Map<String, String>> _sampleItems = [
    {'title': '주지훈', 'subtitle': '프로필'},
    {'title': '클럽 알파', 'subtitle': '모임'},
    {'title': '주말 등산 모임', 'subtitle': '게시물'},
    {'title': '맛집 공유', 'subtitle': '게시물'},
    {'title': '영화 동호회', 'subtitle': '모임'},
  ];

  @override
  Widget build(BuildContext context) {
    final lower = query.toLowerCase();
    final filtered = _sampleItems
        .where((e) =>
            e['title']!.toLowerCase().contains(lower) ||
            (e['subtitle']?.toLowerCase().contains(lower) ?? false))
        .toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: const Color(0xFF304255).withOpacity(0.4),
            ),
            const SizedBox(height: 12),
            Text(
              '"$query"에 대한 결과가 없어요',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF304255).withOpacity(0.7),
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Icon(
                      item['subtitle'] == '프로필'
                          ? Icons.person_rounded
                          : item['subtitle'] == '모임'
                              ? Icons.groups_rounded
                              : Icons.article_rounded,
                      color: const Color(0xFF304255),
                      size: 24,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']!,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: const Color(0xFF243244),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['subtitle']!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: const Color(0xFF304255)
                                      .withOpacity(0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: Color(0xFF304255),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
