import 'dart:html' as html;

/// 웹: 주소창에서 쿼리 파라미터 제거 (카카오 콜백 후 정리).
void clearWebQueryParams() {
  final uri = Uri.parse(html.window.location.href);
  if (uri.queryParameters.isEmpty) return;
  final clean = uri.replace(queryParameters: {});
  html.window.history.replaceState(null, '', clean.toString());
}
