///Everything to do with storing and fetching the map data
///
import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart';

class SportsFacility {
  SportsFacility(
      {required this.coordinates,
      required this.placeName,
      required this.addressDesc,
      required this.facilityType,
      required this.imagePath});

  final LatLng coordinates;
  final String placeName;
  final String addressDesc;
  final String facilityType;
  final String imagePath;

  @override
  toString() {
    return ('${placeName} is a ${facilityType} found at : ${coordinates}');
  }
}

Future<Map<String, dynamic>> parseJsonFromAssets(String assetsPath) async {
  return rootBundle
      .loadString(assetsPath)
      .then((jsonStr) => jsonDecode(jsonStr));
}

/// reads the json file (contianing 350 playgrounds, parks, etc) into a list of SportsFacility objects
/// each object consists of the location coordinates, name, facility type (playground/park) & address description
///
///
Future fetchPlaygroundParks() async {
  String _path = 'assets/images/parks-geojson.json';
  List<SportsFacility> _markers = [];
  await parseJsonFromAssets(_path).then(
    (dmap) {
      // here you get json `dmap` as Map<String, dynamic>
      List<dynamic> data = dmap['features'];

      data.forEach(
        (place) {
          //get coordinates to insert as LatLng data
          double _longitude = place['geometry']['coordinates'][0];
          double _latitude = place['geometry']['coordinates'][1];
          LatLng _coordinates = LatLng(_latitude, _longitude);

          String _description = place['properties']['Description'];

          List<String> _nameDescSplit =
              _description.split('<th>NAME</th> <td>');
          String _name = _nameDescSplit[1].split('</td>')[0];

          String _facilityType;
          if (_name.contains("Playground")) {
            _facilityType = "Playground";
          } else if (_name.contains("Park")) {
            _facilityType = "Park";
          } else {
            _facilityType = "Shared Space";
          }

          List<String> _addrDescSplit =
              _description.split('<th>DESCRIPTION</th> <td>');
          String _addrDesc = _addrDescSplit[1].split('</td>')[0];

          SportsFacility _temp = SportsFacility(
            coordinates: _coordinates,
            placeName: _name,
            addressDesc: _addrDesc,
            facilityType: _facilityType,
            imagePath: _FindMarkerImage(_facilityType),
          );
          _markers.add(_temp);
          // print(
          //     'fetched ${_name} with coordinates ${_longitude.toString()} : ${_latitude.toString()}');
        },
      );
    },
  );
  if (_markers.length > 0) {
    // print(
    //     'Hello fetched ${_markers.length} playgrounds/parksfrom _fetchPlaygroundParks');
    return _markers;
  } else {
    print('smth went wrong in fetching the playgrounds/parks');
  }
  return _markers;
}

