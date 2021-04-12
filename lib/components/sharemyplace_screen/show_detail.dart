import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import '../common/common.dart';
import '../../providers/place_provider.dart';

class ShowPlaceDetail extends StatelessWidget {
  final String _placeId;
  final String _title;
  final String _description;
  final String _imageUrl;
  final double _lat;
  final double _lng;
  final Function _setDestination;
  final Function _removeMarker;

  ShowPlaceDetail(this._placeId, this._title, this._description, this._imageUrl,
      this._lat, this._lng, this._setDestination, this._removeMarker);

  _openOnGoogleMapApp() async {
    String googleUrl = DotEnv.env['google_url'] + '$_lat,$_lng';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      print('Could not open $googleUrl on google map.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff757575),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.90,
                padding: EdgeInsets.all(30),
                child: ListView(
                  children: [
                    Container(
                      width: double.infinity,
                      child: Text(
                        '$_title',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      width: double.infinity,
                      //height: 170,
                      child: Image.network(
                        _imageUrl,
                        fit: BoxFit.fill,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: double.infinity,
                      child: Text(
                        '$_description',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.map),
                        iconSize: 35,
                        color: Colors.white,
                        onPressed: () async {
                          _openOnGoogleMapApp();
                        },
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.place),
                        color: Colors.white,
                        iconSize: 35,
                        onPressed: () {
                          _setDestination(LatLng(_lat, _lng));
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: IconButton(
                        iconSize: 35,
                        color: Colors.white,
                        onPressed: () {
                          PlaceProvider()
                              .removePlaces(_placeId)
                              .then((value) => _removeMarker(_placeId));
                          Navigator.pop(context);
                          showFlashDialog(context, "Remove Place",
                              "Your place was removed!");
                        },
                        icon: Icon(Icons.cancel),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: IconButton(
                        iconSize: 35,
                        color: Colors.white,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
