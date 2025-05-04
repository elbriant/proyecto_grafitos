import 'package:flutter_map/flutter_map.dart';

class Vertex extends Marker {
  final String name;
  final int id;

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
  });
}
