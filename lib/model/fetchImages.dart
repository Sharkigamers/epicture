import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/model/Image.dart';
import 'package:flutter_app/model/ImagePage.dart';

import 'package:flutter_app/model/client.dart';

const catalogLength = 200;

int currentIndex = 0;
int imageCount = 0;

int currentHomeIndex = 0;
int imageHomeCount = 0;

int currentFavoriteIndex = 0;
int imageFavoriteCount = 0;

int currentProfileIndex = 0;
int imageProfileCount = 0;

T cast<T>(x) => x is T ? x : null;

Future<ItemPage> fetchPage(Client client, String query, String searchParameters) async {
  var queryParameters = {
    'q': query,
  };
  print(query);
  var uri = Uri.https(
      'api.imgur.com', '/3/gallery/search/$currentIndex', queryParameters);
  final response = await http.get(
    uri,
    headers: {HttpHeaders.authorizationHeader: "Client-ID 88f18e549628216"},
  );

  Map<String, dynamic> data = jsonDecode(response.body);
  List<dynamic> values = data["data"];

  List<Item> lstItems = new List<Item>();

  print(data);

  values.forEach((element) {
    Map<String, dynamic> newData = cast<Map<String, dynamic>>(element);
    if (newData["is_album"] == true) {
      List<dynamic> images = newData["images"];

      images.forEach((image) {
        imageCount += 1;
        if (imageCount % 20 == 1) {
          currentIndex += 1;
        }
        Map<String, dynamic> newImage = cast<Map<String, dynamic>>(image);

        if (newImage["type"] != "video/mp4") {
          lstItems.add(Item(
              name: newImage["title"],
              url: newImage["link"],
              id: newImage["id"],
              author: newData["account_url"],
              isFavorite: newData["favorite"]));
        }
      });
    } else {
      if (newData["type"] != "video/mp4") {
        lstItems.add(Item(
            name: newData["title"],
            url: newData["link"],
            id: newData["id"],
            author: newData["account_url"],
            isFavorite: newData["favorite"]));
      }
    }
  });

  // The page of items is generated here.
  return ItemPage(
    items: lstItems,
    startingIndex: 0,
    // Returns `false` if we've reached the [catalogLength].
    hasNext: 0 + itemsPerPage < catalogLength,
    maxItems: -1,
  );
}

Future<ItemPage> getHomePage(Client client, String moreParameters) async {
  var uri = Uri.https('api.imgur.com', '/3/gallery/' + moreParameters + '/$currentHomeIndex');
  final response = await http.get(
    uri,
    headers: {HttpHeaders.authorizationHeader: "Client-ID 88f18e549628216"},
  );

  Map<String, dynamic> data = jsonDecode(response.body);
  List<dynamic> values = data["data"];

  List<Item> lstItems = new List<Item>();

  values.forEach((element) {
    Map<String, dynamic> newData = cast<Map<String, dynamic>>(element);
    if (newData["is_album"] == true) {
      List<dynamic> images = newData["images"];

      images.forEach((image) {
        imageHomeCount += 1;
        if (imageHomeCount % 20 == 1) {
          currentHomeIndex += 1;
        }
        Map<String, dynamic> newImage = cast<Map<String, dynamic>>(image);
        if (newImage["type"] != "video/mp4") {
          lstItems.add(Item(
              name: newData["title"],
              url: newImage["link"],
              id: newImage["id"],
              author: newData["account_url"],
              isFavorite: newData["favorite"]));
        }
      });
    } else {
      if (newData["type"] != "video/mp4") {
        lstItems.add(Item(
            name: newData["title"],
            url: newData["link"],
            id: newData["id"],
            author: newData["account_url"],
            isFavorite: newData["favorite"]));
      }
    }
  });

  // The page of items is generated here.
  return ItemPage(
    items: lstItems,
    startingIndex: 0,
    // Returns `false` if we've reached the [catalogLength].
    hasNext: 0 + itemsPerPage < catalogLength,
    maxItems: -1,
  );
}

