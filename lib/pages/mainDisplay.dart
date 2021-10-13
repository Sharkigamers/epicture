import 'package:flutter/material.dart';
import 'package:flutter_app/model/fetchImages.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/model/client.dart';

import 'package:flutter_app/model/ImageList.dart';
import 'package:flutter_app/model/ImageTitle.dart';
import 'package:flutter_app/model/Image.dart';

class Constants {
  static const String top = "top";
  static const String hot = "hot";

  static const String virtual = "viral";
  static const String time = "time";

  static const String day = "day";
  static const String week = "week";
  static const String month = "month";
  static const String year = "year";
  static const String all = "all";

  static const List<String> choicesSection = <String>[
    hot,
    top,
  ];

  static const List<String> choicesSort = <String>[
    virtual,
    top,
    time,
  ];

  static const List<String> choicesWindow = <String>[
    day,
    week,
    month,
    year,
    all,
  ];
}

class ButtonFavorite extends StatefulWidget {
  final Client _currentClient;
  final Item item;

  ButtonFavorite(this._currentClient, this.item);

  @override
  _ButtonFavoriteState createState() => new _ButtonFavoriteState();
}

class _ButtonFavoriteState extends State<ButtonFavorite> {
  Client _currentClient;
  Item item;
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    _currentClient = widget._currentClient;
    item = widget.item;
    return new FlatButton(
      child: Icon(
        (item.isFavorite == true || isPressed == true)
            ? Icons.favorite
            : Icons.favorite_border_outlined,
        color: Colors.red,
        size: 30,
      ),
      onPressed: () {
        setState(() {
          favoriteImage(_currentClient, item);
          isPressed = !isPressed;
        });
      },
    );
  }
}

class MainDisplay extends StatefulWidget {
  final Client currentClient;
  final String arg;

  MainDisplay(this.currentClient, this.arg);

  @override
  _MainDisplayState createState() => _MainDisplayState();
}

class _MainDisplayState extends State<MainDisplay> {
  Client _currentClient;
  String _arg;
  bool isSearching = false;
  bool isLookingPicture = false;
  Item _currentItem;
  String _searchParameters;
  String _searchString = "";
  String choiceSection = "hot";
  String choiceSort = "viral";
  String choiceWindow = "day";
  String _moreParameters = "hot/viral/day";

  bool _toClear = false;

