class Factura {
  final String id;
  final String citaId;
  final String pacienteId;
  final double subtotal;
  final double total;
  final String estado;
  final String metodoPago;
  final String fechaEmision;
  final String? fechaPago;

  const Factura({
    this.id = '',
    required this.citaId,
    required this.pacienteId,
    required this.subtotal,
    required this.total,
    required this.estado,
    required this.metodoPago,
    required this.fechaEmision,
    this.fechaPago,
  });

  factory Factura.fromJson(Map<String, dynamic> json) => Factura(
        id: json['id'].toString(),
        citaId: json['citaId'].toString(),
        pacienteId: json['pacienteId'].toString(),
        subtotal: (json['subtotal'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
        estado: json['estado'] as String,
        metodoPago: json['metodoPago'] as String,
        fechaEmision: json['fechaEmision'] as String,
        fechaPago: json['fechaPago']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        if (id.isNotEmpty) 'id': id,
        'citaId': citaId,
        'pacienteId': pacienteId,
        'subtotal': subtotal,
        'total': total,
        'estado': estado,
        'metodoPago': metodoPago,
        'fechaEmision': fechaEmision,
        'fechaPago': fechaPago,
      };
}
