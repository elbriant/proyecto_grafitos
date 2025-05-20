import 'package:flutter/material.dart';
import 'package:proyecto_grafitos/models/vertex.dart';

enum SelectButton { from, to }

enum SearchMode { time, length }

class SettingsProvider extends ChangeNotifier {
  SelectButton? buttonSelection;
  Set<SearchMode> searchMode = {};

  Vertex? vertexFrom;
  Vertex? vertexTo;

  void setButtonSelection(SelectButton? value) {
    buttonSelection = value;
    notifyListeners();
  }

  void setButtonLabel(Vertex? value) {
    switch (buttonSelection) {
      case SelectButton.from:
        vertexFrom = value;
        notifyListeners();
      case SelectButton.to:
        vertexTo = value;
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
