import 'dart:io';

import 'package:http/http.dart' as http;
//import the io version
import 'package:openid_client/openid_client_io.dart';
// use url launcher package
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<TokenResponse> authentication(
  Uri uri,
  String clientId,
  List<String> scopes,
) async {
  // create the client
  final issuer = await Issuer.discover(uri);
  final client = Client(issuer, clientId);

  Future<void> urlLauncher(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(
        url,
        webViewConfiguration:
            const WebViewConfiguration(enableJavaScript: true),
      );
    } else {
      throw Exception('Could not launch $url');
    }
  }

  // create an authenticator
  final authenticator = Authenticator(
    client,
    scopes: scopes,
    port: 4000,
    urlLancher: urlLauncher,
  );

  // starts the authentication
  final credential = await authenticator.authorize();

  // close the webview when finished
  if (!Platform.isWindows) {
    await closeInAppWebView();
  }

  // return the user info
  return credential.getTokenResponse();
}

Future<void> logout(
  Uri uri,
  String? idTokenString,
  _,
) async {
  final url = Uri.parse(
    '${uri.toString()}/protocol/openid-connect/logout?id_token_hint=$idTokenString',
  );
  await http.get(url);
}
