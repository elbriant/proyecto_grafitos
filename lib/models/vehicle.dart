import 'package:proyecto_grafitos/provider/settings_provider.dart';

class Vehicle {
  final int id;
  final int idEmployee;
  final Dimension via;
  final double maxCargoKg;
  final String matricula;

  Vehicle({
    required this.id,
    required this.idEmployee,
    required this.via,
    required this.maxCargoKg,
    required this.matricula,
  });

  factory Vehicle.fromDB(Map<String, Object?> data) {
    return Vehicle(
      id: data['idVehiculo'] as int,
      idEmployee: data['idEmpleados'] as int,
      via: parseVia(data['medio'] as String),
      maxCargoKg: data['cantidadMaxKg'] as double,
      matricula: data['matricula'] as String,
    );
  }

  static Dimension parseVia(String via) => switch (via.toLowerCase()) {
    'tierra' => Dimension.land,
    'agua' => Dimension.maritime,
    'aire' => Dimension.aerial,
    _ => Dimension.land,
  };
}
