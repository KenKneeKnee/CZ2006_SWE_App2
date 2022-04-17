import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

//use to plot graph of user points on rewards page
ThemeData createTheme([Brightness? brightness]) {
  return ThemeData(
    brightness: brightness,
    fontFamily: "Quicksand",
    primarySwatch: Colors.deepOrange,
    accentColor: Colors.deepOrangeAccent,
    // This makes the visual density adapt to the platform that you run
    // the app on. For desktop platforms, the controls will be smaller and
    // closer together (more dense) than on mobile platforms.
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

class SummaryChart extends StatelessWidget {
  const SummaryChart(
      {Key? key,
      required this.maxValue,
      required this.data1,
      required this.data2})
      : super(key: key);
  final int maxValue;
  final List<FlSpot> data1;
  final List<FlSpot> data2;
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: -500,
        maxY: maxValue.toDouble(),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((e) {
                return LineTooltipItem("${e.y.toStringAsFixed(0)}",
                    Theme.of(context).textTheme.subtitle1 as TextStyle);
              }).toList();
            },
          ),
        ),
        gridData: buildFlGridData(),
        titlesData: buildFlTitlesData(context),
        lineBarsData: [
          buildLineChartBarData(
            data1,
            [Colors.tealAccent.withOpacity(0.5)],
          ),
          buildLineChartBarData(
            data2,
            [Colors.redAccent.withOpacity(0.5)],
          ),
        ],
      ),
    );
  }

  LineChartBarData buildLineChartBarData(data, List<Color> colors) {
    return LineChartBarData(
      belowBarData: BarAreaData(
          colors: colors.map((color) => color.withOpacity(0.2)).toList(),
          show: true),
      isCurved: true,
      preventCurveOverShooting: true,
      colors: colors,
      dotData: FlDotData(show: false),
      spots: data,
    );
  }

  FlTitlesData buildFlTitlesData(context) {
    return FlTitlesData(
      bottomTitles: SideTitles(
        showTitles: false,
        reservedSize: 22,
        //textStyle:
        //Theme.of(context).textTheme.caption.copyWith(color: Colors.white70),
        margin: 10,
        getTitles: (value) {
          // return DateFormat.E()
          //     .format(startDate.add(Duration(days: value.toInt())));

          return value.toString();
        },
      ),
      leftTitles: SideTitles(
        showTitles: false,
        //textStyle:
        //Theme.of(context).textTheme.caption.copyWith(color: Colors.white70),
        getTitles: (value) {
          // if (value % (maxValue / 5) == 0)
          //   return "${value.remainder(1) == 0 ? value.toInt() : value.toStringAsFixed(1)}";
          return "";
        },
        margin: 8,
        reservedSize: 30,
      ),
    );
  }

  FlGridData buildFlGridData() {
    return FlGridData(
      drawHorizontalLine: true,
      drawVerticalLine: true,
      horizontalInterval: maxValue / 2,
      getDrawingHorizontalLine: (value) {
        return FlLine(
            // dashArray: value == 0 ? null : [4],
            color: Colors.white10,
            strokeWidth: 0.5);
      },
      getDrawingVerticalLine: (value) {
        return FlLine(
            dashArray: value == 0 ? null : [4],
            color: Colors.transparent,
            strokeWidth: 1);
      },
    );
  }
}
