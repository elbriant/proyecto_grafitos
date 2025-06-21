import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_grafitos/provider/settings_provider.dart';

class Vertex extends Marker {
  final String name;
  final int id;
  final Dimension via;
  final String? address;
  final String? rif;

  const Vertex({
    super.key,
    required super.point,
    required super.child,
    required this.via,
    super.width,
    super.height,
    super.alignment,
    super.rotate,
    this.name = '',
    required this.id,
    this.address,
    this.rif,
  });

  @override
  String toString() {
    return '[#$id:$name]';
  }

  @override
  bool operator ==(Object other) {
    return (other is Vertex) && (other.id == id) && (other.point == point);
  }

  @override
  int get hashCode => id.hashCode;
}

enum VertextIconSelection { from, to }

class VertextIcon extends StatelessWidget {
  const VertextIcon({super.key, required this.vertexPoint, required this.isCity});
  final LatLng vertexPoint;
  final bool isCity;

  @override
  Widget build(BuildContext context) {
    final verFrom = context.select<SettingsProvider, bool>(
      (p) => p.vertexFrom?.point == vertexPoint,
    );
    final verTo = context.select<SettingsProvider, bool>((p) => p.vertexTo?.point == vertexPoint);

    VertextIconSelection? selected =
        verFrom ? VertextIconSelection.from : (verTo ? VertextIconSelection.to : null);

    return GestureDetector(
      onTap: () => context.read<SettingsProvider>().markerTapped(vertexPoint),
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
