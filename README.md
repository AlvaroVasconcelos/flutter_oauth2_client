# flutter_oauth2_client

flutter oauth2 client package project.

## Getting Started

**Example**
~~~dart
      var tokenResponse = await FlutterOAuth2Client.authenticate(
          uri: Uri.parse('http://localhost:8080/auth/realms/aether-passport'),
          clientId: 'aether-billing',
          scopes: ['email', 'profile']);

      print(tokenResponse.idTokenString);

      //Logout:

      Uri base = Uri(
        scheme: Uri.base.scheme,
        host: Uri.base.host,
        port: Uri.base.port,
      );

      await FlutterOAuth2Client.logout(
        uri: Uri.parse('http://localhost:8080/auth/realms/aether-passport'),
        idTokenString: tokenRepoponse, //mobile only
        redirectString: base.toString(), //web only
      );
~~~


**For Web**:
1. Copy callback.html and place inside web root folder.
2. Copy logout.html and place inside web root folder.



