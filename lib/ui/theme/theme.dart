import 'package:flutter/material.dart';

///
/// Definition of App colors.
///
class RaceColors {
    
  static const Color primary = Color(0xFF5D63D1);
  static const Color secondary = Color(0xFFCFD1F2);

  static Color backgroundAccent   = const Color(0xFFEDEDED);
 
  static Color neutralDark        = const Color.fromARGB(255, 97, 95, 97);
  static Color neutral            = const Color.fromARGB(255, 163, 161, 163);

  static Color greyLight          = const Color(0xFFE2E2E2);
  
  static Color white              = Colors.white;

  static Color get backGroundColor { 
    return RaceColors.primary;
  }

  static Color get textNormal {
    return RaceColors.neutralDark;
  }

//   static Color get textLight {
//     return RaceColors.neutralLight;
//   }

  static Color get iconNormal {
    return RaceColors.neutral;
  }

//   static Color get iconLight {
//     return RaceColors.neutralLighter;
//   }

  static Color get disabled {
    return RaceColors.greyLight;
  }
}
  
///
/// Definition of App text styles.
///
class BlaTextStyles {
  static TextStyle heading = TextStyle(fontSize: 24, fontWeight: FontWeight.w500);

  static TextStyle title =  TextStyle(fontSize: 20, fontWeight: FontWeight.w400);

  static TextStyle body =  TextStyle(fontSize: 16, fontWeight: FontWeight.w400);

  static TextStyle label =  TextStyle(fontSize: 12, fontWeight: FontWeight.w400);

  static TextStyle button =  TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
}



///
/// Definition of App spacings, in pixels.
/// Bascially small (S), medium (m), large (l), extra large (x), extra extra large (xxl)
///
class BlaSpacings {
  static const double s = 15;
  static const double m = 22; 
  static const double l = 26; 
  static const double xl = 30; 
  static const double xxl = 94; 

  static const double radius = 10; 
  //static const double radiusLarge = 24; 
}


class BlaSize {
  static const double icon = 30;
}

///
/// Definition of App Theme.
///
ThemeData appTheme =  ThemeData(
  fontFamily: 'Roboto',
  scaffoldBackgroundColor: Colors.white,
);
 