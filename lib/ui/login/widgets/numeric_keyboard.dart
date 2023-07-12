import 'package:flutter/material.dart';

typedef KeyboardTapCallback = void Function(String text);

class NumericKeyboard extends StatefulWidget {
  /// Color of the text [default = Colors.black]
  final TextStyle textStyle;

  /// Display a custom right icon
  final Widget? rightIcon;

  final bool allowLeftLongPress;
  final bool allowRightLongPress;

  /// Action to trigger when right button is pressed
  final Function()? onTapRightButton;

  /// Action to trigger when right button is long pressed
  final Function()? onLongPressRightButton;

  /// Action to trigger when left button is long pressed
  final Function()? onLongPressLeftButton;

  /// Display a custom left icon
  final Widget? leftIcon;

  /// Action to trigger when left button is pressed
  final Function()? onTapLeftButton;

  /// Callback when an item is pressed
  final KeyboardTapCallback onKeyboardTap;

  /// Main axis alignment [default = MainAxisAlignment.spaceEvenly]
  final MainAxisAlignment mainAxisAlignment;

  const NumericKeyboard(
      {Key? key,
      required this.onKeyboardTap,
      this.textStyle = const TextStyle(color: Colors.black),
      this.onTapRightButton,
      this.onLongPressRightButton,
      this.rightIcon,
      this.onLongPressLeftButton,
      this.onTapLeftButton,
      this.leftIcon,
      this.allowLeftLongPress = false,
      this.allowRightLongPress = false,
      this.mainAxisAlignment = MainAxisAlignment.spaceBetween})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _NumericKeyboardState();
  }
}

class _NumericKeyboardState extends State<NumericKeyboard> {
  bool isLeftButtonPressed = false;
  bool isRightButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          ButtonBar(
            alignment: widget.mainAxisAlignment,
            children: <Widget>[
              _calcButton('1'),
              _calcButton('2'),
              _calcButton('3'),
            ],
          ),
          ButtonBar(
            alignment: widget.mainAxisAlignment,
            children: <Widget>[
              _calcButton('4'),
              _calcButton('5'),
              _calcButton('6'),
            ],
          ),
          ButtonBar(
            alignment: widget.mainAxisAlignment,
            children: <Widget>[
              _calcButton('7'),
              _calcButton('8'),
              _calcButton('9'),
            ],
          ),
          ButtonBar(
            alignment: widget.mainAxisAlignment,
            children: <Widget>[
              GestureDetector(
                child: InkWell(
                  borderRadius: BorderRadius.circular(45),
                  onTap: widget.onTapLeftButton,
                  onLongPress:
                      widget.allowLeftLongPress ? widget.onLongPressLeftButton ?? widget.onTapLeftButton : null,
                  child: Container(alignment: Alignment.center, width: 50, height: 50, child: widget.leftIcon),
                ),
                onLongPressStart: (_) async {
                  isLeftButtonPressed = true;
                  do {
                    widget.onLongPressLeftButton?.call();
                    await Future.delayed(const Duration(milliseconds: 30));
                  } while (isLeftButtonPressed);
                },
                onLongPressEnd: (_) => setState(() => isLeftButtonPressed = false),
              ),
              _calcButton('0'),
              GestureDetector(
                child: InkWell(
                  borderRadius: BorderRadius.circular(45),
                  onTap: widget.onTapRightButton,
                  onLongPress:
                      widget.allowRightLongPress ? widget.onLongPressRightButton ?? widget.onTapRightButton : null,
                  child: Container(alignment: Alignment.center, width: 50, height: 50, child: widget.rightIcon),
                ),
                onLongPressStart: (_) async {
                  isRightButtonPressed = true;
                  do {
                    widget.onLongPressRightButton?.call();
                    await Future.delayed(const Duration(seconds: 1));
                    await Future.delayed(const Duration(seconds: 1));
                  } while (isRightButtonPressed);
                },
                onLongPressEnd: (_) => setState(() => isRightButtonPressed = false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calcButton(String value) {
    return InkWell(
        borderRadius: BorderRadius.circular(45),
        onTap: () {
          widget.onKeyboardTap(value);
        },
        child: Container(
          alignment: Alignment.center,
          width: 50,
          height: 50,
          child: Text(
            value,
            style: widget.textStyle,
          ),
        ));
  }
}
