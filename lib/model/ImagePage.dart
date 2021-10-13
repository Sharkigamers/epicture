import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'package:flutter_app/model/Image.dart';

const int itemsPerPage = 30;

class ItemPage {
  final List<Item> items;

  final int startingIndex;

  final bool hasNext;

  final int maxItems;

  ItemPage({
    @required this.items,
    @required this.startingIndex,
    @required this.hasNext,
    @required this.maxItems,
  });
}