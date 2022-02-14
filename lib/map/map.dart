import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:my_app/calendar/calendar.dart';
import 'package:my_app/events/create_event.dart';
import 'package:my_app/widgets/bouncing_button.dart';
import '../map/map_marker.dart';

const MAPBOX_TOKEN =
    'pk.eyJ1IjoiY2xhcmlzc2FqZXciLCJhIjoiY2t6YzRmMnYzMmtoMjJzdHZlZmk0cDFyZyJ9.OyEroOyhNimfl1l4UrHTXA';
const MAPBOX_URL =
    "https://api.mapbox.com/styles/v1/clarissajew/ckzcbywdr002o14p8zqjuwtvj/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiY2xhcmlzc2FqZXciLCJhIjoiY2t6YzRmMnYzMmtoMjJzdHZlZmk0cDFyZyJ9.OyEroOyhNimfl1l4UrHTXA";

const MAPBOX_TILESET_ID = "clarissajew.4njadghk";

const MARKERSIZE_ENLARGED = 120.0;
const MARKERSIZE_SHRINKED = 70.0;
final LatLng _startingPoint =
    LatLng(1.35436736684635, 103.94077231704); //points at Singapore

class EventMap extends StatefulWidget {
  const EventMap({Key? key}) : super(key: key);

  @override
  _EventMapState createState() => _EventMapState();
}

class _EventMapState extends State<EventMap> {
  //final _pageController = PageController();
  int _selectedIndex = 0;

  List<Marker> _buildMarkers() {
    final _markerList = <Marker>[];
    for (int i = 0; i < mapMarkers.length; i++) {
      final mapItem = mapMarkers[i];
      _markerList.add(
        Marker(
            height: MARKERSIZE_ENLARGED,
            width: MARKERSIZE_ENLARGED,
            builder: (_) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = i;
                    // _pageController.animateToPage(i,
                    //     duration: const Duration(milliseconds: 500),
                    //     curve: Curves.elasticOut);
                    print(
                        'Selected location ${i} out of ${mapMarkers.length} places!');
                  });
                },
                child: _LocationMarker(
                  index: i,
                  selected: _selectedIndex == i,
                  facilityType: mapMarkers[i].facilityType,
                ),
              );
            },
            point: mapItem.location),
      );
    }
    return _markerList;
  }

  @override
  Widget build(BuildContext context) {
    final _markers = _buildMarkers();

    return Scaffold(
      appBar: AppBar(
        actions: [
          MaterialButton(
            onPressed: () => null,
            child: Image.asset('sportsbuds-logo.png'),
          ),
        ],
        title: Text('Sports Facilities'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              minZoom: 2.5,
              maxZoom: 20,
              zoom: 15,
              center: _startingPoint,
            ),
            nonRotatedLayers: [
              TileLayerOptions(urlTemplate: MAPBOX_URL, additionalOptions: {
                'accessToken': MAPBOX_TOKEN,
                'id': MAPBOX_TILESET_ID,
              }),
              MarkerLayerOptions(
                markers: _markers,
              ),
            ],
          ),
          // Positioned(
          //   left: 0,
          //   right: 0,
          //   bottom: 50,
          //   height: MediaQuery.of(context).size.height * 0.3,
          //   child: PageView.builder(
          //     controller: _pageController,
          //     physics: NeverScrollableScrollPhysics(),
          //     itemBuilder: (context, index) {
          //       final item = mapMarkers[index];
          //       return _MapItemDetails(mapMarker: item);
          //     },
          //     itemCount: mapMarkers.length,
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _LocationMarker extends StatelessWidget {
  const _LocationMarker(
      {Key? key,
      this.selected = false,
      required this.facilityType,
      required this.index})
      : super(key: key);

  final bool selected;
  final int index;
  final String facilityType;

  @override
  Widget build(BuildContext context) {
    final size = selected ? MARKERSIZE_ENLARGED : MARKERSIZE_SHRINKED;
    return Center(
        child: AnimatedContainer(
      height: size,
      width: size,
      duration: const Duration(milliseconds: 400),
      child: IconButton(
        icon: _FindMarkerImage(facilityType),
        onPressed: () {
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (builder) {
                return DraggableScrollableSheet(
                    expand: false,
                    builder: ((context, scrollController) {
                      return SingleChildScrollView(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Column(
                          children: <Widget>[
                            _MapItemDetails(mapMarker: mapMarkers[index]),
                            EventCalendar(),
                            BouncingButton(
                                bgColor: Color(0xffE96B46),
                                borderColor: Color(0xffE96B46),
                                buttonText: "Create Event",
                                textColor: Color(0xffffffff),
                                onClick: () {
                                  String _placeId = index.toString();
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        backgroundColor: Color(0xffE5E8E8),
                                        child: CreateEventForm(
                                          date: DateTime.now(),
                                          placeId: _placeId,
                                          placeDetails:
                                              mapMarkers[index].address,
                                        ),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20.0))),
                                      );
                                    },
                                  ).then((value) => {
                                        if (value)
                                          {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return _successDialog(
                                                      context);
                                                })
                                          }
                                        else
                                          {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return _failDialog(context);
                                                })
                                          }
                                      });
                                }),
                          ],
                        ),
                      );
                    }));
              });
        },
      ),
    ));
  }
}

