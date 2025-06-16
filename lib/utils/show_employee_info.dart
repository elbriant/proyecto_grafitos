import 'package:flutter/material.dart';
import 'package:proyecto_grafitos/models/employee.dart';

void showEmployeeDialog(BuildContext context, Employee employee) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Información del Empleado"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    employee.name[0],
                    style: TextStyle(fontSize: 32, color: Colors.blue[800]),
                  ),
                ),
              ),
              SizedBox(height: 16),
              _InfoRow(label: "Nombre", value: employee.name),
              _InfoRow(label: "Apellido", value: employee.lastName),
              _InfoRow(
                label: "Cedula",
                value: employee.cid.isNotEmpty ? employee.cid : 'No registrado',
              ),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("Cerrar"))],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      );
    },
  );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Divider(height: 16),
        ],
      ),
    );
  }
}
