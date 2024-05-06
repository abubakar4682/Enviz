
import 'package:flutter/cupertino.dart';

class BoxwithIcon extends StatelessWidget {
  const BoxwithIcon({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 30,
      child: Image.asset('assets/images/Vector.png'),
    );
  }
}