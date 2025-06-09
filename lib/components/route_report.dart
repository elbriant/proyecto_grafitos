import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_grafitos/models/employee.dart';
import 'package:proyecto_grafitos/models/path_metadata.dart';
import 'package:proyecto_grafitos/provider/settings_provider.dart';
import 'package:proyecto_grafitos/utils/show_employee_info.dart';

class RouteReport extends StatelessWidget {
  const RouteReport({super.key});

  @override
  Widget build(BuildContext context) {
    final pathMetadata = context.select<SettingsProvider, PathMetadata?>((p) => p.pathMetadata);

    if (pathMetadata == null) {
      return SizedBox.shrink();
    }

    final employees = context.select<SettingsProvider, List<Employee>>((p) => p.employees);
    final thisVehicleEmployee = employees.firstWhere(
      (e) => e.id == pathMetadata.vehicle.idEmployee,
    );

    return Dismissible(
      key: Key(pathMetadata.hashCode.toString()),
      child: DecoratedBox(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainer),
        child: ListTile(
          leading: GestureDetector(
            child: CircleAvatar(
              child: Text(thisVehicleEmployee.name[0]), // Primera letra del nombre
            ),
            onTap: () => showEmployeeDialog(context, thisVehicleEmployee),
          ),
          title: Text('Ruta optima(s)'),
          subtitle: Text(
            'Distancia mas corta (en km): ${pathMetadata.totalDistanceInKm.toString()}Km\nMejor tiempo (km/h): ${pathMetadata.estimatedTime}',
          ),
        ),
      ),
      onDismissed: (direction) {
        context.read<SettingsProvider>().resetPath();
      },
    );
  }
}
