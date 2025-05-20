import 'dart:ui';

import 'package:flutter_map/flutter_map.dart';

class Edge extends Polyline {
  final double trafficWeight;
  final double lenghtWeight;

  Edge({
    required super.points,
    required this.trafficWeight,
    required this.lenghtWeight,
    super.strokeWidth = 1.0,
    super.pattern = const StrokePattern.solid(),
    super.color = const Color(0xFF00FF00),
    super.borderStrokeWidth = 0.0,
    super.borderColor = const Color(0xFFFFFF00),
    super.gradientColors,
    super.colorsStop,
    super.strokeCap = StrokeCap.round,
    super.strokeJoin = StrokeJoin.round,
    super.useStrokeWidthInMeter = false,
    super.hitValue,
  });
}