const res = [
  [
    '1.35436736684635,103.94077231704',
    'Swimming Complex/Sports Hall/Gym',
    '495 Tampines Ave 5, Singapore 529649'
  ],
  [
    '1.37448512294275,103.952424537943',
    'Swimming Complex/Sports Hall/Stadium/Tennis Centre/Gym',
    '45 Pasir Ris Drive 3, Singapore 519500'
  ],
  [
    '1.29703118433011,103.8021979086',
    'Swimming Complex/Stadium',
    '473 Stirling Rd, Singapore 148948'
  ],
  [
    '1.39628632762323,103.887535237702',
    'Swimming Complex/Sports Hall/Gym/Hockey Pitch',
    'Blk 326d, Singapore'
  ],
  [
    '1.35779894733763,103.874819675218',
    'Swimming Complex/ Stadium',
    '67 Yio Chu Kang Rd, Singapore'
  ],
  [
    '1.33114710936452,103.852261295317',
    'Swimming Complex/Sports Hall/Stadium/Gym',
    '297a Lor 6 Toa Payoh, Singapore 319389'
  ],
  [
    '1.4357545025108,103.78097604595',
    'Swimming Complex/Sports Hall/Stadium/Gym',
    '1A Woodlands Street 13, Singapore 738598'
  ],
  [
    '1.32605591303017,103.862154974899',
    'Field/Tennis Centre',
    "19A St Michael's Rd, Singapore 328003"
  ],
  [
    '1.38339562811452,103.84538692395',
    'Swimming Complex/Sports Hall/Stadium/Tennis Centre/Squash Centre/Gym',
    '3002 Ang Mo Kio Ave 8, Singapore'
  ],
  [
    '1.41375104904808,103.832038418267',
    'Sports Hall/Stadium/Gym',
    'Yishun Sports Hall, Singapore'
  ],
  [
    '1.42411707461287,103.834053811006',
    'Swimming Complex',
    '768 Yishun Ave 3, Block 768, Singapore 760768'
  ],
  [
    '1.32129929136485,103.820163508503',
    'Sports Hall/Stadium/Swimming Complex/Tennis Centre/Squash Centre/Hockey Pitch',
    '449 Bukit Timah Rd, Singapore 259747'
  ],
  [
    '1.29088508668353,103.820350965163',
    'Swimming Complex/Sports Hall/Gym/Hockey Pitch',
    'Delta Sports Hall, Singapore'
  ],
  ['1.2876679644099,103.814843176229', 'Gym', '20 Lengkok Bahru, Singapore'],
  [
    '1.32148423019096,103.888148340047',
    'Swimming Complex',
    '601 Aljunied Ave 1, Singapore 389862'
  ],
  [
    '1.31093087343346,103.87761161695',
    'Field',
    '19 Lor 10 Geylang, Singapore 399051'
  ],
  [
    '1.30957995820846,103.850338873065',
    'Field/Tennis Centre',
    '21 Northumberland Rd, Singapore 218984'
  ],
  [
    '1.31068958851184,103.859668996456',
    'Swimming Complex/Stadium',
    '113 Tyrwhitt Rd, Singapore 207544'
  ],
  [
    '1.34586414829953,103.729138907193',
    'Swimming Complex/Sports Hall/Stadium/Gym/Gateball & Petanque Courts',
    '21 Jurong East Street 31, Singapore 609517'
  ],
  [
    '1.32722499734466,103.931147265025',
    'Swimming Complex/Sports Hall/Tennis Centre/Gym',
    '21 Bedok North Street 1, Singapore 469659'
  ],
  [
    '1.3698443789415,103.886186285942',
    'Swimming Complex/Sports Hall/Stadium/Gym',
    '100 Hougang Ave 2, Singapore 538856'
  ],
  [
    '1.31054736358854,103.762831357532',
    'Stadium',
    '15 W Coast Walk, Singapore 127162'
  ],
  [
    '1.31137729496485,103.764384219114',
    'Swimming Complex/Sports Hall/Gym',
    '426 Clementi Ave 3, Block 426, Singapore 120426'
  ],
  [
    '1.33893979108182,103.693702605961',
    'Swimming Complex/Sports Hall/Stadium/Tennis Centre/Gym',
    '980 Jurong West Street 93, Singapore 640980'
  ],
  [
    '1.32325195762473,103.872252956458',
    'Swimming Complex',
    'Kallang Basin Swim Cplx, Singapore'
  ],
  [
    '1.30680410822255,103.877357239552',
    'Practice Track/Field/Tennis Centre/Squash Centre/Netball Centre/Lawn Bowl',
    'Kallang ActiveSG Tennis Centre'
  ],
  [
    '1.30223475636127,103.885917296542',
    'Swimming Complex',
    '111 Wilkinson Rd, Singapore 436752'
  ],
  [
    '1.36240591106072,103.850044420756',
    'Swimming Complex',
    '1771 Ang Mo Kio Ave 1, Singapore 569978'
  ],
  [
    '1.35549795781487,103.851865316168',
    'Swimming Complex/Sports Hall/Stadium/Gym',
    '5 Bishan Street 14, #03-01, Singapore 579783'
  ],
  [
    '1.3449742165657,103.747781014088',
    'Swimming Complex',
    '2 Bukit Batok Street 22, Singapore 659581'
  ],
  [
    '1.35968730286159,103.751882635276',
    'Sports Hall/Stadium/Gym',
    '800A Bukit Batok West Ave 5, Singapore 659082'
  ],
  [
    '1.3266435360719,103.936351191135',
    'Stadium',
    '131 Bedok North Ave 3, Block 131, Singapore 46013'
  ],
  [
    '1.35925932367945,103.860926082782',
    'Squash Centre/Tennis Centre',
    '39 Burghley Dr, Singapore 559017'
  ],
  [
    '1.39035615823275,103.74745156842',
    'Swimming Complex/Sports Hall/Stadium/Futsal Court/Tennis Centre/Gym',
    'Blk 707 Choa Chu Kang Street 53, Singapore 680707'
  ],
  [
    '1.3340808063381,103.718512212638',
    'Stadium',
    '15 Fourth Chin Bee Rd, Singapore 619703'
  ]
];

