import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class DebugProvider extends ChangeNotifier {
  bool showDebug = false;
  double currentZoom = 1.0;
  LatLng? lastPoint;

  void toggleShowDebug() {
    showDebug = !showDebug;
    notifyListeners();
  }

  void setCurrentZoom(double value) {
    if (!showDebug) return; // avoid updating if not shower

    currentZoom = value;
    notifyListeners();
  }

  void setLastPoint(LatLng value) {
    if (!showDebug) return; // avoid updating if not shower

    lastPoint = value;
    notifyListeners();
  }
}
