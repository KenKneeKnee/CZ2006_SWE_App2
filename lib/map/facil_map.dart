import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:lottie/lottie.dart' hide Marker;
import 'package:my_app/calendar/grrrrrrr.dart';
import 'package:my_app/events/create_event.dart';
import 'package:my_app/loading_lotties/loading_lotties.dart';
import 'package:my_app/map/map_data.dart';
import 'package:my_app/map/map_sheet.dart';
import 'package:my_app/map/map_widgets.dart';
import 'package:my_app/widgets/background.dart';
import 'package:my_app/widgets/bouncing_button.dart';
import 'package:location/location.dart';

const MAPBOX_TOKEN =
    'pk.eyJ1IjoiY2xhcmlzc2FqZXciLCJhIjoiY2t6YzRmMnYzMmtoMjJzdHZlZmk0cDFyZyJ9.OyEroOyhNimfl1l4UrHTXA';
const MAPBOX_URL =
    "https://api.mapbox.com/styles/v1/clarissajew/ckzcbywdr002o14p8zqjuwtvj/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiY2xhcmlzc2FqZXciLCJhIjoiY2t6YzRmMnYzMmtoMjJzdHZlZmk0cDFyZyJ9.OyEroOyhNimfl1l4UrHTXA";
const MAPBOX_TILESET_ID = "clarissajew.4njadghk";
const MARKERSIZE_ENLARGED = 80.0;
const MARKERSIZE_SHRINKED = 50.0;

LatLng _startingPoint =
    LatLng(1.35436736684635, 103.94077231704); //points at Singapore

class FacilitiesMap extends StatefulWidget {
  FacilitiesMap({Key? key}) : super(key: key);

  final User? user = FirebaseAuth.instance.currentUser;
  //TODO: Put user's profile pic for the location marker icon

  @override
  _FacilitiesMapState createState() => _FacilitiesMapState();
}

class _FacilitiesMapState extends State<FacilitiesMap>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late bool loading;
  late bool location;
  late LatLng userLocation;
  late List<SportsFacility> SportsFacilityList;
  late List<Marker> MarkerList;

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    loading = true;
    location = false;
    getData();
    getUserLocation();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  ///Fetches User's location
  ///
  Future getUserLocation() async {
    final _userLocationData = await checkLocation();
    if (_userLocationData == null) {
      print('location services not enabled!');
    }
    setState(() {
      location = true;
    });
    var _longitude = _userLocationData.longitude;
    var _latitude = _userLocationData.latitude;
    _startingPoint = LatLng(_latitude, _longitude);
    print(
        'Successfully fetched ${widget.user?.displayName}\'s location -- ${_startingPoint}');
  }

  Future getData() async {
    var sportsfacildatasource = SportsFacilDataSource();
    final facildata = await sportsfacildatasource.someFunction();
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      SportsFacilityList = facildata;
      loading = false;
      MarkerList = _buildMapMapMarkers();
    });
  }

  /// Returns a list of Marker objects from  a list of SportsFacility objects
  Widget build(BuildContext context) {
    return Scaffold(
      body: (!loading & location)
          ? FlutterMap(
              options: MapOptions(
                minZoom: 2.5,
                maxZoom: 20,
                zoom: 15,
                center: _startingPoint,
              ),
              children: [],
              nonRotatedLayers: [
                TileLayerOptions(urlTemplate: MAPBOX_URL, additionalOptions: {
                  'accessToken': MAPBOX_TOKEN,
                  'id': MAPBOX_TILESET_ID,
                }),
                MarkerLayerOptions(
                  markers: MarkerList, //List<Marker>
                ),
                MarkerLayerOptions(
                  markers: [
                    Marker(
                        point: _startingPoint,
                        height: 60,
                        width: 60,
                        builder: (context) {
                          return _myLocationMarker(_animationController);
                        }),
                  ], //List<Marker>
                ),
              ],
            )
          : LottieMap(),
    );
  }

  List<Marker> _buildMapMapMarkers() {
    final _markerList = <Marker>[]; //list to be returned from this function

    // print(
    //     '${SportsFacilityList.length} facilities have been fetched into the SportsFacilityList');

    for (int i = 0; i < SportsFacilityList.length; i++) {
      final _sportsFacil = SportsFacilityList[i];

      _markerList.add(
        Marker(
            height: MARKERSIZE_ENLARGED,
            width: MARKERSIZE_ENLARGED,
            builder: (_) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = i;
                  });
                  print('selected place ${_selectedIndex}!');

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    builder: (builder) {
                      return DraggableScrollableSheet(
                          expand: false,
                          builder: ((context, scrollController) {
                            return Stack(children: [
                              RoundedBackgroundImage(
                                  imagePath: 'assets/images/background.png'),
                              MapMarkerInfoSheet(
                                  SportsFacil: _sportsFacil,
                                  index: _selectedIndex),
                            ]);
                          }));
                    },
                  );
                },
                child: MapMarker(
                  imagePath: _sportsFacil.markerImgPath,
                  selected: _selectedIndex == i, //true if this marker is tapped
                ),
              );
            },
            point: _sportsFacil.coordinates),
      );
    }
    if (_markerList.length > 0) {
      print(
          '${_markerList.length} markers have been created on the map from ${SportsFacilityList.length}!');
    }
    return _markerList;
  }
}

Future checkLocation() async {
  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return;
    }
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return;
    }
  }

  _locationData = await location.getLocation();
  return _locationData;
}

class _myLocationMarker extends AnimatedWidget {
  const _myLocationMarker(
    Animation<double> animation, {
    Key? key,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final value = (listenable as Animation<double>).value;
    final newValue = lerpDouble(0.5, 1.0, value)!;
    //lerpDouble interpolates between two numbers by an extrapolation t
    final size = 50.0;

    return Center(
        child: Stack(
      children: [
        Center(
          child: Container(
            height: size * newValue,
            width: size * newValue,
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Center(
          child: Container(
            height: 20,
            width: 20,
            decoration:
                BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
          ),
        ),
      ],
    ));
  }
}
