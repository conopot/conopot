import 'package:flutter/widgets.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double defaultSize;
  static late Orientation orientation;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;

    /// 화면 방향 (가로 = portrait, 세로 = landscape)
    // On iPhone 11 the defaultSzie = 10 almost
    // So if the screen size increase or decrease then out defaultSize also vary
    defaultSize = orientation == Orientation.landscape
        ? screenHeight * 0.0027
        : screenWidth * 0.0027;
  }
}
