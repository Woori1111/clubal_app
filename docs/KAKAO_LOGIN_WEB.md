# 웹 카카오 로그인 설정

웹에서 카카오 로그인을 사용하려면 아래 세 가지를 설정해야 합니다.

## 1. 카카오 개발자 콘솔

1. [Kakao Developers](https://developers.kakao.com)에서 앱 생성/선택
2. **앱 설정 > 앱 키**: JavaScript 키 복사
3. **플랫폼 > Web**: 사이트 도메인 등록 (예: `https://clubal.co.kr`, 개발 시 `http://localhost:포트`)
4. **카카오 로그인 > Redirect URI**: 웹 도메인과 동일하게 등록 (예: `https://clubal.co.kr/`)
5. **카카오 로그인** 활성화

## 2. 앱에 JavaScript 키 설정

`lib/core/kakao/kakao_config.dart`에서 `javascriptAppKey`에 위에서 복사한 **JavaScript 키**를 넣습니다.

```dart
static const String javascriptAppKey = '여기에_JavaScript_키_입력';
```

## 3. Firebase Cloud Function (Custom Token 발급)

Firebase Auth는 카카오를 기본 제공하지 않으므로, **권한 코드(code)**를 서버에서 토큰으로 바꾼 뒤 **Firebase Custom Token**을 만들어 클라이언트에 넘겨야 합니다.

### 배포할 함수 예시 (Node.js)

함수 이름: `getKakaoFirebaseToken`  
호출 시 인자: `{ "code": "카카오_리다이렉트_후_받은_code" }`  
반환: `{ "customToken": "firebase_custom_jwt" }`

1. 카카오 REST API로 `code` → 액세스 토큰 교환  
   - [토큰 받기](https://developers.kakao.com/docs/latest/en/kakaologin/rest-api#request-token)
2. (선택) 액세스 토큰으로 [사용자 정보 조회](https://developers.kakao.com/docs/latest/en/kakaologin/rest-api#req-user-info)
3. Firebase Admin SDK로 `createCustomToken(uid)` 호출  
   - `uid` 예: `kakao:${카카오_유저_숫자_ID}`
4. 클라이언트에 `{ "customToken": "..." }` 반환

클라이언트는 이 `customToken`으로 `FirebaseAuth.instance.signInWithCustomToken(customToken)` 호출합니다.

### 참고

- REST API 요청 시 **REST API 키** 사용 (JavaScript 키 아님)
- Redirect URI는 카카오 콘솔에 등록한 값과 앱에서 사용하는 값이 **완전히 동일**해야 합니다.
