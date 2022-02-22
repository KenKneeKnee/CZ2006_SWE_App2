import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieMap extends StatefulWidget {
  const LottieMap({Key? key}) : super(key: key);

  @override
  _LottieMapState createState() => _LottieMapState();
}

class _LottieMapState extends State<LottieMap> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Stack(
          children: [
            Text('Fetching Locations..'),
            Lottie.network(
              'https://assets6.lottiefiles.com/packages/lf20_qjeqt7ez.json',
              repeat: true,
              reverse: true,
              animate: true,
              frameRate: FrameRate.max,
            ),
          ],
        ),
      ),
    );
  }
}
