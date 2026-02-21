import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/core/widgets/clubal_full_body.dart';
import 'package:clubal_app/core/widgets/glass_card.dart';
import 'package:clubal_app/core/widgets/pressed_icon_action_button.dart';
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
    return Scaffold(
      body: Builder(
        builder: (context) => wrapFullBody(
          context,
          Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(child: ClubalBackground()),
              ),
              SafeArea(
                child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PressedIconActionButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: '뒤로가기',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _save,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF2A394A),
                          textStyle: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        child: const Text('저장'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '프로필 수정',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF243244),
                        ),
                  ),
                  const SizedBox(height: 20),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '이름',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF243244),
                              ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: '이름을 입력하세요',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.5),
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
                                color: const Color(0xFF243244),
                              ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '소개',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF243244),
                              ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _bioController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: '자기소개를 입력하세요',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.5),
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
                                color: const Color(0xFF243244),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ),
    );
  }
}
