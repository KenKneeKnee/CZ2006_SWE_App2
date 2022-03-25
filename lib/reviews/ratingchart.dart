/// Horizontal bar chart example
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:my_app/map/map_data.dart';

class StarSeries {
  final String star;
  final int score;
  final int count;
  final charts.Color barColor;

  StarSeries({
    required this.star,
    required this.score,
    required this.count,
    required this.barColor,
  });
}

// List<StarSeries> stardata = [
//   StarSeries(
//     star: "1 star",
//     score: 1,
//     count: 11,
//     barColor: charts.ColorUtil.fromDartColor(Colors.red),
//   ),
//   StarSeries(
//     star: "2 star",
//     score: 2,
//     count: 12,
//     barColor: charts.ColorUtil.fromDartColor(Colors.orange),
//   ),
//   StarSeries(
//     star: "3 star",
//     score: 3,
//     count: 15,
//     barColor: charts.ColorUtil.fromDartColor(Colors.blue),
//   ),
//   StarSeries(
//     star: "4 star",
//     score: 4,
//     count: 18,
//     barColor: charts.ColorUtil.fromDartColor(Colors.green),
//   ),
//   StarSeries(
//     star: "5 star",
//     score: 5,
//     count: 13,
//     barColor: charts.ColorUtil.fromDartColor(Colors.purple),
//   )
// ];

class RatingChart extends StatelessWidget {
  RatingChart({Key? key, required this.sportsFacility, required this.stardata}) : super(key: key);
  final Map stardata;
  SportsFacility sportsFacility;
  final chartColors={
    1: charts.ColorUtil.fromDartColor(Colors.redAccent),
    2: charts.ColorUtil.fromDartColor(Colors.orangeAccent),
    3: charts.ColorUtil.fromDartColor(Colors.blueAccent),
    4: charts.ColorUtil.fromDartColor(Colors.greenAccent),
    5: charts.ColorUtil.fromDartColor(Colors.purpleAccent),
  };
  @override
  Widget build(BuildContext context) {
    List<StarSeries> data=[];
    for (int rating in stardata.keys) {
      data.add(StarSeries(
          star: "${rating} star",
          score: rating,
          count: stardata[rating],
          barColor: chartColors[rating]!));
    }
    List<charts.Series<StarSeries, String>> series = [
      charts.Series(
          id: "Stars",
          data: data,
          domainFn: (StarSeries series, _) => series.star,
          measureFn: (StarSeries series, _) => series.count,
          colorFn: (StarSeries series, _) => series.barColor)
    ];

    double avgRating = calcAvgRating(data);
    int total = data.length;
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sports_tennis,
                size: 50,
                color: Colors.red,
              ),
              Text(
                sportsFacility.placeName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                sportsFacility.facilityType,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${avgRating}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                        ),
                      ),
                      RatingBarIndicator(
                        rating: avgRating,
                        itemBuilder: (context, index) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 20.0,
                        direction: Axis.horizontal,
                      ),
                      Text(
                        "based on ${total} reviews",
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: charts.BarChart(
                    series,
                    animate: true,
                    vertical: false,
                    defaultRenderer: new charts.BarRendererConfig(
                        cornerStrategy: const charts.ConstCornerStrategy(30)),
                    primaryMeasureAxis: new charts.NumericAxisSpec(
                        renderSpec: new charts.NoneRenderSpec()),
                    domainAxis: new charts.OrdinalAxisSpec(
                      // Make sure that we draw the domain axis line.
                      showAxisLine: true,
                      // But don't draw anything else.
                      // renderSpec: new charts.NoneRenderSpec(),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

double calcAvgRating(List<StarSeries> data) {
  int sumRating = 0;

  for (int i = 0; i < data.length; i++) {
    sumRating += (data[i].score*data[i].count);
  }

  double average = (sumRating / data.length);
  return average;
}
