import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_grafitos/provider/debug_provider.dart';

class DebugInfo extends StatelessWidget {
  const DebugInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final debugData = context.watch<DebugProvider>();

    return Column(
      children: [
        Text('zoom: ${debugData.currentZoom}'),
        Text('last point: ${debugData.lastPoint}'),
      ],
    );
  }
}
