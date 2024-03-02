import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class fullWidthButton extends StatefulWidget {
  final bool isSmall;
  final String buttonText;
  final VoidCallback onPress;
  final Color primaryColor;
  final Color textColor;

  const fullWidthButton(
      {super.key,
      required this.isSmall,
      required this.buttonText,
      required this.onPress,
      required this.primaryColor,
      required this.textColor});

  @override
  State<fullWidthButton> createState() => _fullWidthButtonState();
}

class _fullWidthButtonState extends State<fullWidthButton> {
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.95,
      child: Container(
          height: 60,
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: TextButton(
            onPressed: widget.onPress,
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(widget.primaryColor),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)))),
            child: Text(widget.buttonText,
                style: TextStyle(
                    fontSize: widget.isSmall ? 15 : 20,
                    fontWeight: FontWeight.w600,
                    color: widget.textColor)),
          )),
    );
  }
}

class halfWidthOutlineButton extends StatefulWidget {
  final String buttonText;
  final VoidCallback onPress;
  final Color color;

  const halfWidthOutlineButton(
      {super.key,
      required this.buttonText,
      required this.onPress,
      required this.color});

  @override
  _halfWidthOutlineButtonState createState() => _halfWidthOutlineButtonState();
}

class _halfWidthOutlineButtonState extends State<halfWidthOutlineButton> {
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.60,
      child: Container(
          height: 50,
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: TextButton(
            onPressed: widget.onPress,
            style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
                side: MaterialStateProperty.all(
                    BorderSide(width: 1, color: widget.color))),
            child: Text(widget.buttonText,
                style: TextStyle(fontSize: 15, color: widget.color)),
          )),
    );
  }
}
