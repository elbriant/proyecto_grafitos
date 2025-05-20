import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_grafitos/provider/settings_provider.dart';

class Vertex extends Marker {
  final String name;
  final int id;
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
    this.address,
    this.rif,
  });
}

enum VertextIconSelection { from, to }

class VertextIcon extends StatelessWidget {
  const VertextIcon({super.key, required this.vertexId, required this.isCity});
  final int vertexId;
  final bool isCity;

  @override
  Widget build(BuildContext context) {
    final verFrom = context.select<SettingsProvider, Vertex?>((p) => p.vertexFrom);
    final verTo = context.select<SettingsProvider, Vertex?>((p) => p.vertexTo);

    VertextIconSelection? selected =
        verFrom?.id == vertexId
            ? VertextIconSelection.from
            : (verTo?.id == vertexId ? VertextIconSelection.to : null);

    return GestureDetector(
      onTap: () => context.read<SettingsProvider>().markerTapped(vertexId),
      child:
          isCity
              ? Icon(
                Icons.location_on,
                color: switch (selected) {
                  VertextIconSelection.from => Colors.redAccent,
                  VertextIconSelection.to => Colors.green,
                  _ => Colors.blueAccent,
                },
                shadows: [Shadow(blurRadius: 3), Shadow(blurRadius: 3), Shadow(blurRadius: 3)],
              )
              : Icon(
                Icons.location_city,
                color: switch (selected) {
                  VertextIconSelection.from => Colors.redAccent,
                  VertextIconSelection.to => Colors.green,
                  _ => Colors.grey[350],
                },
                shadows: [Shadow(blurRadius: 3), Shadow(blurRadius: 3), Shadow(blurRadius: 3)],
              ),
    );
  }
}
