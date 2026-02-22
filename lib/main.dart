import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:clubal_app/app/clubal_app.dart';
import 'package:clubal_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw TimeoutException('Firebase init'),
    );
  } on Exception catch (_) {
    // 웹 등에서 Firebase 초기화가 멈출 때 앱은 그대로 진입 (Firestore 등은 빈 데이터)
  }
  runApp(const ClubalApp());
}
