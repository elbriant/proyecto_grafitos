class Order {
  final int id;
  final int idClient;
  final int idVehicle;
  final int idCargo;
  final String? date;

  Order({
    required this.id,
    required this.idClient,
    required this.idVehicle,
    required this.idCargo,
    this.date,
  });
}
