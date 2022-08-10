import 'package:flutter/widgets.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double defaultSize;
  static late Orientation orientation;

  init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;
    
    // On iPhone 11 the defaultSzie = 10 almost
    // So if the screen size increase or decrease then out defaultSize also vary
    defaultSize = orientation == Orientation.landscape
        ? screenHeight * 0.027 / MediaQuery.of(context).textScaleFactor
        : screenWidth * 0.027 / MediaQuery.of(context).textScaleFactor;
  }
}
