/// 웹에서만 동작. 카카오 로그인 리다이렉트 복귀 후 쿼리 파라미터(code 등) 제거.
import 'url_util_stub.dart' if (dart.library.html) 'url_util_web.dart' as _impl;

void clearWebQueryParams() => _impl.clearWebQueryParams();