  @override
  void initState() {
    _currentClient = widget.currentClient;
    _arg = widget.arg;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isLookingPicture ? _appBarLookingSpecificPicture() : null,
      body: isLookingPicture ? _spePicture() : _imageContainer(),
    );
  }

  _imageContainer() {
    return ChangeNotifierProvider<ImageList>(
      create: (context) => ImageList(),
      child: MaterialApp(
        title: 'Infinite List Sample',
        home: Scaffold(
          appBar: _arg == "home" || _arg == "search" ? _appBar() : null,
          body: _pictureDisplayer(),
          backgroundColor: Colors.grey[850],
        ),
      ),
    );
  }

  _pictureDisplayer() {
    return Selector<ImageList, int>(
      selector: (context, catalog) => catalog.itemCount,
      builder: (context, itemCount, child) => ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          var catalog = Provider.of<ImageList>(context);
          if (_toClear == true) {
            _toClear = false;
            catalog.clear();
          }
          var item;
          switch (_arg) {
            case "home":
              item = catalog.getHomeByIndex(
                  _currentClient, _moreParameters, index);
              break;
            case "favorite":
              item = catalog.getFavoriteByIndex(_currentClient, index);
              break;
            case "search":
              item = catalog.getSearchByIndex(
                  _currentClient, _searchString, choiceSort + "/" + choiceWindow, index);
              break;
            case "profile":
              item = catalog.getProfileImageByIndex(_currentClient, index);
              break;
            default:
              item = catalog.getHomeByIndex(
                  _currentClient, _moreParameters, index);
              break;
          }

          if (item.isLoading) {
            return LoadingItemTile();
          }


          return Column(
            children: [
              _topPictureDisplay(item),
              FlatButton(
                child: ItemTile(item: item),
                onPressed: () {
                  setState(() {
                    _currentItem = item;
                    isLookingPicture = true;
                  });
                },
              ),
              _bottomPictureButton(item, true),
            ],
          );
        },
      ),
    );
  }

  _topPictureDisplay(Item currentItem) {
    return Align(
      alignment: FractionalOffset(0.01, 0.6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(5.0, 10.0, 10.0, 5.0),
            child: CircleAvatar(
              //backgroundImage: NetworkImage(currentItem.urlAuthor),
              radius: 15,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width - 60,
                  child: Text(
                    currentItem.author == null
                        ? "Unknown Author"
                        : currentItem.author,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width - 60,
                  child: Text(
                    currentItem.name == null ? "" : currentItem.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _favoriteButton(Item currentItem) {
    return ButtonFavorite(_currentClient, currentItem);
  }

  _bottomPictureButton(Item currentItem, bool mainPage) {
    return Column(
      children: [
        _favoriteButton(currentItem),
        if (mainPage) ...[
          SizedBox(
            height: 20.0,
          ),
          Container(
            height: 2,
            width: 300,
            decoration: BoxDecoration(
              border: Border.all(width: 1.0),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
        SizedBox(
          height: 20.0,
        ),
      ],
    );
  }

  _appBar() {
    return new AppBar(
      backgroundColor: Colors.orange[600],
      title: !isSearching
          ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  setState(() {
                    _arg = "home";
                    _toClear = true;
                  });
                },
                child: Text(
                  'ImgurHub',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                )
              )
            ]
          ) : TextField(
              onSubmitted: (str) {
                print("$str");
                setState(() {
                  _searchString = str;
                  _searchParameters =
                      choiceSort + "/" + choiceWindow;
                  _arg = "search";
                  _toClear = true;
                  MainDisplay(_currentClient, "search");
                  isSearching = false;
                });
              },
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  hintText: "Category",
                  hintStyle: TextStyle(color: Colors.white),
                  icon: Icon(
                    Icons.search,
                    color: Colors.white,
                  )),
            ),
      centerTitle: true,
      elevation: 0,
      actions: <Widget>[
        isSearching
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    isSearching = false;
                  });
                })
            : IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    isSearching = true;
                  });
                }),
        if (_arg == "home") ...[
          _popUpChoiceSection(),
        ],
        _popUpChoiceSort(),
        _popUpChoiceWindow(),
      ],
    );
  }

  _appBarLookingSpecificPicture() {
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
      title: Text('Specific picture'),
      centerTitle: true,
      elevation: 0,
    );
  }

  _spePicture() {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 5.0),
              child: _topPictureDisplay(_currentItem),
            ),
            ItemTile(item: _currentItem),
            _bottomPictureButton(_currentItem, false),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  child: Text(
                    _currentItem.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _popUpChoiceSection() {
    return PopupMenuButton<String>(
      onSelected: _choiceActionSection,
      itemBuilder: (BuildContext context) {
        return Constants.choicesSection.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: RichText(
              text: TextSpan(children: [
                TextSpan(text: choice, style: TextStyle(color: Colors.black)),
                WidgetSpan(
                    child: SizedBox(
                  width: 20,
                )),
                choiceSection == choice
                    ? WidgetSpan(
                        child: Icon(
                          Icons.check,
                          color: Colors.black,
                        ),
                      )
                    : WidgetSpan(
                        child: SizedBox(
                        width: 0,
                      )),
              ]),
            ),
          );
        }).toList();
      },
    );
  }

  _popUpChoiceSort() {
    return PopupMenuButton<String>(
      onSelected: _choiceActionSort,
      itemBuilder: (BuildContext context) {
        return Constants.choicesSort.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: RichText(
              text: TextSpan(children: [
                TextSpan(text: choice, style: TextStyle(color: Colors.black)),
                WidgetSpan(
                    child: SizedBox(
                  width: 20,
                )),
                choiceSort == choice
                    ? WidgetSpan(
                        child: Icon(
                          Icons.check,
                          color: Colors.black,
                        ),
                      )
                    : WidgetSpan(
                        child: SizedBox(
                        width: 0,
                      )),
              ]),
            ),
          );
        }).toList();
      },
    );
  }

  _popUpChoiceWindow() {
    return PopupMenuButton<String>(
      onSelected: _choiceActionWindow,
      itemBuilder: (BuildContext context) {
        return Constants.choicesWindow.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: RichText(
              text: TextSpan(children: [
                TextSpan(text: choice, style: TextStyle(color: Colors.black)),
                WidgetSpan(
                    child: SizedBox(
                  width: 20,
                )),
                choiceWindow == choice
                    ? WidgetSpan(
                        child: Icon(
                          Icons.check,
                          color: Colors.black,
                        ),
                      )
                    : WidgetSpan(
                        child: SizedBox(
                        width: 0,
                      )),
              ]),
            ),
          );
        }).toList();
      },
    );
  }

  _choiceActionSection(String choice) {
    choiceSection = choice;
    _moreParameters = choiceSection + "/" + choiceSort + "/" + choiceWindow + "/";
  }

  _choiceActionSort(String choice) {
    choiceSort = choice;
    _moreParameters = choiceSection + "/" + choiceSort + "/" + choiceWindow + "/";
    _searchParameters = _searchString + "/" + choiceSort + "/" + choiceWindow + "/";
  }

  _choiceActionWindow(String choice) {
    choiceWindow = choice;
    _moreParameters = choiceSection + "/" + choiceSort + "/" + choiceWindow + "/";
    _searchParameters = _searchString + "/" + choiceSort + "/" + choiceWindow + "/";
  }
}
