import 'package:flutter/material.dart';

import 'place_form.dart';

class AddPlace extends StatelessWidget {
  final double _lat;
  final double _lng;
  final Function _addMarker;

  AddPlace(this._lat, this._lng, this._addMarker);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff757575),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: PlaceForm(_lat, _lng, _addMarker),
      ),
    );
  }
}
