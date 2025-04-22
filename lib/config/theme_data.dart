import 'package:flutter/cupertino.dart';

final cupertinoAppTheme = CupertinoThemeData(
  brightness: Brightness.light,
  primaryColor: CupertinoColors.activeBlue,
  scaffoldBackgroundColor: CupertinoColors.white,
  textTheme: CupertinoTextThemeData(
    pickerTextStyle: TextStyle(
      color: CupertinoColors.black,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),
);