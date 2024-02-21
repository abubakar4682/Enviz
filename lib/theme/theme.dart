import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Utils/colors.dart';


InoTheme inoTheme = InoTheme();

class InoTheme {
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? letterSpacing;
  final Color? textColor;
  final TextDecoration? decoration;
  final Color? decorationColor;
  final double? lineheight;

  InoTheme({
    this.fontSize,
    this.fontWeight,
    this.letterSpacing,
    this.textColor,
    this.decoration,
    this.decorationColor,
    this.lineheight,
  });

  TextStyle get style {
    return TextStyle(
      fontFamily: 'Commissioner',
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: textColor,
      decoration: decoration,
      decorationColor: decorationColor,
      height: lineheight,
    );
  }

  TextStyle Heading = const TextStyle(
    fontFamily: 'Commissioner',
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.24,
    color: blackColor,
  );

  TextStyle mainHeading = const TextStyle(
    fontFamily: 'Commissioner',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.24,
    color: blackColor,
  );

  late final TextStyle textStyle = TextStyle(
    fontFamily: 'Commissioner',
    fontSize: fontSize,
    fontWeight: fontWeight,
    letterSpacing: -0.24,
    height: lineheight,
    color: textColor,
  );

  late final TextStyle textStyle2 = const TextStyle(
    fontFamily: 'Commissioner',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
    color: blackColor,
    decoration: TextDecoration.underline,
    decorationColor: blackColor,
  );
  late final TextStyle textStyle3 = TextStyle(
    fontFamily: 'Commissioner',
    fontSize: fontSize,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
    color: blackColor,
    decoration: TextDecoration.underline,
    decorationColor: blackColor,
  );

  late final TextStyle buttonTextStyle = TextStyle(
    fontFamily: 'Commissioner',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.24,
    color: textColor,
  );

  late final TextStyle labelStyle = const TextStyle(
    fontFamily: 'Commissioner',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
    color: blackColor,
  );

  late final TextStyle hintStyle = TextStyle(
    fontFamily: 'Commissioner',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
    fontStyle: FontStyle.italic,
    color: greyColor,
  );

  late final TextStyle navigationLabelStyle = TextStyle(
    fontFamily: 'Commissioner',
    fontSize: 12,
    fontWeight: fontWeight,
    letterSpacing: -0.24,
    color: blackColor,
  );

  late final TextStyle tabLabelStyle = TextStyle(
    fontFamily: 'Commissioner',
    fontSize: 14,
    fontWeight: fontWeight,
    letterSpacing: -0.24,
    color: blackColor,
  );
}

const TextStyle bntText = TextStyle(
  fontFamily: 'Commissioner',
  fontSize: 12,
  fontWeight: FontWeight.w500,
  letterSpacing: -0.18,
  color: blackColor,
);

const TextStyle regular10 = TextStyle(
  fontFamily: 'Commissioner',
  fontSize: 10,
  fontWeight: FontWeight.w400,
  letterSpacing: -0.15,
  color: blackColor,
);

const TextStyle regular12 = TextStyle(
  fontFamily: 'Commissioner',
  fontSize: 12,
  fontWeight: FontWeight.w400,
  letterSpacing: -0.18,
  color: blackColor,
);

const TextStyle regular14 = TextStyle(
  fontFamily: 'Commissioner',
  fontSize: 14,
  fontWeight: FontWeight.w400,
  letterSpacing: -0.21,
  color: blackColor,
);

const TextStyle regular16 = TextStyle(
  fontFamily: 'Commissioner',
  fontSize: 16,
  fontWeight: FontWeight.w400,
  letterSpacing: -0.24,
  color: Color(0xff424242),
);

const TextStyle regular18 = TextStyle(
  fontFamily: 'Commissioner',
  fontSize: 18,
  fontWeight: FontWeight.w400,
  letterSpacing: -0.27,
  color: blackColor,
);

const TextStyle underline_text = TextStyle(
  fontFamily: 'Commissioner',
  fontSize: 18,
  fontWeight: FontWeight.w400,
  letterSpacing: -0.27,
  color: blackColor,
  decoration: TextDecoration.underline,
  decorationColor: blackColor,
);
