class OrdenMedica {
  final String id;
  final String citaId;
  final String tipo;
  final String descripcion;
  final String estado;

  const OrdenMedica({
    required this.id,
    required this.citaId,
    required this.tipo,
    required this.descripcion,
    required this.estado,
  });

  factory OrdenMedica.fromJson(Map<String, dynamic> json) => OrdenMedica(
        id: json['id'].toString(),
        citaId: json['citaId'].toString(),
        tipo: json['tipo'] as String,
        descripcion: json['descripcion'] as String,
        estado: json['estado'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'citaId': citaId,
        'tipo': tipo,
        'descripcion': descripcion,
        'estado': estado,
      };
}
