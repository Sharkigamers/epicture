import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_app/model/client.dart';
import 'package:http/http.dart' as http;

import 'package:image_picker/image_picker.dart';

import 'package:loading_animations/loading_animations.dart';

class UploadPicture extends StatefulWidget {
  final Client currentClient;

  UploadPicture(this.currentClient);

  @override
  _UploadPictureState createState() => _UploadPictureState();
}

class _UploadPictureState extends State<UploadPicture> {
  Map _data = {};
  Client _currentClient;
  File _image;
  String _filedTitle;
  String _filedDescription;
  bool waitingForResponse = false;
  String indications = "Load a picture";
  String hintTitleText = "Title";
  String hintDescriptionText = "Description";

  @override
  void initState() {
    _currentClient = widget.currentClient;
    super.initState();
  }

  final TextEditingController _multiLineTextFieldController =
      TextEditingController();
  final TextEditingController _singleLineTextFieldController =
  TextEditingController();

  openCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  openGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    _data = ModalRoute.of(context).settings.arguments;
    _currentClient = _data["user"];
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: Colors.orange[600],
        title: Text('Upload a picture'),
        centerTitle: true,
        elevation: 0,
      ),
      body: !waitingForResponse ? _body() : _waitingResponse(),
      floatingActionButtonLocation: !waitingForResponse ? FloatingActionButtonLocation.centerDocked : null,
      floatingActionButton:!waitingForResponse ? _dualButton() : null,
    );
  }

  _body() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(15, 20, 15, 70),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: _image == null ?
                MediaQuery.of(context).size.height / 10
                    : MediaQuery.of(context).size.height / 1.5,
                child: _image == null ? Text(
                  indications,
                  style: indications == "Load a picture" ? TextStyle(color: Colors.white)
                      : indications == "Picture has been successfully sent" ? TextStyle(color: Colors.green, fontWeight: FontWeight.bold)
                      : indications == "Sending a picture has failed" ? TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
                      : TextStyle(color: Colors.orange[600], fontWeight: FontWeight.bold),
                ) : Image.file(_image),
              ),
              _description()
            ],
          ),
        ),
      ),
    );
  }

  _dualButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 25.0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FloatingActionButton.extended(
              heroTag: "cameraButton",
              elevation: 10.0,
              icon: const Icon(Icons.camera),
              label: const Text('Camera'),
              backgroundColor: Colors.orange[600],
              onPressed: () {
                openCamera();
              },
            ),
            FloatingActionButton.extended(
              heroTag: "galleryButton",
              elevation: 10.0,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Gallery'),
              backgroundColor: Colors.orange[600],
              onPressed: () {
                openGallery();
              },
            )
          ]),
    );
  }

  _description() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _descirptionZone(),
            ),
          ],
        ),
      ),
    );
  }

  _descirptionZone() {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextField(
            controller: _singleLineTextFieldController,
            maxLines: 1,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hintTitleText,
              hintStyle: hintTitleText == "Title" ? TextStyle(color: Colors.white)
                  : TextStyle(color: Colors.orange[600], fontWeight: FontWeight.bold),
            ),
            onChanged: (str) => _filedTitle =  "$str",
          ),
          TextField(
            controller: _multiLineTextFieldController,
            maxLines: 7,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hintDescriptionText,
              hintStyle: hintDescriptionText == "Description" ? TextStyle(color: Colors.white)
                  : TextStyle(color: Colors.orange[600], fontWeight: FontWeight.bold),
            ),
            onChanged: (str) => _filedDescription = str,
            onSubmitted: (str) {
              _filedDescription = str;
            },
          ),
          SizedBox(height: 10),
          FlatButton(
            textColor: Colors.white,
            onPressed: () {
              setState(() {
                if (_image == null)
                  indications = "You need to load a correct picture";
                else if (_filedTitle == null)
                  hintTitleText = "You need a title";
                else if (_filedDescription == null)
                  hintDescriptionText = "You need a description";
                else {
                  waitingForResponse = true;
                  postRequest(_currentClient, _image, _filedDescription, _filedTitle);
                  _image = null;
                  _filedDescription = null;
                  _filedTitle = null;
                  indications = "Load a picture";
                  hintTitleText = "Title";
                  hintDescriptionText = "Description";
                  _multiLineTextFieldController.clear();
                  _singleLineTextFieldController.clear();
                }
              });
            },
            child: const Text("Submit"),
          )
        ],
      ),
    );
  }

  _waitingResponse() {
    return Scaffold(
      backgroundColor: Colors.grey[850],
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

  Future<bool> postRequest(Client client, File file, String description, String title) async {
    var url = "https://api.imgur.com/3/image";

    List<int> imageBytes = file.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);

    var response = await http.post(url,
        headers: {
          "Authorization": "Bearer " + client.accessToken,
        },
        body: {
          "title": title,
          "description": description,
          "image": base64Image,
        });

    if (response.statusCode == 200) {
      // Create album with newly uploaded image

      final responseData = json.decode(response.body);
      var urlAlbum = "https://api.imgur.com/3/album";

      print(responseData);
      var responseAlbum = await http.post(urlAlbum,
          headers: {
            "Authorization": "Bearer " + client.accessToken,
          },
          body: {
            "ids": responseData["data"]["id"],
            "title": title,
            "description": description,
            "cover": responseData["data"]["id"],
          });
      print(responseAlbum.body);
      indications = "Picture has been successfully sent";
    } else
      indications = "Sending a picture has failed";
    setState(() {
      waitingForResponse = false;
    });
  }
}
