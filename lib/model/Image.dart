import 'package:flutter/material.dart';

class Item {
  final String name;
  final String url;
  final String author;
  final String id;
  final bool isFavorite;
  final Image image;

  Item({
    @required this.name,
    @required this.url,
    @required this.author,
    @required this.id,
    @required this.isFavorite,
    @required this.image,
  });

  Item.loading() : this(name: '/loading\\', url: '', author: '', id: '', isFavorite: false, image: null);

  bool get isLoading => name == '/loading\\';
}