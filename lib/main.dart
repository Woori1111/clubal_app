import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:clubal_app/app/clubal_app.dart';
import 'package:clubal_app/debug_ingest.dart';
import 'package:clubal_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // #region agent log
  const _debugChannel = MethodChannel('com.clubal.app/debug');
  _debugChannel.setMethodCallHandler((MethodCall call) async {
    if (call.method == 'log' && call.arguments is Map) {
      final m = Map<String, dynamic>.from(call.arguments as Map);
      debugIngest(m);
    }
  });
  // #endregion
  // iOS/Android: 화면 끝까지 그리기. 미설정 시 하단·노치 바깥이 검은 막대로 보임.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ClubalApp());
}
