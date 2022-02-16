import 'package:flutter/material.dart';

class AnimatedHoverImage extends StatefulWidget {
  AnimatedHoverImage(
      {Key? key, required this.imagePath, required this.durationMilliseconds})
      : super(key: key);
  String imagePath;
  final int durationMilliseconds;
  @override
  _AnimatedHoverImageState createState() => _AnimatedHoverImageState();
}

class _AnimatedHoverImageState extends State<AnimatedHoverImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: widget.durationMilliseconds),
  )..repeat(reverse: true);

  late Animation<Offset> _animation = Tween(
    begin: Offset.zero,
    end: Offset(0, 0.05),
  ).animate(CurvedAnimation(curve: Curves.fastOutSlowIn, parent: _controller));

  late final Animation<double> _animation2 = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutQuart,
  );
  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  //animates the position of a widget relative to its normal position
  @override
  Widget build(BuildContext context) {
    return Stack(
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
    );
  }
}
