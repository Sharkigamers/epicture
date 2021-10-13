import 'package:flutter_app/model/client.dart';
import 'package:flutter/material.dart';

import 'package:flutter_app/pages/mainDisplay.dart';

class ShowProfile extends StatefulWidget {
  final Client currentClient;

  ShowProfile(this.currentClient);

  @override
  _ShowProfileState createState() => _ShowProfileState();
}

class _ShowProfileState extends State<ShowProfile> {
  Client _currentClient;
  bool isLookingPicture = false;

  @override
  void initState() {
    _currentClient = widget.currentClient;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: isLookingPicture ? _appBarLookingPersonalPicture() : null,
      body: _profileContainer(),
    );
  }

  _profileContainer() {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange[600],
              Colors.pinkAccent,
              Colors.deepPurpleAccent,
              Colors.grey[850],
            ],
          )
      ),
      child: !isLookingPicture ? _profileBox() : MainDisplay(_currentClient, "profile"),
    );
  }

  _profileBox() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              backgroundImage: NetworkImage(_currentClient.urlPicture),
              radius: 50,
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              _currentClient.username,
              style: TextStyle(
                fontSize: 22.0,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            _informationsProfile(),
            SizedBox(
              height: 40.0,
            ),
            _buttonPictures(),
          ],
        ),
      ),
    );
  }

  _informationsProfile() {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 8.0,
      ),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      elevation: 8.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 22.0, horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Text(
                    "Reputation",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    _currentClient.reputation.toString(),
                    style: TextStyle(
                        color: Colors.orange[600],
                        fontSize: 20.0,
                        fontWeight: FontWeight.w400
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Text(
                    "Type",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    _currentClient.reputationName,
                    style: TextStyle(
                        color: Colors.orange[600],
                        fontSize: 20.0,
                        fontWeight: FontWeight.w400
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buttonPictures() {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 8.0,
      ),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      elevation: 8.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
        child: FlatButton(
          height: 100,
          onPressed: () {
            setState(() {
              isLookingPicture = true;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "My pictures",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 24,
                  fontWeight: FontWeight.bold
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _appBarLookingPersonalPicture() {
    return AppBar(
      backgroundColor: Colors.orange[600],
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.clear,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              isLookingPicture = false;
            });
          }
        ),
      ],
      title: Text('My pictures'),
      centerTitle: true,
      elevation: 0,
    );
  }
}
