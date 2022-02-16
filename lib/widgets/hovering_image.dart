import 'package:flutter/material.dart';

class AnimatedImage extends StatefulWidget {
  AnimatedImage({Key? key, required this.imagePath}) : super(key: key);
  String imagePath;
  @override
  _AnimatedImageState createState() => _AnimatedImageState();
}

class _AnimatedImageState extends State<AnimatedImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..repeat(reverse: true);

  late Animation<Offset> _animation = Tween(
    begin: Offset.zero,
    end: Offset(0, 0.05),
  ).animate(CurvedAnimation(curve: Curves.fastOutSlowIn, parent: _controller));

  late final Animation<double> _animation2 = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutQuart,
  );

  //animates the position of a widget relative to its normal position

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 60,
        ),
        Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
            SlideTransition(
              child: Image.asset(
                widget.imagePath,
                fit: BoxFit.contain,
              ),
              position: _animation,
            ),
          ],
        ),
      ],
    );
  }
}
