class Seguimiento {
  final String id;
  final String citaId;
  final String pacienteId;
  final String fechaRecordatorio;
  final String canal;
  final int? encuestaPuntuacion;
  final String? encuestaComentario;
  final String? proximaCita;
  final String estado;

  const Seguimiento({
    this.id = '',
    required this.citaId,
    required this.pacienteId,
    required this.fechaRecordatorio,
    required this.canal,
    this.encuestaPuntuacion,
    this.encuestaComentario,
    this.proximaCita,
    required this.estado,
  });

  factory Seguimiento.fromJson(Map<String, dynamic> json) => Seguimiento(
        id: json['id'].toString(),
        citaId: json['citaId'].toString(),
        pacienteId: json['pacienteId'].toString(),
        fechaRecordatorio: json['fechaRecordatorio'] as String,
        canal: json['canal'] as String,
        encuestaPuntuacion: (json['encuestaPuntuacion'] as num?)?.toInt(),
        encuestaComentario: json['encuestaComentario']?.toString(),
        proximaCita: json['proximaCita']?.toString(),
        estado: json['estado'] as String,
      );

  Map<String, dynamic> toJson() => {
        if (id.isNotEmpty) 'id': id,
        'citaId': citaId,
        'pacienteId': pacienteId,
        'fechaRecordatorio': fechaRecordatorio,
        'canal': canal,
        'encuestaPuntuacion': encuestaPuntuacion,
        'encuestaComentario': encuestaComentario,
        'proximaCita': proximaCita,
        'estado': estado,
      };
}
