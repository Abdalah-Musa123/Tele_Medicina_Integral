class Paciente {
  final String id;
  final String nombre;
  final String correo;
  final String telefono;
  final String? seguroId;

  const Paciente({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.telefono,
    this.seguroId,
  });

  factory Paciente.fromJson(Map<String, dynamic> json) => Paciente(
        id: json['id'].toString(),
        nombre: json['nombre'] as String,
        correo: json['correo'] as String,
        telefono: json['telefono'] as String,
        seguroId: json['seguroId']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        if (id.isNotEmpty) 'id': id,
        'nombre': nombre,
        'correo': correo,
        'telefono': telefono,
        'seguroId': seguroId,
      };
}
