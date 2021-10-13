import 'package:flutter/material.dart';

import 'package:loading_animations/loading_animations.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: <Widget>[
            Center(
              child: LoadingBouncingGrid.square(
                backgroundColor: Colors.orange[600],
                size: 70.0,
              ),
            ),
          ]
      ),
    );
  }
}

