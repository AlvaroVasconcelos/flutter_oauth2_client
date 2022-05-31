import 'package:openid_client/openid_client.dart';

import 'src/authentication.dart'
    if (dart.library.html) 'src/authentication_web.dart'
    if (dart.library.io) 'src/authentication_io.dart' as oauth;

abstract class FlutterOAuth2Client {
  FlutterOAuth2Client._();

  static Future<TokenResponse> authenticate({
    required Uri uri,
    required String clientId,
    List<String>? scopes,
  }) async =>
      oauth.authentication(uri, clientId, scopes ?? const []);

  static Future<void> logout({
    required Uri uri, //Same uri from authenticate method
    String? idTokenString, //Used only in mobile logout
    String? redirectString, //Used only in web logout
  }) async {
    if (idTokenString == null && redirectString == null) {
      throw UnimplementedError(
        'Define idTokenString for mobile logout or redirectString for web logout.',
      );
    }
    await oauth.logout(uri, idTokenString, redirectString);
  }
}

extension AetherTokenResponseExtensions on TokenResponse {
  String? get idTokenString => toJson()['id_token'] as String;
}
