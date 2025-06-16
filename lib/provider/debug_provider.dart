import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class DebugProvider extends ChangeNotifier {
  bool showDebug = false;
  bool useExternalProvider = false;
  bool useAStar = false;
  double currentZoom = 1.0;
  LatLng? lastPoint;
  bool forceHideVertex = false;
  bool forceShowEdges = false;

  void toggleShowDebug() {
    showDebug = !showDebug;
    notifyListeners();
  }

  void toggleForceHideVertex() {
    forceHideVertex = !forceHideVertex;
    notifyListeners();
  }

  void toggleForceShowEdges() {
    forceShowEdges = !forceShowEdges;
    notifyListeners();
  }

  void toggleUseExternalProvider() {
    useExternalProvider = !useExternalProvider;
    notifyListeners();
  }

  void toggleUseAStar() {
    useAStar = !useAStar;
    notifyListeners();
  }

  void setCurrentZoom(double value) {
    currentZoom = value;
    notifyListeners();
  }

  void setLastPoint(LatLng value) {
    if (!showDebug) return; // avoid updating if not shower

    lastPoint = value;
    notifyListeners();
  }
}
