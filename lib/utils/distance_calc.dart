import 'dart:math';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:proyecto_grafitos/provider/settings_provider.dart';

const double R = 6371e3; // Radio de la Tierra en metros

// km/h
final speeds = {
  Dimension.aerial: 800.0, // Velocidad crucero avión comercial
  Dimension.maritime: 40.0, // Velocidad barco promedio
  Dimension.land: 90.0, // Auto
};

extension Astar on LatLng {
  /// Calcula la distancia en metros entre esta coordenada y otra
  /// usando la fórmula de Haversine (distancia en línea recta sobre la esfera terrestre)
  double distanceTo(LatLng other, [bool inKm = false]) {
    final phi1 = latitude * pi / 180;
    final phi2 = other.latitude * pi / 180;
    final deltaPhi = (other.latitude - latitude) * pi / 180;
    final deltaGamma = (other.longitude - longitude) * pi / 180;

    final a =
        sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaGamma / 2) * sin(deltaGamma / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return (R * (inKm ? 1e-3 : 1)) * c;
  }
}

extension Calcs on Polyline {
  /// Devuelve la distancia total en kilómetros con 2 decimales de precisión
  double calculateTotalDistance() {
    if (points.length < 2) return 0.0;

    double totalDistance = 0.0;

    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += points[i].distanceTo(points[i + 1], true);
    }

    return double.parse(totalDistance.toStringAsFixed(2));
  }
}

/// Devuelve la distancia total en kilómetros con 2 decimales de precisión
double calculateTotalDistance(List<LatLng> points) {
  if (points.length < 2) return 0.0;

  double totalDistance = 0.0;

  for (int i = 0; i < points.length - 1; i++) {
    totalDistance += points[i].distanceTo(points[i + 1], true);
  }

  return double.parse(totalDistance.toStringAsFixed(2));
}

String estimateTravelTime(double distance, Dimension via) {
  // Obtener velocidad según método
  final speed = speeds[via] ?? 0.0;
  // Calcular tiempo en horas (distancia / velocidad)
  double totalHours = distance / speed;
  // Descomponer en horas y minutos
  int hours = totalHours.floor();
  int minutes = ((totalHours - hours) * 60).round();
  // Ajustar formato si minutos son 60
  if (minutes >= 60) {
    hours += 1;
    minutes -= 60;
  }

  return '${hours > 0 ? '$hours hora(s)' : ''} ${minutes > 0 ? '$minutes minuto(s)' : ''}';
}
