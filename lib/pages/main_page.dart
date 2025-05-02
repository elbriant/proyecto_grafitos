import 'package:flutter/material.dart';
import 'package:proyecto_grafitos/components/map_sample.dart';
import 'package:proyecto_grafitos/components/mode_selection.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('GrafitosApp')),
      drawer: NavigationDrawer(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text('Configuracion', style: Theme.of(context).textTheme.titleSmall),
          ),
          NavigationDrawerDestination(label: Text('placeholder'), icon: Icon(Icons.abc)),
          const Padding(padding: EdgeInsets.fromLTRB(28, 16, 28, 10), child: Divider()),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text('Otros', style: Theme.of(context).textTheme.titleSmall),
          ),
          NavigationDrawerDestination(label: Text('placeholder'), icon: Icon(Icons.abc)),
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          MapSample(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: ElevatedButton(onPressed: () {}, child: Text('Desde'))),
                      SizedBox(width: 20),
                      Expanded(child: ElevatedButton(onPressed: () {}, child: Text('Hasta'))),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ModeSelection(),
                    FloatingActionButton.extended(onPressed: () {}, label: Text('Buscar')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
