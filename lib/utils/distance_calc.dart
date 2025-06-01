import 'dart:math';

import 'package:latlong2/latlong.dart';

const double R = 6371e3; // Radio de la Tierra en metros

extension Astar on LatLng {
  /// Calcula la distancia en metros entre esta coordenada y otra
  /// usando la fórmula de Haversine (distancia en línea recta sobre la esfera terrestre)
  double distanceTo(LatLng other) {
    final phi1 = latitude * pi / 180;
    final phi2 = other.latitude * pi / 180;
    final deltaPhi = (other.latitude - latitude) * pi / 180;
    final deltaGamma = (other.longitude - longitude) * pi / 180;

    final a =
        sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaGamma / 2) * sin(deltaGamma / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }
}
