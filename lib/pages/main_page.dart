import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_grafitos/components/bottom_tools.dart' show BottomTools;
import 'package:proyecto_grafitos/components/debug_info.dart' show DebugInfo;
import 'package:proyecto_grafitos/components/dimension_tools.dart';
import 'package:proyecto_grafitos/components/loading_widget.dart';
import 'package:proyecto_grafitos/components/map_widget.dart';
import 'package:proyecto_grafitos/components/nav_drawer.dart';
import 'package:proyecto_grafitos/components/route_report.dart';
import 'package:proyecto_grafitos/provider/debug_provider.dart';
import 'package:proyecto_grafitos/provider/settings_provider.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final showDebug = context.select<DebugProvider, bool>((p) => p.showDebug);
    final isPathLoading = context.select<SettingsProvider, bool>((p) => p.isPathLoading);
    final existPathMetadata = context.select<SettingsProvider, bool>((p) => p.pathMetadata != null);

    return Scaffold(
      appBar: AppBar(title: Text('GrafitosApp')),
      drawer: NavDrawer(),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          MapWidget(),
          BottomTools(),
          Align(alignment: Alignment.topRight, child: DimensionTools()),
          if (existPathMetadata) Align(alignment: Alignment.topCenter, child: RouteReport()),
          if (isPathLoading) LoadingWidget(),
          Visibility(visible: showDebug, child: DebugInfo()),
        ],
      ),
    );
  }
}
