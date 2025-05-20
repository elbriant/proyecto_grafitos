import 'package:flutter_map/flutter_map.dart';

class Vertex extends Marker {
  final String name;
  final int id;
  final bool isCity;
  final String? address;
  final String? rif;

  const Vertex({
    super.key,
    required super.point,
    required super.child,
    super.width,
    super.height,
    super.alignment,
    super.rotate,
    this.name = '',
    required this.id,
    required this.isCity,
    this.address,
    this.rif,
  });
}
