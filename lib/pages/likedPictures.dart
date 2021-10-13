import 'package:flutter/material.dart';
import 'package:flutter_app/model/client.dart';

import 'package:flutter_app/pages/mainDisplay.dart';

class LikedPictures extends StatefulWidget {
  final Client currentClient;

  LikedPictures(this.currentClient);

  @override
  _LikedPicturesState createState() => _LikedPicturesState();
}

class _LikedPicturesState extends State<LikedPictures> {
  Client _currentClient;

  @override
  void initState() {
    _currentClient = widget.currentClient;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: Colors.orange[600],
        title: Text('My favorites'),
        centerTitle: true,
        elevation: 0,
      ),
      body: MainDisplay(_currentClient, "favorite")
    );
  }
}
