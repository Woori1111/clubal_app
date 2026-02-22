/// 카카오 로그인 설정.
///
/// [Kakao Developers](https://developers.kakao.com)에서 앱을 등록한 뒤
/// 웹 플랫폼 JavaScript 키를 발급받아 설정하세요.
/// 리다이렉트 URI는 웹 도메인(예: https://clubal.co.kr/)을 등록해야 합니다.
class KakaoConfig {
  KakaoConfig._();

  /// 웹용 JavaScript 앱 키. 카카오 개발자 콘솔 > 앱 설정 > 앱 키에서 확인.
  static const String javascriptAppKey = '';

  /// 웹에서 카카오 로그인 사용 여부 (키가 비어 있으면 비활성화).
  static bool get isWebEnabled =>
      javascriptAppKey.isNotEmpty;
}
