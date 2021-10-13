import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'package:flutter_app/model/client.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final flutterWebviewPlugin = new FlutterWebviewPlugin();

  StreamSubscription _onDestroy;
  StreamSubscription<String> _onUrlChanged;
  StreamSubscription<WebViewStateChanged> _onStateChanged;

  String token;
  Client currentClient;

  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.
    _onDestroy.cancel();
    _onUrlChanged.cancel();
    _onStateChanged.cancel();
    flutterWebviewPlugin.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    //flutterWebviewPlugin.close();

    // Add a listener to on destroy WebView, so you can make came actions.
    _onDestroy = flutterWebviewPlugin.onDestroy.listen((_) {
      print("destroy");
    });

    _onStateChanged = flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      if (mounted) {
        setState(() {
          if (!state.url.startsWith("https://api.imgur.com/oauth2/authorize?")) {
            currentClient = new Client();
            currentClient.parseResponse(state.url);
            Navigator.pushReplacementNamed(context, '/home',
                arguments: {'user': currentClient});
            flutterWebviewPlugin.close();
          }
        });
      }
    });

    // Add a listener to on url changed
    _onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if (mounted) {
        setState(() {
          if (!url.startsWith("https://api.imgur.com/oauth2/authorize?")) {
            print(url);
            currentClient = new Client();
            currentClient.parseResponse(url);
            Navigator.pushReplacementNamed(context, '/home',
                arguments: {'user': currentClient});
            flutterWebviewPlugin.close();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String loginUrl =
        "https://api.imgur.com/oauth2/authorize?client_id=88f18e549628216&response_type=token";

    return new WebviewScaffold(
      url: loginUrl,
      mediaPlaybackRequiresUserGesture: false,
      appBar: new AppBar(
        title: new Text("Login to Imgur..."),
      ),
      hidden: true,
    );
  }
}
