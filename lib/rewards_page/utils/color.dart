import 'package:flutter/material.dart';

///allows for color theme change
class ColorHelper {
  static Color keepOrWhite(Color textColor, Color backgroundColor,
      [Color? alternateColor]) {
    if (isDark(textColor) && isDark(backgroundColor))
      return alternateColor ?? Colors.white;
    return textColor;
  }

  static bool isDark(Color color) {
    return color.computeLuminance() < 0.5;
  }
}
