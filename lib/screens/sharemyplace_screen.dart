import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../components/sharemyplace_screen/network.dart';
import '../components/sharemyplace_screen/show_detail.dart';
import '../components/sharemyplace_screen/add_place.dart';
import '../components/common/common.dart';
import '../providers/place_provider.dart';
import '../models/place.dart';

class ShareMyPlaceScreen extends StatefulWidget {
  @override
  State<ShareMyPlaceScreen> createState() => ShareMyPlaceScreenState();
}

class ShareMyPlaceScreenState extends State<ShareMyPlaceScreen> {
  GoogleMapController _controller;
  Set<Polygon> _polygons = HashSet<Polygon>();

  Set<Polyline> _polyLines = {};
  List<LatLng> _polyPoints = [];

  var data;

  BitmapDescriptor _csLocationIcon;

  Set<Marker> _markers = {};

  LocationData _currentLocation;
  Location _location;
  StreamSubscription<LocationData> _locationSubscription;
  BitmapDescriptor _sourceIcon;
  BitmapDescriptor _destinationIcon;

  LocationData _destinationLocation;

  @override
  void initState() {
    super.initState();

    _addMarkerFromDatabase();
    _location = new Location();

    _locationSubscription =
        _location.onLocationChanged.listen((LocationData cLoc) {
      _currentLocation = cLoc;
      _updatePinOnMap();
    });
    _setCurrentLationIcons();
    _setCustomMapPin();
    _setPolygonsComSci();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Cultural & Tourist Attractions in Songkhla",
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.school, color: Colors.red),
              onPressed: _goToSKRU),
          IconButton(
              icon: Icon(Icons.person, color: Colors.orangeAccent),
              onPressed: _goToCS),
        ],
        backgroundColor: Colors.blueGrey,
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        myLocationEnabled: true,
        polygons: _polygons,
        initialCameraPosition: _kSKRU,
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
          _onMapCreated();
        },
        markers: _markers,
        polylines: _polyLines,
        onLongPress: (LatLng latlng) async {
          _showAddForm(latlng.latitude, latlng.longitude);
        },
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton.extended(
          onPressed: () {
            setState(() {
              _markers = {};
            });
            _onMapCreated();
            _addMarkerFromDatabase();
          },
          label: Text('Refresh'),
          icon: Icon(Icons.refresh),
        ),
      ),
    );
  }

  @override
  void dispose() {
    print('dispose');
    _controller.dispose();
    _locationSubscription.cancel();
    super.dispose();
  }

  void _addMarkerFromDatabase() async {
    PlaceProvider _place = PlaceProvider();
    List<Place> placeList = await _place.getPlaces();

    placeList.forEach((plc) {
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId(plc.placeId),
          position: LatLng(plc.lat, plc.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          infoWindow: InfoWindow(
            title: plc.title,
            onTap: () => _showDetail(plc.placeId),
          ),
        ));
      });
    });
  }

  void _addMarker(String plcId, String title, double lat, double lng) async {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(plcId),
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        infoWindow: InfoWindow(
          title: title,
          onTap: () => _showDetail(plcId),
        ),
      ));
    });
  }

  void _removeMarker(String plcId) async {
    _markers.removeWhere((m) => m.markerId.value == plcId);
  }

  void _setDestination(LatLng latlng) async {
    if ((_destinationLocation != null) &&
        (_destinationLocation.latitude == latlng.latitude) &&
        (_destinationLocation.longitude == latlng.longitude)) {
      setState(() {
        _destinationLocation = null;
        _markers
            .removeWhere((m) => m.markerId.value == 'destinationLacationPin');
        _polyPoints.clear();
      });
    } else {
      setState(() {
        _destinationLocation = LocationData.fromMap(
            {'latitude': latlng.latitude, 'longitude': latlng.longitude});
        _markers
            .removeWhere((m) => m.markerId.value == 'destinationLacationPin');
        _markers.add(Marker(
          markerId: MarkerId('destinationLacationPin'),
          position: latlng,
          icon: _destinationIcon,
          infoWindow: InfoWindow(
              title: "Destination Location",
              snippet: "Your destination is here!"),
        ));
      });
      _addRoute();
    }
  }

  void _setCurrentLationIcons() async {
    _sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'images/driving_pin.png');

    _destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'images/destination_map_marker.png');
  }

  void _setCustomMapPin() async {
    _csLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'images/logocomsci.jpg');
  }

  void _setPolygonsComSci() {
    _polygons.add(
      Polygon(
          polygonId: PolygonId("0"),
          points: CommonData.polygonLatLngComSci,
          fillColor: Colors.orangeAccent,
          strokeWidth: 3,
          strokeColor: Colors.black),
    );
  }

  void _updatePinOnMap() async {
    setState(() {
      var pinPosition =
          LatLng(_currentLocation.latitude, _currentLocation.longitude);

      _markers.removeWhere((m) => m.markerId.value == 'currentLacationPin');
      _markers.add(Marker(
        markerId: MarkerId('currentLacationPin'),
        position: pinPosition,
        icon: _sourceIcon,
        infoWindow:
            InfoWindow(title: "Current Location", snippet: "I am here now!"),
      ));
    });
  }

  void _onMapCreated() {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('SKRU'),
          position: CommonData.SKRU_LATLNG,
          infoWindow: InfoWindow(
              title: "Songklha Rajabhat University",
              snippet: "Our beloved university <3"),
          onTap: () => _showDetail('SKRU'),
        ),
      );
      _markers.add(
        Marker(
          markerId: MarkerId('CS_SKRU'),
          position: CommonData.ComSci_LATLNG,
          icon: _csLocationIcon,
          infoWindow: InfoWindow(
              title: "Computer Department", snippet: "We study here!"),
          onTap: () => _showDetail('CS_SKRU'),
        ),
      );
    });
  }

  static final CameraPosition _kSKRU = CameraPosition(
    target: CommonData.SKRU_LATLNG,
    zoom: 16,
  );

  static final CameraPosition _kBuliding8 = CameraPosition(
      //bearing: 192.8334901395799,
      target: CommonData.ComSci_LATLNG,
      //tilt: 59.440717697143555,
      zoom: 19);

  Future<void> _goToSKRU() async {
    _controller.animateCamera(CameraUpdate.newCameraPosition(_kSKRU));
  }

  Future<void> _goToCS() async {
    _controller.animateCamera(CameraUpdate.newCameraPosition(_kBuliding8));
  }

  Future<LocationData> getCurrentLocation() async {
    Location location = Location();

    return await location.getLocation();
  }

  _showAddForm(double _lat, double _lng) async {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return AddPlace(_lat, _lng, _addMarker);
        });
  }

  _showDetail(String placeId) async {
    String title;
    String description;
    String imageUrl;
    double lat;
    double lng;
    if (placeId == 'SKRU') {
      title = CommonData.SKRU_TITLE;
      description = CommonData.SKRU_DESCRIPTION;
      imageUrl = CommonData.SKRU_IMAGE;
      lat = CommonData.SKRU_LATLNG.latitude;
      lng = CommonData.SKRU_LATLNG.longitude;
    } else if (placeId == 'CS_SKRU') {
      title = CommonData.ComSci_TITLE;
      description = CommonData.ComSci_DESCRIPTION;
      imageUrl = CommonData.ComSci_IMAGE;
      lat = CommonData.ComSci_LATLNG.latitude;
      lng = CommonData.ComSci_LATLNG.longitude;
    } else {
      PlaceProvider _place = PlaceProvider();
      Place plc = await _place.findByPlaceId(placeId);
      print(plc);
      title = plc.title;
      description = plc.description;
      imageUrl = plc.imageUrl;
      lat = plc.lat;
      lng = plc.lng;
    }

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return ShowPlaceDetail(placeId, title, description, imageUrl, lat,
              lng, _setDestination, _removeMarker);
        });
  }

  _setPolyLines() {
    Polyline polyline = Polyline(
      polylineId: PolylineId("polyline"),
      color: Colors.lightBlue,
      width: 5,
      points: _polyPoints,
    );
    _polyLines.add(polyline);
    setState(() {});
  }

  void _addRoute() async {
    _polyPoints.clear();
    NetworkHelper network = NetworkHelper(
      startLat: _currentLocation.latitude,
      startLng: _currentLocation.longitude,
      endLat: _destinationLocation.latitude,
      endLng: _destinationLocation.longitude,
    );

    try {
      data = await network.getData();

      LineString ls =
          LineString(data['features'][0]['geometry']['coordinates']);

      for (int i = 0; i < ls.lineString.length; i++) {
        _polyPoints.add(LatLng(ls.lineString[i][1], ls.lineString[i][0]));
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
