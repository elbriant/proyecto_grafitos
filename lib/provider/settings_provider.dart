import 'package:flutter/material.dart';

enum SelectButton { from, to }

enum SearchMode { time, length }

class SettingsProvider extends ChangeNotifier {
  SelectButton? buttonSelection;
  Set<SearchMode> searchMode = {};

  String? buttonFromLabel;
  String? buttonToLabel;

  void setButtonSelection(SelectButton? value) {
    buttonSelection = value;
    notifyListeners();
  }

  void setButtonLabel(String? value) {
    switch (buttonSelection) {
      case SelectButton.from:
        buttonFromLabel = value;
        notifyListeners();
      case SelectButton.to:
        buttonToLabel = value;
        notifyListeners();
      default:
        break;
    }
  }

  void setSearchMode(Set<SearchMode> value) {
    searchMode = value;
    notifyListeners();
  }
}
