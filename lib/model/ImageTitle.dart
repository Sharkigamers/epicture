import 'package:flutter/material.dart';

import 'package:flutter_app/model/Image.dart';
import 'package:flutter_app/model/client.dart';

import 'package:loading_animations/loading_animations.dart';

/// This is the widget responsible for building the item in the list,
/// once we have the actual data [item].
class ItemTile extends StatelessWidget {
  final Item item;

  ItemTile({@required this.item, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Container(
        child: Image.network(item.url, fit: BoxFit.fitWidth)
      ),
    );
  }
}

/// This is the widget responsible for building the "still loading" item
/// in the list (represented with "..." and a crossed square).
class LoadingItemTile extends StatelessWidget {
  const LoadingItemTile({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
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