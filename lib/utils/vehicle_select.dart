import 'package:flutter/material.dart';
import 'package:proyecto_grafitos/models/employee.dart';
import 'package:proyecto_grafitos/models/vehicle.dart';
import 'package:proyecto_grafitos/provider/settings_provider.dart';
import 'package:proyecto_grafitos/utils/show_employee_info.dart';

Future<Vehicle?> showVehicleModal(
  BuildContext context,
  List<Vehicle> vehicles,
  List<Employee> employees,
) async {
  return await showModalBottomSheet<Vehicle>(
    context: context,
    isScrollControlled: true, // Permite scroll si hay muchos elementos
    useSafeArea: true,
    constraints: BoxConstraints.loose(
      Size(MediaQuery.sizeOf(context).width, MediaQuery.sizeOf(context).height * 0.6),
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (context) {
      // example just in case
      if (vehicles.isEmpty) {
        employees.add(Employee(id: -69, name: 'John', lastName: 'Doe', cid: '69.696.696'));
        vehicles.add(
          Vehicle(
            id: -69,
            idEmployee: -69,
            via: Dimension.land,
            maxCargoKg: 30,
            matricula: 'S3X0ST',
          ),
        );
      }

      return Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Selecciona un vehiculo para la ruta",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  final thisVehicleEmployee = employees.firstWhere(
                    (e) => e.id == vehicle.idEmployee,
                  );
                  return ListTile(
                    leading: GestureDetector(
                      child: CircleAvatar(
                        child: Text(thisVehicleEmployee.name[0]), // Primera letra del nombre
                      ),
                      onTap: () => showEmployeeDialog(context, thisVehicleEmployee),
                    ),
                    title: Text('${thisVehicleEmployee.name} - ${vehicle.matricula}'),
                    subtitle: Text(
                      '#${vehicle.id} | ${_getViaLabel(vehicle.via)} | Max: ${vehicle.maxCargoKg}',
                    ),
                    onTap: () {
                      Navigator.pop(context, vehicle); // Cierra el modal
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

String _getViaLabel(Dimension via) => switch (via) {
  Dimension.land => 'Terrestre',
  Dimension.aerial => 'Aereo',
  Dimension.maritime => 'Maritimo',
};
