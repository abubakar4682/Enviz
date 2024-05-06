import 'package:flutter/cupertino.dart';

class CustomText extends StatelessWidget {
  final String texts;
  final Color textColor;

  CustomText({
    Key? key,
    required this.texts,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      texts,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0,
        // Color(0xff002F46),

        color: textColor,
      ),
    );
  }
}