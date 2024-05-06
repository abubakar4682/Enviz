import 'package:flutter/material.dart';


import '../Theme/theme.dart';
import '../Utils/colors.dart';

class FilledRedButton extends StatelessWidget {
  VoidCallback onPressed;
  String text;

  FilledRedButton({

    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
      ),
      child: Container(
        width: deviceWidth,
        height: 45,
        // margin: const EdgeInsets.only(left: 30, right: 30, top: 20),
        margin: const EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          color:  Color(0xff009f8d),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            text,
            style: inoTheme.buttonTextStyle.copyWith(color: whiteColor),
          ),
        ),
      ),
    );
  }
}
