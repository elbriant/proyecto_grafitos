import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class Edge extends Polyline {
  final double trafficWeight;
  final double lengthWeight;

  Edge({
    required super.points,
    required this.trafficWeight,
    required this.lengthWeight,
    super.strokeWidth = 3.5,
    super.pattern = const StrokePattern.solid(),
    super.color = Colors.black54,
    super.borderStrokeWidth = 0.0,
    super.borderColor = Colors.black,
  });
}

class EdgeTime extends Polyline {
  EdgeTime({
    required super.points,
    super.strokeWidth = 3,
    super.pattern = const StrokePattern.dotted(),
    super.color = Colors.yellow,
    super.borderStrokeWidth = 0.5,
    super.borderColor = Colors.black,
    super.strokeCap = StrokeCap.round,
    super.strokeJoin = StrokeJoin.round,
  });
}

class EdgeLength extends Polyline {
  EdgeLength({
    required super.points,
    super.strokeWidth = 3,
    super.pattern = const StrokePattern.dotted(),
    super.color = Colors.purpleAccent,
    super.borderStrokeWidth = 0.5,
    super.borderColor = Colors.black,
    super.strokeCap = StrokeCap.round,
    super.strokeJoin = StrokeJoin.round,
  });
}

class EdgeAlternative extends Polyline {
  EdgeAlternative({
    required super.points,
    super.strokeWidth = 2.5,
    super.pattern = const StrokePattern.dotted(),
    super.color = Colors.blueGrey,
    super.strokeCap = StrokeCap.round,
    super.strokeJoin = StrokeJoin.round,
  });
}