//----------------------------------------------------
// UI widgets for the alert dialog of event creation
Widget _okButton(BuildContext context) {
  return BouncingButton(
    bgColor: Colors.white,
    textColor: Color(0xffD56F2F),
    borderColor: Color(0xffD56F2F),
    buttonText: "Got it!",
    onClick: () {
      Navigator.of(context, rootNavigator: true).pop('dialog');
    },
  );
}

AlertDialog _successDialog(BuildContext context) {
  return AlertDialog(
      content: Container(
        height: 350,
        decoration: _successBackground,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height * 0.22),
              Text(
                'Event Created!',
                style: _titleStyle,
              ),
              SizedBox(height: 15),
              Text(
                'Now all that\'s left is getting fellow SportBuddies to join your event!',
                style: _paraStyleBold,
              ),
            ],
          ),
        ),
      ),
      actions: [
        _okButton(context),
      ]);
}

AlertDialog _failDialog(BuildContext context) {
  return AlertDialog(
      content: Container(
        height: 240,
        decoration: _failBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Text(
              'Error!',
              style: _titleStyle,
            ),
            SizedBox(height: 15),
            Text(
              'Something went wrong. I\'m sorry :(',
              style: _paraStyleBold,
            ),
          ],
        ),
      ),
      actions: [
        _okButton(context),
      ]);
}

const BoxDecoration _successBackground = BoxDecoration(
  image: DecorationImage(
    image: AssetImage('create-event-success.png'),
    fit: BoxFit.fitWidth,
    alignment: Alignment.topCenter,
  ),
);
const BoxDecoration _failBackground = BoxDecoration(
  image: DecorationImage(
    image: AssetImage('create-event-fail.png'),
    fit: BoxFit.fitWidth,
    alignment: Alignment.topCenter,
  ),
);
//Text Styles
const TextStyle _titleStyle = TextStyle(
    fontWeight: FontWeight.bold, fontSize: 45, color: Color(0xffE3663E));

const TextStyle _paraStyleBold = TextStyle(
  color: Colors.black87,
  fontSize: 15,
  fontWeight: FontWeight.bold,
);

//-----------------------------------------------------
Image _FindMarkerImage(String facilityType) {
  if (facilityType.contains("Gym")) {
    return Image.asset('gym-marker.png');
  } else if (facilityType.contains("wim")) {
    return Image.asset('swimming-marker.png');
  } else if (facilityType.contains("ennis")) {
    return Image.asset('tennis-marker.png');
  } else if (facilityType.contains('all')) {
    return Image.asset('basketball-marker.png');
  } else if (facilityType.contains("tadium")) {
    return Image.asset('stadium-marker.png');
  }
  return Image.asset('missing-marker.png');
}

class _MapItemDetails extends StatelessWidget {
  const _MapItemDetails({
    Key? key,
    required this.mapMarker,
  }) : super(key: key);

  final MapMarker mapMarker;
  @override
  Widget build(BuildContext context) {
    final _style = TextStyle(
      color: Colors.grey[900],
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.arrow_drop_down_circle),
                  title: Text(
                    mapMarker.facilityType,
                    style: TextStyle(color: Colors.black.withOpacity(0.6)),
                  ),
                  // subtitle: Text(
                  //   mapMarker.facilityType,
                  //   style: TextStyle(color: Colors.black.withOpacity(0.6)),
                  // ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    mapMarker.address,
                    style: TextStyle(color: Colors.black.withOpacity(0.6)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
