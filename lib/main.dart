import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:clubal_app/app/clubal_app.dart';
import 'package:clubal_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  try {
    // 웹: 짧은 타임아웃으로 무한 로딩 방지 (느린/막힌 네트워크에서도 화면 진입)
    final timeout = kIsWeb ? const Duration(seconds: 6) : const Duration(seconds: 15);
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      timeout,
      onTimeout: () => throw TimeoutException('Firebase init'),
    );
  } on Exception catch (_) {
    // 웹 등에서 Firebase 초기화가 멈추거나 실패해도 앱은 그대로 진입 (Firestore 등은 빈 데이터)
  }
  runApp(const ClubalApp());
}
