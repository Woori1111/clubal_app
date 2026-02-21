import 'dart:convert';
import 'dart:io';

// #region agent log
void debugIngest(Map<String, dynamic> payload) {
  payload['timestamp'] = DateTime.now().millisecondsSinceEpoch;
  payload['location'] = payload['location'] ?? 'debug_ingest.dart';
  Future<void>.microtask(() async {
    try {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse(
          'http://127.0.0.1:7242/ingest/2f2c6eea-fb49-450f-b23e-ea99425b357b'));
      request.headers.set('Content-Type', 'application/json');
      request.write(jsonEncode(payload));
      await request.close();
      client.close();
    } catch (_) {}
  });
}
// #endregion
