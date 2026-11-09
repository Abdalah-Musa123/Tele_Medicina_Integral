class Seguro {
  final String id;
  final String pacienteId;
  final String aseguradora;
  final String numeroAfiliacion;
  final double coberturaPorcentaje;
  final String autorizacion;
  final bool vigente;

  const Seguro({
    required this.id,
    required this.pacienteId,
    required this.aseguradora,
    required this.numeroAfiliacion,
    required this.coberturaPorcentaje,
    required this.autorizacion,
    required this.vigente,
  });

  factory Seguro.fromJson(Map<String, dynamic> json) => Seguro(
        id: json['id'].toString(),
        pacienteId: json['pacienteId'].toString(),
        aseguradora: json['aseguradora'] as String,
        numeroAfiliacion: json['numeroAfiliacion'] as String,
        coberturaPorcentaje: (json['coberturaPorcentaje'] as num).toDouble(),
        autorizacion: json['autorizacion'] as String,
        vigente: json['vigente'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'pacienteId': pacienteId,
        'aseguradora': aseguradora,
        'numeroAfiliacion': numeroAfiliacion,
        'coberturaPorcentaje': coberturaPorcentaje,
        'autorizacion': autorizacion,
        'vigente': vigente,
      };
}
