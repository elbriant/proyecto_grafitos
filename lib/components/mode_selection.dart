import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_grafitos/provider/settings_provider.dart';

class ModeSelection extends StatelessWidget {
  const ModeSelection({super.key});

  @override
  Widget build(BuildContext context) {
    final searchMode = context.select<SettingsProvider, Set<SearchMode>>((p) => p.searchMode);
    final pathIsShowing = context.select<SettingsProvider, bool>((p) => p.pathMetadata != null);
    final pathTime = context.select<SettingsProvider, Polyline?>((p) => p.pathTime);
    final pathLength = context.select<SettingsProvider, Polyline?>((p) => p.pathLength);
    final pathAll = context.select<SettingsProvider, Polyline?>((p) => p.pathAll);

    if (pathIsShowing) {
      return Container(
        height: 36,
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          border: BoxBorder.all(
            color: Theme.of(context).colorScheme.onSurface,
            width: 1.2,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          boxShadow: kElevationToShadow[4],
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children:
              pathAll != null
                  ? [
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: Colors.redAccent),
                        child: Center(
                          child: Text(
                            'Distancia y Tiempo',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]
                  : [
                    if (pathLength != null)
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: Color.fromARGB(255, 37, 182, 218)),
                          child: Center(
                            child: Text(
                              'Distancia',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (pathLength != null && pathTime != null)
                      SizedBox(
                        width: 2,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                    if (pathTime != null)
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 246, 145),
                          ),
                          child: Center(
                            child: Text(
                              'Tiempo',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
        ),
      );
    }

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
