import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_grafitos/components/mode_selection.dart' show ModeSelection;
import 'package:proyecto_grafitos/provider/settings_provider.dart';

class BottomTools extends StatelessWidget {
  const BottomTools({super.key});

  void setSelectedButton(SelectButton value, BuildContext context) {
    final p = context.read<SettingsProvider>();
    if (value == p.buttonSelection) {
      p.setButtonSelection(null);
      return;
    }

    p.setButtonSelection(value);
  }

  @override
  Widget build(BuildContext context) {
    final selectedButton = context.select<SettingsProvider, SelectButton?>(
      (p) => p.buttonSelection,
    );

    final fromButtonLabel = context.select<SettingsProvider, String?>((p) => p.buttonFromLabel);

    final toButtonLabel = context.select<SettingsProvider, String?>((p) => p.buttonToLabel);

    return Padding(
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
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setSelectedButton(SelectButton.from, context),
                    style: ButtonStyle(
                      side: WidgetStateBorderSide.resolveWith((_) {
                        if (selectedButton == SelectButton.from) {
                          return BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2.0,
                          );
                        }
                        return null;
                      }),
                    ),
                    child: Text(fromButtonLabel ?? 'Desde'),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setSelectedButton(SelectButton.to, context),
                    style: ButtonStyle(
                      side: WidgetStateBorderSide.resolveWith((_) {
                        if (selectedButton == SelectButton.to) {
                          return BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2.0,
                          );
                        }
                        return null;
                      }),
                    ),
                    child: Text(toButtonLabel ?? 'Hasta'),
                  ),
                ),
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
    );
  }
}