Future<ItemPage> getFavoriteImages(Client client) async {
  final username = client.username;
  final token = client.accessToken;

  var uri = Uri.https('api.imgur.com', '/3/account/$username/favorites/$currentFavoriteIndex');
  final response = await http.get(
    uri,
    headers: {HttpHeaders.authorizationHeader: "Bearer $token"},
  );

  Map<String, dynamic> data = jsonDecode(response.body);
  List<dynamic> values = data["data"];

  List<Item> lstItems = new List<Item>();

  values.forEach((element) async {
    Map<String, dynamic> newData = cast<Map<String, dynamic>>(element);
    if (newData["is_album"] == true) {
      List<dynamic> images = newData["images"];

      if (images != null) {
        images.forEach((image) {
          imageFavoriteCount += 1;
          if (imageFavoriteCount % 20 == 1) {
            currentFavoriteIndex += 1;
          }
          Map<String, dynamic> newImage = cast<Map<String, dynamic>>(image);
          print(newData);

          if (newImage["type"] != "video/mp4") {
            lstItems.add(Item(
                name: newData["title"],
                url: newImage["link"],
                id: newImage["id"],
                author: newData["account_url"],
                isFavorite: newData["favorite"]));
          }
        });
      } else {
        var albumHash = newData["id"];
        var newUrl = Uri.https('api.imgur.com', '/3/gallery/album/$albumHash');
        final newResponse = await http.get(
          uri,
          headers: {HttpHeaders.authorizationHeader: "Client-ID 88f18e549628216"},
        );

        Map<String, dynamic> albumData = jsonDecode(response.body);
        List<dynamic> albumValues = albumData["data"];

        if (albumData["data"][0]["type"] != "video/mp4") {
          lstItems.add(Item(
              name: albumData["data"][0]["title"],
              url: albumData["data"][0]["link"],
              id: albumData["data"][0]["id"],
              author: albumData["data"][0]["account_url"],
              isFavorite: albumData["data"][0]["favorite"]));
        }
      }
    } else {
      if (newData["type"] != "video/mp4") {
        lstItems.add(Item(
            name: newData["title"],
            url: newData["link"],
            id: newData["id"],
            author: newData["account_url"],
            isFavorite: newData["favorite"]));
      }
    }
  });

  // The page of items is generated here.
  return ItemPage(
    items: lstItems,
    startingIndex: 0,
    // Returns `false` if we've reached the [catalogLength].
    hasNext: 0 + itemsPerPage < catalogLength,
    maxItems: lstItems.length,
  );
}

Future<ItemPage> getProfileImages(Client client) async {
  final token = client.accessToken;
  var uri = Uri.https('api.imgur.com', '/3/account/me/images');
  final response = await http.get(
    uri,
    headers: {HttpHeaders.authorizationHeader: "Bearer $token"},
  );

  Map<String, dynamic> data = jsonDecode(response.body);
  List<dynamic> values = data["data"];

  List<Item> lstItems = new List<Item>();

  values.forEach((element) {
    Map<String, dynamic> newData = cast<Map<String, dynamic>>(element);
    if (newData["is_album"] == true) {
      List<dynamic> images = newData["images"];

      images.forEach((image) {
        imageProfileCount += 1;
        if (imageProfileCount % 20 == 1) {
          currentProfileIndex += 1;
        }
        Map<String, dynamic> newImage = cast<Map<String, dynamic>>(image);
        print(newData);

        if (newImage["type"] != "video/mp4") {
          lstItems.add(Item(
              name: newData["title"],
              url: newImage["link"],
              id: newImage["id"],
              author: newData["account_url"],
              isFavorite: newData["favorite"]));
        }
      });
    } else {
      if (newData["type"] != "video/mp4") {
        lstItems.add(Item(
            name: newData["title"],
            url: newData["link"],
            id: newData["id"],
            author: newData["account_url"],
            isFavorite: newData["favorite"]));
      }
    }
  });

  // The page of items is generated here.
  return ItemPage(
    items: lstItems,
    startingIndex: 0,
    // Returns `false` if we've reached the [catalogLength].
    hasNext: 0 + itemsPerPage < catalogLength,
    maxItems: lstItems.length,
  );
}

Future<void> favoriteImage(Client client, Item image) async {
  String imageId = image.id;
  print(client.typeToken + " " + client.accessToken);
  Map<String, String> header = {};

  header["Authorization"] = "Bearer " + client.accessToken;
  final response = await http
      .post("https://api.imgur.com/3/image/$imageId/favorite", headers: header);
  if (response.statusCode != 200) {
    print(response.body);
  }
}

Future<List<ItemPage>> fetchAllPages(Client client, String url) async {}
