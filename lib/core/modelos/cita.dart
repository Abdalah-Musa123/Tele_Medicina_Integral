/// Una cita acompaña el proceso completo. Los campos extra son opcionales
/// para permitir leer citas creadas por la versión anterior (Persona 4).
class Cita {
  final String id;
  final String pacienteId;
  final String fechaHora;
  final String motivo;
  final String estado;
  final String medico;
  final String canal;

  const Cita({
    this.id = '',
    required this.pacienteId,
    required this.fechaHora,
    required this.motivo,
    required this.estado,
    required this.medico,
    this.canal = 'Portal',
  });

  factory Cita.fromJson(Map<String, dynamic> json) => Cita(
        id: (json['id'] ?? '').toString(),
        pacienteId: (json['pacienteId'] ?? '').toString(),
        fechaHora: (json['fechaHora'] ?? '').toString(),
        motivo: (json['motivo'] ?? '').toString(),
        estado: (json['estado'] ?? 'solicitada').toString(),
        medico: (json['medico'] ?? 'Por asignar').toString(),
        canal: (json['canal'] ?? 'Portal').toString(),
      );

  Map<String, dynamic> toJson() => {
        if (id.isNotEmpty) 'id': id,
        'pacienteId': pacienteId,
        'fechaHora': fechaHora,
        'motivo': motivo,
        'estado': estado,
        'medico': medico,
        'canal': canal,
      };
}
