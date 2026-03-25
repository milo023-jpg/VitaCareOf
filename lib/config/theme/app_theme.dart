import 'package:flutter/material.dart';

const List<Color> colorsList = [
  Colors.blue,
  Colors.teal,
  Colors.green,
  Colors.red,
  Colors.purple,
  Colors.deepPurple,
  Colors.orange,
  Colors.pink,
  Colors.pinkAccent,
];

class AppTheme {
  final int selectedColor;
  final bool isDarkmode;

  AppTheme({
    this.selectedColor = 0,
    this.isDarkmode = false,
  }) : assert(selectedColor >= 0, 'Selected color must be greater than >= 0'),
       assert(
         selectedColor < colorsList.length,
         'Selected color must be less than < ${colorsList.length}',
       );

  ThemeData getTheme() => ThemeData(
    useMaterial3: true,
    brightness: isDarkmode ? Brightness.dark : Brightness.light,
    colorSchemeSeed: colorsList[selectedColor],
    appBarTheme: const AppBarTheme(centerTitle: false),
  );
}
