import 'package:clubal_app/core/theme/app_theme.dart';
import 'package:clubal_app/features/home/presentation/clubal_home_shell.dart';
import 'package:flutter/material.dart';

class ClubalApp extends StatelessWidget {
  const ClubalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '클러버 Clubal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const ClubalHomeShell(),
    );
  }
}
