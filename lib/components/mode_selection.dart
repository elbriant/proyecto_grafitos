import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_grafitos/provider/settings_provider.dart';

class ModeSelection extends StatelessWidget {
  const ModeSelection({super.key});

  @override
  Widget build(BuildContext context) {
    final searchMode = context.select<SettingsProvider, Set<SearchMode>>((p) => p.searchMode);

    return SegmentedButton(
      segments: <ButtonSegment<SearchMode>>[
        ButtonSegment(value: SearchMode.time, label: Text('Tiempo'), icon: Icon(Icons.more_time)),
        ButtonSegment(
          value: SearchMode.length,
          label: Text('Distancia'),
          icon: Icon(Icons.timeline),
        ),
      ],
      style: ButtonStyle(
        backgroundColor: WidgetStateColor.fromMap({
          WidgetState.selected: Theme.of(context).colorScheme.primaryContainer,
          WidgetState.any: Theme.of(context).colorScheme.surface,
        }),
      ),
      selected: searchMode,
      emptySelectionAllowed: true,
      onSelectionChanged: (setOfSearchMode) {
        context.read<SettingsProvider>().setSearchMode(setOfSearchMode);
      },
    );
  }
}
