import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_grafitos/provider/settings_provider.dart';
import 'package:expandable_text/expandable_text.dart';

class LogPage extends StatelessWidget {
  const LogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final log = context.read<SettingsProvider>().lastLog!;

    return Scaffold(
      appBar: AppBar(),
      body: Scrollbar(
        interactive: true,
        thickness: 12.0,
        radius: Radius.circular(12),
        child: ListView.builder(
          itemCount: log.length,
          cacheExtent: 1200,
          itemBuilder: (context, index) {
            return Container(
              color:
                  index % 2 == 0
                      ? Theme.of(context).colorScheme.surfaceContainerHigh
                      : Theme.of(context).colorScheme.surfaceContainerLow,
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ExpandableText(
                log[index],
                expandText: 'Más',
                maxLines: 2,
                animation: true,
                expandOnTextTap: true,
                collapseOnTextTap: true,
              ),
            );
          },
        ),
      ),
    );
  }
}
