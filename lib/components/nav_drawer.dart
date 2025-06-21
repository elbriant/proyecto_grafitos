import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_grafitos/pages/log_page.dart';
import 'package:proyecto_grafitos/provider/debug_provider.dart';
import 'package:proyecto_grafitos/provider/settings_provider.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final debugToggle = context.select<DebugProvider, bool>((p) => p.showDebug);
    final externalAPIToggle = context.select<DebugProvider, bool>((p) => p.useExternalProvider);
    final aStar = context.select<DebugProvider, bool>((p) => p.useAStar);
    final hasLastLog = context.select<SettingsProvider, bool>((p) => p.lastLog != null);
    final forceHideVertex = context.select<DebugProvider, bool>((p) => p.forceHideVertex);
    final forceShowEdges = context.select<DebugProvider, bool>((p) => p.forceShowEdges);

    return NavigationDrawer(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
          child: Text('Vistas', style: Theme.of(context).textTheme.titleSmall),
        ),
        const SizedBox(height: 6),
        NavigationDrawerDestination(label: Text('Mapa'), icon: Icon(Icons.map)),
        const Padding(padding: EdgeInsets.fromLTRB(28, 16, 28, 10), child: Divider()),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
          child: Text('Otros', style: Theme.of(context).textTheme.titleSmall),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 0, 10),
          child: SwitchListTile(
            title: Text('Mostrar datos de depuración'),
            value: debugToggle,
            onChanged: (_) {
              context.read<DebugProvider>().toggleShowDebug();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 0, 10),
          child: SwitchListTile(
            title: Text('Usar API externa'),
            value: externalAPIToggle,
            onChanged: (_) {
              context.read<DebugProvider>().toggleUseExternalProvider();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 0, 10),
          child: SwitchListTile(
            title: Text('Forzar uso de A*'),
            value: aStar,
            onChanged: (_) {
              context.read<DebugProvider>().toggleUseAStar();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 0, 10),
          child: ListTile(
            title: Text('Recargar VertexData'),
            onTap: () {
              context.read<SettingsProvider>().loadDBData();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('reloading')));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 0, 10),
          child: ListTile(
            title: Text('Logs'),
            enabled: hasLastLog,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => LogPage()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 0, 10),
          child: SwitchListTile(
            title: Text('Forzar el ocultamiento de Vertices'),
            value: forceHideVertex,
            onChanged: (_) {
              context.read<DebugProvider>().toggleForceHideVertex();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 0, 10),
          child: SwitchListTile(
            title: Text('Forzar la visibilidad de las aristas'),
            value: forceShowEdges,
            onChanged: (_) {
              context.read<DebugProvider>().toggleForceShowEdges();
            },
          ),
        ),
      ],
    );
  }
}
