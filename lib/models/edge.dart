import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:proyecto_grafitos/provider/settings_provider.dart';

class Edge extends Polyline {
  final double trafficWeight;
  final double lengthWeight;
  final Dimension via;

  Edge({
    required super.points,
    required this.trafficWeight,
    required this.lengthWeight,
    required this.via,
    super.strokeWidth = 3.5,
    super.pattern = const StrokePattern.solid(),
    super.color = const Color.fromARGB(40, 0, 0, 0),
    super.borderStrokeWidth = 0.0,
    super.borderColor = Colors.black,
  });

  @override
  String toString() {
    return '[path-${super.points.length}p]';
  }
}

class EdgeTime extends Polyline {
  EdgeTime({
    required super.points,
    super.strokeWidth = 3,
    super.pattern = const StrokePattern.solid(),
    super.color = const Color.fromARGB(255, 255, 246, 145),
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
    super.pattern = const StrokePattern.solid(),
    super.color = const Color.fromARGB(255, 37, 182, 218),
    super.borderStrokeWidth = 0.5,
    super.borderColor = Colors.black,
    super.strokeCap = StrokeCap.round,
    super.strokeJoin = StrokeJoin.round,
  });
}

class EdgeAll extends Polyline {
  EdgeAll({
    required super.points,
    super.strokeWidth = 3,
    super.pattern = const StrokePattern.solid(),
    super.color = const Color.fromARGB(255, 216, 67, 87),
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
