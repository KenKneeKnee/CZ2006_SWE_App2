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

  final myController = TextEditingController();

  late final AnimationController _animationController;
  late MapController mapController;

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
    setState(() {
      mapController = MapController();
    });
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
    setState(() {
      location = true;
    });
    if (_userLocationData == null) {
      print('location services not enabled!');
      _startingPoint = LatLng(1.3489, 103.6895);

      return;
    }

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
      appBar: AppBar(
        title: Container(
          color: Colors.blue,
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Container(
                    padding: EdgeInsets.fromLTRB(15, 10, 0, 10),
                    child: TextField(
                      decoration: new InputDecoration.collapsed(
                        hintStyle:
                            TextStyle(fontSize: 20.0, color: Colors.white),
                        hintText: 'Search for Facilities',
                      ),
                      controller: myController,
                    )),
              ),
              Expanded(
                flex: 1,
                child: Stack(
                  children: [
                    IconButton(
                        onPressed: () {
                          List<SportsFacility> searchedList = [];

                          for (SportsFacility place in SportsFacilityList) {
                            String lower_place = place.placeName.toLowerCase();
                            String lower_search = myController.text;
                            // String lower_search =
                            //     myController.text.toLowerCase();
                            late SportsFacility sf;
                            late int sf_index;

                            if (lower_search != null &&
                                lower_place.contains(lower_search)) {
                              searchedList.add(place);
                            }
                          }
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Are you looking for...'),
                                  content: setupAlertDialoadContainer(
                                      searchedList, mapController),
                                );
                              });
                        },
                        icon: Icon(Icons.search, color: Colors.white)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      body: (!loading & location)
          ? FlutterMap(
              options: MapOptions(
                minZoom: 2.5,
                maxZoom: 20,
                zoom: 15,
                center: _startingPoint,
                // onMapCreated: (c) {
                //   mapController = c;
                // }),
              ),
              mapController: mapController,
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
                  //Layer for user's loaction
                  markers: [
                    Marker(
                        point: _startingPoint,
                        height: 60,
                        width: 60,
                        builder: (context) {
                          return myLocationMarker(_animationController);
                        }),
                  ], //List<Marker>
                ),
              ],
            )
          : LottieMap(),
    );
  }

  Widget setupAlertDialoadContainer(
      List<SportsFacility> sflist, MapController mapController) {
    return Container(
      height: 300.0, // Change as per your requirement
      width: 300.0, // Change as per your requirement
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: sflist.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(sflist[index].placeName),
            onTap: () {
              setState(() {
                _selectedIndex = index;
                mapController.move(sflist[index].coordinates, 15.0);
                print('moving to ${sflist[index].coordinates}');
                Navigator.of(context, rootNavigator: true).pop();
              });
            },
          );
        },
      ),
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
