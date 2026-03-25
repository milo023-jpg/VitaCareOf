import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  int selectedColor = 0;
  bool isDarkmode = false;

  void changeColorIndex(int colorIndex) {
    selectedColor = colorIndex;
    notifyListeners();
  }

  void toggleDarkmode() {
    isDarkmode = !isDarkmode;
    notifyListeners();
  }
}
