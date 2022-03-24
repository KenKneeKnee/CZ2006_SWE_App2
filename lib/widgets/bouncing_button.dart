import 'package:flutter/material.dart';

class BouncingButton extends StatefulWidget {
  BouncingButton({
    Key? key,
    required this.bgColor,
    required this.borderColor,
    required this.buttonText,
    required this.textColor,
    required this.onClick,
  }) : super(key: key);

  final Color bgColor;
  final Color borderColor;
  final String buttonText;
  final Color textColor;

  void Function() onClick;
  //MaterialPageRoute routeTo;
  //routeTo: MaterialPageRoute(builder: (context) => RegisterPage())

  @override
  _BouncingButtonState createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late double _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, //works only when this widget is in play on screen
      duration: const Duration(
        milliseconds: 100,
      ),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    return Center(
      child: GestureDetector(
        onTap: widget.onClick,
        onTapDown: _tapDown,
        onTapUp: _tapUp,
        child: Transform.scale(
          scale: _scale,
          child: _animatedButton(),
        ),
      ),
    );
  }

  Widget _animatedButton() {
    return Container(
      height: 40,
      width: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.0),
        border: Border.all(
          color: widget.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2.0,
            offset: Offset(0.0, 5.0),
          ),
        ],
        color: widget.bgColor,
      ),
      child: Center(
        child: Text(
          widget.buttonText,
          style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: widget.textColor),
        ),
      ),
    );
  }

  void _tapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _tapUp(TapUpDetails details) {
    _controller.reverse();
  }
}

class ButtonIcon extends StatefulWidget {
  ButtonIcon({
    Key? key,
    required this.bgColor,
    required this.borderColor,
    required this.buttonText,
    required this.textColor,
    required this.onClick,
    required this.icon,
  }) : super(key: key);

  final Color bgColor;
  final Color borderColor;
  final String buttonText;
  final Color textColor;
  final Icon icon;

  void Function() onClick;

  @override
  State<ButtonIcon> createState() => _ButtonIconState();
}

class _ButtonIconState extends State<ButtonIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late double _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, //works only when this widget is in play on screen
      duration: const Duration(
        milliseconds: 100,
      ),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    return Center(
      child: GestureDetector(
        onTap: widget.onClick,
        onTapDown: _tapDown,
        onTapUp: _tapUp,
        child: Transform.scale(
          scale: _scale,
          child: _animatedButton(),
        ),
      ),
    );
  }

  Widget _animatedButton() {
    return Container(
      height: 40,
      width: 180,
      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.0),
        border: Border.all(
          color: widget.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2.0,
            offset: Offset(0.0, 5.0),
          ),
        ],
        color: widget.bgColor,
      ),
      child: Row(
        children: [
          Container(
            child: widget.icon,
            margin: EdgeInsets.all(5),
          ),
          Text(
            widget.buttonText,
            style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: widget.textColor),
          ),
        ],
      ),
    );
  }

  void _tapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _tapUp(TapUpDetails details) {
    _controller.reverse();
  }
}
