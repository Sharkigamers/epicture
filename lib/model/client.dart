import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;

class Client {
  String accessToken = "";
  String typeToken = "";
  String refreshToken = "";
  String username = "";
  String id = "";

  int reputation;
  String reputationName;
  String urlPicture = "";

  void parseResponse(String response) {
    this.accessToken = parseAccess(response);
    this.typeToken = parseTypeToken(response);
    this.refreshToken = parseRefreshToken(response);
    this.username = parseUsername(response);
    this.id = parseId(response);

    getUserInfo();
  }

  String parseAccess(String response) {
    const start = "access_token=";
    const end = "&expires_in";

    final startIndex = response.indexOf(start);
    final endIndex = response.indexOf(end, startIndex + start.length);

    return(response.substring(startIndex + start.length, endIndex));
  }

  String parseTypeToken(String response) {
    const start = "token_type=";
    const end = "&refresh_token";

    final startIndex = response.indexOf(start);
    final endIndex = response.indexOf(end, startIndex + start.length);

    return(response.substring(startIndex + start.length, endIndex));
  }

  String parseRefreshToken(String response) {
    const start = "refresh_token=";
    const end = "&account_username";

    final startIndex = response.indexOf(start);
    final endIndex = response.indexOf(end, startIndex + start.length);

    return(response.substring(startIndex + start.length, endIndex));
  }

  String parseUsername(String response) {
    const start = "account_username=";
    const end = "&account_id";

    final startIndex = response.indexOf(start);
    final endIndex = response.indexOf(end, startIndex + start.length);

    return(response.substring(startIndex + start.length, endIndex));
  }

  String parseId(String response) {
    const start = "account_id=";

    final startIndex = response.indexOf(start);

    return(response.substring(startIndex + start.length, response.length));
  }

  void getUserInfo() async {
    var uri = Uri.https('api.imgur.com', '/3/account/$username');
    final response = await http.get(
      uri,
      headers: {HttpHeaders.authorizationHeader: "Client-ID 88f18e549628216"},
    );
    Map<String, dynamic> data = jsonDecode(response.body);

    print(data);

    reputation = data["data"]["reputation"];
    reputationName = data["data"]["reputation_name"];
    urlPicture = data["data"]["avatar"];
  }

}
