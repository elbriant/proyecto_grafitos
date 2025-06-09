import 'package:proyecto_grafitos/models/vehicle.dart';

class PathMetadata {
  final Vehicle vehicle;
  final double totalDistanceInKm;
  final String estimatedTime;

  PathMetadata({
    required this.vehicle,
    required this.totalDistanceInKm,
    required this.estimatedTime,
  });
}
