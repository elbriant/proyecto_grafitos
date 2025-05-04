import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_grafitos/provider/debug_provider.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final debugToggle = context.select<DebugProvider, bool>((p) => p.showDebug);

    return NavigationDrawer(
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
        NavigationDrawerDestination(label: Text('placeholder'), icon: Icon(Icons.abc)),
      ],
    );
  }
}
