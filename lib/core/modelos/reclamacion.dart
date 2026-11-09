class Reclamacion {
  final String id;
  final String citaId;
  final String facturaId;
  final String seguroId;
  final double montoReclamado;
  final String estado;
  final String fechaEnvio;

  const Reclamacion({
    this.id = '',
    required this.citaId,
    required this.facturaId,
    required this.seguroId,
    required this.montoReclamado,
    required this.estado,
    required this.fechaEnvio,
  });

  factory Reclamacion.fromJson(Map<String, dynamic> json) => Reclamacion(
        id: json['id'].toString(),
        citaId: json['citaId'].toString(),
        facturaId: json['facturaId'].toString(),
        seguroId: json['seguroId'].toString(),
        montoReclamado: (json['montoReclamado'] as num).toDouble(),
        estado: json['estado'] as String,
        fechaEnvio: json['fechaEnvio'] as String,
      );

  Map<String, dynamic> toJson() => {
        if (id.isNotEmpty) 'id': id,
        'citaId': citaId,
        'facturaId': facturaId,
        'seguroId': seguroId,
        'montoReclamado': montoReclamado,
        'estado': estado,
        'fechaEnvio': fechaEnvio,
      };
}