List<SportsFacility> fetchSportsFacils() {
  List<SportsFacility> markers = <SportsFacility>[];

  for (int i = 0; i < res.length; i++) {
    String coords = res[i][0];
    double _latitude = double.parse(coords.split(",")[0]);
    double _longitude = double.parse(coords.split(",")[1]);

    String _address = res[i][2];
    List<String> _facilities = res[i][1].split("/");

    for (int j = 0; j < _facilities.length; j++) {
      //shift coordinates slightly if there are more than 1 facil for a place
      var randomGenerator = Random();
      _latitude = _latitude +
          (randomGenerator.nextInt(5) * 0.0001 * j) -
          (randomGenerator.nextInt(5) * 0.0001 * j);
      _longitude = _longitude +
          (randomGenerator.nextInt(5) * 0.0001 * j) -
          (randomGenerator.nextInt(5) * 0.0001 * j);

      String _facilityType = _facilities[j];

      SportsFacility sportsFacil = SportsFacility(
        facilityType: _facilityType,
        placeName: "", //was not able to get name for these
        addressDesc: _address,
        coordinates: LatLng(_latitude, _longitude),
        imagePath: _FindMarkerImage(_facilityType),
      );
      markers.add(sportsFacil);
      //print(sportsFacil);
    }
  }
  if (markers.length > 0) {
    // print('fetched ${markers.length} facilites from _fetchSportsFacilites');
  } else {
    print('smth went wrong in fetching the 35 sports facilities');
  }

  return markers;
}

//-----------------------------------------------------
/// Find Marker image path according to the facility Type
String _FindMarkerImage(String facilityType) {
  if (facilityType.contains("Gym")) {
    return ('gym-marker.png');
  }
  if (facilityType.contains("wim")) {
    return ('swimming-marker.png');
  }
  if (facilityType.contains("ennis")) {
    return ('tennis-marker.png');
  }
  if (facilityType.contains('all')) {
    return ('basketball-marker.png');
  }
  if (facilityType.contains("tadium")) {
    return ('stadium-marker.png');
  }
  if (facilityType.contains("Playground")) {
    return ('playground-marker.png');
  }
  if (facilityType.contains("Park")) {
    return ('park-marker.png');
  }
  if (facilityType.contains("Gaden")) {
    return ('garden-marker.png');
  }
  return ('sports-marker.png');
}

class SportsFacilDataSource {
  Future someFunction() async {
    List<SportsFacility> someList = await fetchPlaygroundParks();
    List<SportsFacility> anotherList = fetchSportsFacils();
    List<SportsFacility> finalList = someList + anotherList;
    return finalList;
  }
}

// need to uncomment dependencies and do import if want to use this fn
// import 'package:csv/csv.dart';
// abstract class someClass {
//   static void writeToCsv() async {
//     final playgroundParkList = await fetchPlaygroundParks();
//     final otherFacilList = fetchSportsFacils();

//     List<List> _facilList = [
//       ["Name", "Coordinates", "FacilityType", "Address", "imagePath"]
//     ];
//     playgroundParkList.forEach((facility) {
//       List _facilInfo = [];
//       _facilInfo.add(facility.placeName);
//       _facilInfo.add(facility.coordinates);
//       _facilInfo.add(facility.facilityType);
//       _facilInfo.add(facility.addressDesc);
//       _facilInfo.add(facility.imagePath);

//       _facilList.add(_facilInfo);
//     });

//     String csv = const ListToCsvConverter().convert(_facilList);
//     print(_facilList.length);
//     print(csv);

//     /// Write to a file
//     // final String directory = (await getApplicationSupportDirectory()).path;
//     // final path = "$directory/csv-${DateTime.now()}.csv";
//     // File file = await File(path);
//     // file.writeAsString(csv);
//   }
// }
