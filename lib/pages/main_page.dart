import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_grafitos/components/bottom_tools.dart' show BottomTools;
import 'package:proyecto_grafitos/components/debug_info.dart' show DebugInfo;
import 'package:proyecto_grafitos/components/map_sample.dart';
import 'package:proyecto_grafitos/components/nav_drawer.dart';
import 'package:proyecto_grafitos/provider/debug_provider.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final showDebug = context.select<DebugProvider, bool>((p) => p.showDebug);

    return Scaffold(
      appBar: AppBar(
        title: Text('GrafitosApp'),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))],
      ),
      drawer: NavDrawer(),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [MapSample(), BottomTools(), Visibility(visible: showDebug, child: DebugInfo())],
      ),
    );
  }
}
