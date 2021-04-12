import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../common/common.dart';
import '../../providers/place_provider.dart';

class PlaceForm extends StatefulWidget {
  final double lat;
  final double lng;
  final Function _addMarker;

  PlaceForm(this.lat, this.lng, this._addMarker);

  @override
  _PlaceFormState createState() => _PlaceFormState();
}

class _PlaceFormState extends State<PlaceForm> {
  final _formKey = GlobalKey<FormState>();
  File _imageFile;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  String errMsg = "";

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Form(
            key: _formKey,
            child: Container(
              padding: EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width * 0.85,
              child: ListView(
                children: [
                  //---title---
                  titleForm(),

                  SizedBox(height: 10),

                  //---description---
                  descriptionForm(),

                  SizedBox(height: 15),
                  Container(
                    child: Text(
                      errMsg,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text('Add Place Image:'),
                  Card(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(10),
                          child: _imageFile != null
                              ? Image(
                                  image: FileImage(_imageFile),
                                  //height: 50,
                                )
                              : Container(
                                  height: 200,
                                  color: Colors.grey.withOpacity(0.8),
                                ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          //heightFactor: 0.4,
                          child: FloatingActionButton(
                            backgroundColor: Colors.blueGrey,
                            onPressed: () {
                              _showChoiceDialog(context);
                            },
                            child: Icon(Icons.add_a_photo),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Column(
            children: [
              Container(
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: IconButton(
                  icon: Icon(Icons.save),
                  iconSize: 25,
                  color: Colors.white,
                  onPressed: () async {
                    if (_formKey.currentState.validate() &&
                        _imageFile != null) {
                      addPlace(context);

                      Navigator.pop(context);
                      showFlashDialog(
                          context, "Add Place", "Your place was added!");
                    }
                  },
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: IconButton(
                  iconSize: 28,
                  color: Colors.white,
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 10,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  void addPlace(BuildContext context) async {
    await PlaceProvider()
        .addImageToFireStorage(context, _imageFile)
        .then((imageUrl) async {
      await PlaceProvider()
          .addPlaces(_titleController.text, _descriptionController.text,
              imageUrl, widget.lat, widget.lng)
          .then((plcId) {
        widget._addMarker(plcId, _titleController.text, widget.lat, widget.lng);
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _openCamera(BuildContext context) async {
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    setState(() {
      _imageFile = File(pickedFile.path);
    });
  }


  void _openGallery(BuildContext context) async {
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
    );
    setState(() {
      _imageFile = File(pickedFile.path);
    });
  }

  Future _showChoiceDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Choose option",
              style: TextStyle(color: Colors.blue),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Divider(
                    height: 1,
                    color: Colors.blue,
                  ),
                  ListTile(
                    onTap: () {
                      _openGallery(context);
                      Navigator.pop(context);
                    },
                    title: Text("Gallery"),
                    leading: Icon(
                      Icons.account_box,
                      color: Colors.blue,
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Colors.blue,
                  ),
                  ListTile(
                    onTap: () {
                      _openCamera(context);
                      Navigator.pop(context);
                    },
                    title: Text("Camera"),
                    leading: Icon(
                      Icons.camera,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  TextFormField titleForm() {
    return TextFormField(
      keyboardType: TextInputType.text,
      controller: _titleController,
      validator: (String inputTitle) {
        if (inputTitle.isEmpty) {
          return "Please input title.";
        } else {
          return null;
        }
      },
      decoration: InputDecoration(
        labelText: "Title",
        hintText: "Enter title",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: Icon(
          Icons.place,
          color: Colors.grey[700],
          size: 20.0,
        ),
      ),
    );
  }

  TextFormField descriptionForm() {
    return TextFormField(
      keyboardType: TextInputType.text,
      controller: _descriptionController,
      minLines: 2,
      maxLines: 4,
      validator: (String inputDescription) {
        if (inputDescription.isEmpty) {
          return "Please input description";
        } else {
          return null;
        }
      },
      decoration: InputDecoration(
        labelText: "Description",
        hintText: "Enter description",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: Icon(
          Icons.description,
          color: Colors.grey[700],
          size: 20.0,
        ),
      ),
    );
  }
}
