import 'package:flutter/material.dart';
import '../constants/color_constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: ColorConstants.primaryColor,
      scaffoldBackgroundColor: ColorConstants.backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorConstants.primaryColor,
        elevation: 0,
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: ColorConstants.accentColor,
      ),
    );
  }
}
