import 'package:flutter/material.dart';
/*
void _showNodeCreationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      final TextEditingController nodeNameController = TextEditingController();
      final TextEditingController nodeDescriptionController = TextEditingController();

      return AlertDialog(
        title: Text("Crear nuevo nodo"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nodeNameController,
                decoration: InputDecoration(
                  labelText: "Nombre del nodo*",
                  hintText: "Ej: Parque Central",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: nodeDescriptionController,
                decoration: InputDecoration(
                  labelText: "Descripción",
                  hintText: "Ej: Área verde con juegos infantiles",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("Cancelar")),
          ElevatedButton(onPressed: () => _createNode(context), child: Text("Guardar")),
        ],
      );
    },
  );
}

void _createNode(BuildContext context) {
  final String name = _nodeNameController.text.trim();
  final String description = _nodeDescriptionController.text.trim();

  if (name.isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("El nombre del nodo es obligatorio")));
    return;
  }

  // Aquí iría la lógica para guardar el nodo (API, base de datos, etc.)
  print("Nodo creado: $name - $description");

  Navigator.of(context).pop(); // Cierra el diálogo
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text("Nodo '$name' creado correctamente")));
}

*/