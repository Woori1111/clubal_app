import 'package:clubal_app/core/widgets/clubal_glass_card.dart';
import 'package:clubal_app/core/widgets/clubal_page_scaffold.dart';
import 'package:flutter/material.dart';

/// 프로필 편집 결과를 돌려줄 때 사용
class ProfileEditResult {
  const ProfileEditResult({
    required this.displayName,
    required this.bio,
  });

  final String displayName;
  final String bio;
}

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({
    super.key,
    required this.initialDisplayName,
    required this.initialBio,
  });

  final String initialDisplayName;
  final String initialBio;

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialDisplayName);
    _bioController = TextEditingController(text: widget.initialBio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final bio = _bioController.text.trim();
    Navigator.of(context).pop(ProfileEditResult(
      displayName: name.isEmpty ? widget.initialDisplayName : name,
      bio: bio.isEmpty ? widget.initialBio : bio,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return ClubalPageScaffold(
      title: '프로필 편집',
      appBarTrailing: TextButton(
        onPressed: _save,
        style: TextButton.styleFrom(
          foregroundColor: onSurface,
          textStyle: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        child: const Text('저장'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ClubalGlassCard(
              radius: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '이름',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: onSurface,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: '이름을 입력하세요',
                      filled: true,
                      fillColor: onSurface.withValues(alpha: 0.08),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: onSurface,
                        ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '소개',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: onSurface,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bioController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: '자기소개를 입력하세요',
                      filled: true,
                      fillColor: onSurface.withValues(alpha: 0.08),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: onSurface,
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
}
