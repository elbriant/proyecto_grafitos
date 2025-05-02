import 'package:flutter/material.dart';

enum SearchMode { time, length }

class ModeSelection extends StatefulWidget {
  const ModeSelection({super.key});

  @override
  State<ModeSelection> createState() => _ModeSelectionState();
}

class _ModeSelectionState extends State<ModeSelection> {
  @override
  Widget build(BuildContext context) {
    return SegmentedButton(
      segments: <ButtonSegment<SearchMode>>[
        ButtonSegment(value: SearchMode.time, label: Text('Tiempo')),
        ButtonSegment(value: SearchMode.length, label: Text('Distancia')),
      ],
      style: ButtonStyle(
        backgroundColor: WidgetStateColor.fromMap({
          WidgetState.selected: Theme.of(context).colorScheme.primaryContainer,
          WidgetState.any: Theme.of(context).colorScheme.surface,
        }),
      ),
      selected: {SearchMode.time},
      onSelectionChanged: (_) {},
    );
  }
}
