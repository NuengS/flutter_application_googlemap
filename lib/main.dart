import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

import 'network.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Polygon> _polygons = HashSet<Polygon>();

  Set<Polyline> polyLines = {};
  List<LatLng> polyPoints = [];
  var data;

  BitmapDescriptor csLocationIcon;
  LocationData currentLocation;

  Set<Marker> _markers = {};

  Location location;
  BitmapDescriptor sourceIcon;

  @override
  void initState() {
    super.initState();

    location = new Location();

    location.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
      updatePinOnMap();
      print(currentLocation.latitude);
      print(currentLocation.longitude);
    });
    _setCurrentLationIcons();
    _setCustomMapPin();
    _setPolygonsCS();
    _getJsonData();
  }

  void _setCurrentLationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'images/driving_pin.png');
  }

  void _setCustomMapPin() async {
    currentLocation = await getCurrentLocation();
    csLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'images/logocomsci.jpg');
  }

  void _setPolygonsCS() {
    // ignore: deprecated_member_use
    List<LatLng> polygonLatLongsCS = List<LatLng>();
    polygonLatLongsCS.add(LatLng(7.167031636560606, 100.61265602322639));
    polygonLatLongsCS.add(LatLng(7.166943815238209, 100.61303823800192));
    polygonLatLongsCS.add(LatLng(7.166845348886892, 100.61301946253927));
    polygonLatLongsCS.add(LatLng(7.16691720271293, 100.61263456555477));

    _polygons.add(
      Polygon(
          polygonId: PolygonId("0"),
          points: polygonLatLongsCS,
          fillColor: Colors.orangeAccent,
          strokeWidth: 3,
          strokeColor: Colors.black),
    );
  }

  void updatePinOnMap() async {
/*     CameraPosition cPosition = CameraPosition(
      zoom: 16,
      //tilt: CAMERA_TILT,
      //bearing: CAMERA_BEARING,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition)); */

    setState(() {
      // updated position
      var pinPosition =
          LatLng(currentLocation.latitude, currentLocation.longitude);

      _markers.removeWhere((m) => m.markerId.value == 'sourcePin');
      _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: pinPosition,
        icon: sourceIcon,
        infoWindow:
            InfoWindow(title: "Current Location", snippet: "I am here now!"),
        //icon: BitmapDescriptor.defaultMarkerWithHue(30),
      ));
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('1'),
          position: LatLng(7.172265216145902, 100.61383998810894),
          infoWindow: InfoWindow(
              title: "Songklha Rajabhat University",
              snippet: "Our beloved university <3"),
          onTap: () =>
              _openOnGoogleMapApp(7.172265216145902, 100.61383998810894),
        ),
      );
      _markers.add(
        Marker(
          markerId: MarkerId('2'),
          position: LatLng(7.166961325721222, 100.61281237129259),
          icon: csLocationIcon,
          infoWindow: InfoWindow(
              title: "Computer Department", snippet: "We study here!"),
          onTap: () =>
              _openOnGoogleMapApp(7.166961325721222, 100.61281237129259),
        ),
      );
      _markers.add(
        Marker(
          markerId: MarkerId('3'),
          position: LatLng(6.9920075759382465, 100.48274286992068),
          icon: BitmapDescriptor.defaultMarkerWithHue(80),
          infoWindow: InfoWindow(
              title: "Central Festival Hadyai", snippet: "Start here!"),
        ),
      );
      _markers.add(
        Marker(
          markerId: MarkerId('sourcePin'),
          position: LatLng(currentLocation.latitude, currentLocation.longitude),
          icon: sourceIcon,
          infoWindow:
              InfoWindow(title: "Current Location", snippet: "I am here now!"),
        ),
      );
    });
  }

  static final CameraPosition _kSKRU = CameraPosition(
    target: LatLng(7.172265216145902, 100.61383998810894),
    zoom: 16,
  );

  static final CameraPosition _kCenFest = CameraPosition(
    target: LatLng(6.9920075759382465, 100.48274286992068),
    zoom: 16,
  );

  static final CameraPosition _kBuliding8 = CameraPosition(
      //bearing: 192.8334901395799,
      target: LatLng(7.166961325721222, 100.61281237129259),
      //tilt: 59.440717697143555,
      zoom: 19);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(title: Text("My Map"), actions: <Widget>[
        IconButton(
            icon: Icon(
              Icons.store,
              color: Colors.greenAccent,
            ),
            onPressed: _goToCenFest),
        IconButton(
            icon: Icon(Icons.school, color: Colors.red), onPressed: _goToSKRU),
        IconButton(
            icon: Icon(Icons.favorite, color: Colors.orangeAccent),
            onPressed: _goToBuilding8),
      ]),
      body: GoogleMap(
        mapType: MapType.normal,
        myLocationEnabled: true,
        //mapType: MapType.normal,
        polygons: _polygons,
        initialCameraPosition: _kSKRU,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          _onMapCreated(controller);
        },
        markers: _markers,
        polylines: polyLines,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToBuilding8,
        label: Text('To My Location!'),
        icon: Icon(Icons.save_alt_rounded),
      ),
    );
  }

  Future<void> _goToSKRU() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kSKRU));
  }

  Future<void> _goToBuilding8() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kBuliding8));
  }

  Future _goToCenFest() async {
    final GoogleMapController controller = await _controller.future;
    currentLocation = await getCurrentLocation();
    controller.animateCamera(CameraUpdate.newCameraPosition(_kCenFest));
  }

  Future _goToMe() async {
    final GoogleMapController controller = await _controller.future;
    currentLocation = await getCurrentLocation();
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
      zoom: 16,
    )));
  }

  Future<LocationData> getCurrentLocation() async {
    Location location = Location();

    return await location.getLocation();
  }

  _openOnGoogleMapApp(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      // Could not open the map.
    }
  }

  _setPolyLines() {
    Polyline polyline = Polyline(
      polylineId: PolylineId("polyline"),
      color: Colors.lightGreenAccent,
      points: polyPoints,
    );
    polyLines.add(polyline);
    setState(() {});
  }

  void _getJsonData() async {
    // Create an instance of Class NetworkHelper which uses http package
    // for requesting data to the server and receiving response as JSON format

    NetworkHelper network = NetworkHelper(
      startLat: 7.166961325721222,
      startLng: 100.61281237129259,
      endLat: 6.991936163139371,
      endLng: 100.48276059353766,
    );

    try {
      // getData() returns a json Decoded data
      data = await network.getData();
      //print('data');
      //print(data);
      // We can reach to our desired JSON data manually as following
      LineString ls =
          LineString(data['features'][0]['geometry']['coordinates']);

      for (int i = 0; i < ls.lineString.length; i++) {
        polyPoints.add(LatLng(ls.lineString[i][1], ls.lineString[i][0]));
      }
      _setPolyLines();
    } catch (e) {
      print(e);
    }
  }
}

class LineString {
  LineString(this.lineString);
  List<dynamic> lineString;
}
