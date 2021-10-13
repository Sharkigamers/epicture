import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import 'package:flutter_app/pages/showProfile.dart';
import 'package:flutter_app/pages/upload_picture.dart';
import 'package:flutter_app/pages/likedPictures.dart';
import 'package:flutter_app/pages/mainDisplay.dart';

import 'package:flutter_app/model/client.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Client currentClient;
  Map data = {};
  List<Widget> _bodies = [];
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context).settings.arguments;
    currentClient = data["user"];

    _bodies = [
      MainDisplay(currentClient, "home"),
      UploadPicture(currentClient),
      LikedPictures(currentClient),
      ShowProfile(currentClient),
    ];

    print(_index);
    return Scaffold(
      body: _bodies[_index],
      bottomNavigationBar: _bottomBar(context, currentClient),
    );
  }

  _bottomBar(BuildContext context, Client currentClient) {
    return CurvedNavigationBar(
      height: 50,
      color: Colors.orange[600],
      backgroundColor: Colors.grey[850],
      buttonBackgroundColor: Colors.orange[600],
      items: <Widget>[
        Icon(
          Icons.home_filled,
          size: 20,
          color: Colors.black,
        ),
        Icon(
          Icons.add,
          size: 20,
          color: Colors.black,
        ),
        Icon(
          Icons.favorite,
          size: 20,
          color: Colors.black,
        ),
        Icon(
          Icons.list,
          size: 20,
          color: Colors.black,
        ),
      ],
      animationDuration: Duration(
        milliseconds: 200,
      ),
      index: _index,
      onTap: (index) {
        _index = index;
        setState(() {});
      },
    );
  }
}
