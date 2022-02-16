import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:my_app/calendar/calendar.dart';
import 'package:my_app/events/create_event.dart';
import 'package:my_app/map/map_data.dart';
import 'package:my_app/map/map_widgets.dart';
import 'package:my_app/widgets/bouncing_button.dart';

const MAPBOX_TOKEN =
    'pk.eyJ1IjoiY2xhcmlzc2FqZXciLCJhIjoiY2t6YzRmMnYzMmtoMjJzdHZlZmk0cDFyZyJ9.OyEroOyhNimfl1l4UrHTXA';
const MAPBOX_URL =
    "https://api.mapbox.com/styles/v1/clarissajew/ckzcbywdr002o14p8zqjuwtvj/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiY2xhcmlzc2FqZXciLCJhIjoiY2t6YzRmMnYzMmtoMjJzdHZlZmk0cDFyZyJ9.OyEroOyhNimfl1l4UrHTXA";
const MAPBOX_TILESET_ID = "clarissajew.4njadghk";
const MARKERSIZE_ENLARGED = 80.0;
const MARKERSIZE_SHRINKED = 50.0;
final LatLng _startingPoint =
    LatLng(1.35436736684635, 103.94077231704); //points at Singapore

class FacilitiesMap extends StatefulWidget {
  FacilitiesMap({Key? key}) : super(key: key);

  @override
  _FacilitiesMapState createState() => _FacilitiesMapState();
}

class _FacilitiesMapState extends State<FacilitiesMap> {
  int _selectedIndex = 0;
  late bool loading;
  late List<SportsFacility> SportsFacilityList;
  late List<Marker> MarkerList;

  @override
  void initState() {
    super.initState();

    loading = true;
    getData();
  }

  Future getData() async {
    var sportsfacildatasource = SportsFacilDataSource();
    final facildata = await sportsfacildatasource.someFunction();
    setState(() {
      SportsFacilityList = facildata;
      loading = false;
      MarkerList = _buildMapMapMarkers();
    });
  }

  /// Returns a list of Marker objects from a list of SportsFacility objects
  ///
  ///@override
  ///
  Widget build(BuildContext context) {
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
      body: !loading
          ? FlutterMap(
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
                  markers: MarkerList, //List<Marker>
                ),
              ],
            )
          : Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height,
              child:
                  CircularProgressIndicator()), //TODO: I THINK SMTH IS NOT RIGHT HERE
    );
  }

  List<Marker> _buildMapMapMarkers() {
    final _markerList = <Marker>[]; //list to be returned from this function

    print(
        '${SportsFacilityList.length} facilities have been fetched into the SportsFacilityList');

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
                            return MapMarkerInfoSheet(
                                SportsFacil: _sportsFacil,
                                index: _selectedIndex);
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

/// (custom) MapMarker consists of location marker image with dynamic size
/// Function holding function to trigger corrsponding details is in the Marker class (flutter)
class MapMarker extends StatelessWidget {
  const MapMarker({Key? key, required this.selected, required this.imagePath})
      : super(key: key);

  final bool selected;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final size = selected ? MARKERSIZE_ENLARGED : MARKERSIZE_SHRINKED;

    return Center(
      child: AnimatedContainer(
        height: size,
        width: size,
        duration: const Duration(milliseconds: 400),
        child: Image.asset(imagePath),
      ),
    );
  }
}

class MapMarkerInfoSheet extends StatelessWidget {
  const MapMarkerInfoSheet(
      {Key? key, required this.SportsFacil, required this.index})
      : super(key: key);
  final SportsFacility SportsFacil;
  final int index;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          MapMarkerInfoHeader(SportsFacil.placeName, SportsFacil.facilityType,
              SportsFacil.addressDesc, SportsFacil.hoverImgPath),
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
                          placeDetails: SportsFacil.addressDesc),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                    );
                  },
                ).then((value) => {
                      if (value)
                        {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SuccessDialog();
                              })
                        }
                      else
                        {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return FailDialog();
                              })
                        }
                    });
              })
        ],
      ),
    );
  }
}
