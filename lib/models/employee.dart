class Employee {
  final int id;
  final String name;
  final String lastName;
  final String cid;

  Employee({required this.id, required this.name, required this.lastName, required this.cid});

  factory Employee.fromDB(Map<String, Object?> data) {
    return Employee(
      id: data['idEmpleados'] as int,
      name: data['nombre'] as String,
      lastName: data['apellido'] as String,
      cid: data['cedula'] as String,
    );
  }
}
