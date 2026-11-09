class Receta {
  final String id;
  final String citaId;
  final List<String> medicamentos;
  final String instrucciones;
  final String fecha;

  const Receta({
    required this.id,
    required this.citaId,
    required this.medicamentos,
    required this.instrucciones,
    required this.fecha,
  });

  factory Receta.fromJson(Map<String, dynamic> json) => Receta(
        id: json['id'].toString(),
        citaId: json['citaId'].toString(),
        medicamentos: (json['medicamentos'] as List<dynamic>)
            .map((item) => item.toString())
            .toList(),
        instrucciones: json['instrucciones'] as String,
        fecha: json['fecha'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'citaId': citaId,
        'medicamentos': medicamentos,
        'instrucciones': instrucciones,
        'fecha': fecha,
      };
}
