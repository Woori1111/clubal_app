import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:clubal_app/app/clubal_app.dart';
import 'package:clubal_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ClubalApp());
}
