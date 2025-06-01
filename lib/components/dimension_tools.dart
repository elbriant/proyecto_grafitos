import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_grafitos/provider/settings_provider.dart';

class DimensionTools extends StatefulWidget {
  const DimensionTools({super.key});

  @override
  State<DimensionTools> createState() => _DimensionToolsState();
}

class _DimensionToolsState extends State<DimensionTools> {
  bool choosing = false;

  void toggle() {
    setState(() {
      choosing = !choosing;
    });
  }

  void changeDimension(Dimension d, BuildContext context) {
    final currentD = context.read<SettingsProvider>().dimension;
    if (currentD == d) return;

    choosing = false; // not need to do setState as provider will do it anyways
    context.read<SettingsProvider>().setDimension(d);
  }

  @override
  Widget build(BuildContext context) {
    final dim = context.select<SettingsProvider, Dimension>((p) => p.dimension);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 350),
            curve: Curves.fastOutSlowIn,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(99),
                bottomRight: Radius.circular(99),
              ),
            ),
            margin: EdgeInsets.only(top: 18),
            clipBehavior: Clip.hardEdge,
            height: choosing ? (28 + 48 * 3) : 0,
            child: Visibility(
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              visible: choosing,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: const SizedBox(height: 28)),
                  Flexible(
                    child: IconButton(
                      onPressed: () => changeDimension(Dimension.land, context),
                      icon: Icon(
                        Icons.landscape,
                        color: dim == Dimension.land ? Theme.of(context).colorScheme.primary : null,
                      ),
                    ),
                  ),
                  Flexible(
                    child: IconButton(
                      onPressed: () => changeDimension(Dimension.aerial, context),
                      icon: Icon(
                        Icons.air,
                        color:
                            dim == Dimension.aerial ? Theme.of(context).colorScheme.primary : null,
                      ),
                    ),
                  ),
                  Flexible(
                    child: IconButton(
                      onPressed: () => changeDimension(Dimension.maritime, context),
                      icon: Icon(
                        Icons.water,
                        color:
                            dim == Dimension.maritime
                                ? Theme.of(context).colorScheme.primary
                                : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => toggle(),
            style: ButtonStyle(
              side: WidgetStateBorderSide.resolveWith((_) {
                if (choosing) {
                  return BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0);
                }
                return null;
              }),
              padding: WidgetStatePropertyAll(EdgeInsets.all(12.0)),
              shape: WidgetStatePropertyAll(CircleBorder()),
            ),
            child: Icon(switch (dim) {
              Dimension.land => Icons.landscape,
              Dimension.aerial => Icons.air,
              Dimension.maritime => Icons.water,
            }, size: 24),
          ),
        ],
      ),
    );
  }
}
