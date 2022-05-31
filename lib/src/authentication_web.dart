// ignore: avoid_web_libraries_in_flutter
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:openid_client/openid_client_browser.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> _launchURL(String url) async {
  if (!await launchUrlString(
    url,
    webOnlyWindowName: '_self',
  )) {
    throw Exception('Could not launch $url');
  }
}

Future<TokenResponse> authentication(
  Uri uri,
  String clientId,
  List<String> scopes,
) async {
  // create the client
  final issuer = await Issuer.discover(uri);
  final client = Client(issuer, clientId);

  // create an authenticator
  final authenticator = Authenticator(client, scopes: scopes);

  // Our current app URL
  final currentUri = Uri.base;

// Generate the URL redirection to our static.html page
  final redirectUri = Uri(
    host: currentUri.host,
    scheme: currentUri.scheme,
    port: currentUri.port,
    path: '/callback.html',
  );

  authenticator.flow.redirectUri = redirectUri;

  // get the credential
  final credential = await authenticator.credential;

  return credential == null
      ? await authenticator.authorizeWithPopup()
      : await credential.getTokenResponse();
}

Future<void> logout(
  Uri uri,
  _,
  String? redirectString,
) async {
  final redirectUri =
      '${uri.toString()}/protocol/openid-connect/logout?redirect_uri=$redirectString';
  final encodedRedirectUri = Uri.encodeComponent(redirectUri);
  final baseUri = Uri(
    scheme: Uri.base.scheme,
    host: Uri.base.host,
    port: Uri.base.port,
  );
  await _launchURL(
    '${baseUri.toString()}/logout.html?redirect_uri=$encodedRedirectUri',
  );
}

extension AetherAuthenticatorExtensions on Authenticator {
  Future<TokenResponse> authorizeWithPopup({
    int popupHeight = 640,
    int popupWidth = 480,
  }) async {
    _forgetCredentials();
    final localStorage = html.window.localStorage;
    localStorage['openid_client:state'] = flow.state;
    final screenAvailable = html.window.screen?.available;

    final top = (html.window.outerHeight - popupHeight) / 2 +
        (screenAvailable?.top ?? 0);
    final left = (html.window.outerWidth - popupWidth) / 2 +
        (screenAvailable?.left ?? 0);

    final options =
        'width=$popupWidth,height=$popupHeight,toolbar=no,location=no,directories=no,status=no,menubar=no,copyhistory=no&top=$top,left=$left';

    // ignore: unsafe_html
    final child = html.window.open(
      flow.authenticationUri.toString(),
      'aether_passport',
      options,
    );

    final event = await html.window.onMessage.first;
    final url = event.data.toString();
    final uri = Uri(query: Uri.parse(url).fragment);
    final queryParameters = uri.queryParameters;
    final response = TokenResponse.fromJson(queryParameters);

    localStorage['openid_client:auth'] = json.encode(queryParameters);

    child.close();

    return response;
  }

  void _forgetCredentials() {
    html.window.localStorage
      ..remove('openid_client:state')
      ..remove('openid_client:auth');
  }
}
