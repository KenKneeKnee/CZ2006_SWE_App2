import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

//// URLs to Lottie animations
const String _eventLottie =
    'https://assets9.lottiefiles.com/packages/lf20_163wm8ao.json';
const String _mapLottie =
    'https://assets6.lottiefiles.com/packages/lf20_qjeqt7ez.json';

class LottieRecommend extends StatefulWidget {
  const LottieRecommend({Key? key}) : super(key: key);

  @override
  State<LottieRecommend> createState() => _LottieRecommendState();
}

class _LottieRecommendState extends State<LottieRecommend> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: SizedBox(height: 150, child: _wavyRecommend())),
          SizedBox(height: 100),
          Center(
            child: SizedBox(
              height: 300,
              child: _lottie(_eventLottie),
            ),
          ),
        ],
      ),
    );
  }
}

class LottieMap extends StatefulWidget {
  const LottieMap({Key? key}) : super(key: key);

  @override
  _LottieMapState createState() => _LottieMapState();
}

class _LottieMapState extends State<LottieMap> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: SizedBox(height: 150, child: _wavy())),
          SizedBox(height: 100),
          Center(
            child: SizedBox(
              height: 300,
              child: _lottie(_mapLottie),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _wavyRecommend() {
  return DefaultTextStyle(
    style: const TextStyle(
      fontSize: 25.0,
      color: Colors.blueGrey,
      fontWeight: FontWeight.bold,
    ),
    child: AnimatedTextKit(
      animatedTexts: [
        WavyAnimatedText("Fetching Recommendations ....",
            speed: Duration(milliseconds: 200)),
      ],
      isRepeatingAnimation: true,
      repeatForever: true,
    ),
  );
}

Widget _wavy() {
  return DefaultTextStyle(
    style: const TextStyle(
      fontSize: 25.0,
      color: Colors.blueGrey,
      fontWeight: FontWeight.bold,
    ),
    child: AnimatedTextKit(
      animatedTexts: [
        WavyAnimatedText("Loading Map....", speed: Duration(milliseconds: 200)),
        WavyAnimatedText('Fetching Data...',
            speed: Duration(milliseconds: 200)),
      ],
      isRepeatingAnimation: true,
      repeatForever: true,
    ),
  );
}

Widget _lottie(String url) {
  return Lottie.network(
    url,
    repeat: true,
    reverse: true,
    animate: true,
    frameRate: FrameRate.max,
  );
}

class LottieEvent extends StatelessWidget {
  const LottieEvent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: _lottie(_eventLottie));
  }
}
