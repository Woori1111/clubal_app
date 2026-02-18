import 'package:clubal_app/core/widgets/clubal_background.dart';
import 'package:clubal_app/core/widgets/glass_card.dart';
import 'package:clubal_app/core/widgets/pressed_icon_action_button.dart';
import 'package:clubal_app/features/profile/presentation/profile_edit_page.dart';
import 'package:flutter/material.dart';

class ProfileDetailPage extends StatefulWidget {
  const ProfileDetailPage({
    super.key,
    this.initialDisplayName = '주지훈',
    this.initialBio = '나는 주지훈 입니다. 1000만 영화배우입니다!!',
  });

  final String initialDisplayName;
  final String initialBio;

  @override
  State<ProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage> {
  late String _displayName;
  late String _bio;

  @override
  void initState() {
    super.initState();
    _displayName = widget.initialDisplayName;
    _bio = widget.initialBio;
  }

  void _openEdit() {
    Navigator.of(context)
        .push<ProfileEditResult>(
          MaterialPageRoute<ProfileEditResult>(
            builder: (_) => ProfileEditPage(
              initialDisplayName: _displayName,
              initialBio: _bio,
            ),
          ),
        )
        .then((result) {
      if (result != null && mounted) {
        setState(() {
          _displayName = result.displayName;
          _bio = result.bio;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const ClubalBackground(),
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
                        onPressed: _openEdit,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF2A394A),
                          textStyle: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        child: const Text('수정하기'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 20,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white.withOpacity(0.25),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Color(0xFF243244),
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _displayName,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _bio,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xD9EAF6FF),
                                  height: 1.4,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
