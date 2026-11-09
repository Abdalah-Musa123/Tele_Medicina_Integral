import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Acceso de demostración: roles, NO autenticación de producción.
enum Rol { paciente, admision, medico, apoyoTecnologia, facturacion }

extension RolTexto on Rol {
  String get nombre => switch (this) {
        Rol.paciente => 'Paciente',
        Rol.admision => 'Admisión',
        Rol.medico => 'Médico',
        Rol.apoyoTecnologia => 'Apoyo y tecnología',
        Rol.facturacion => 'Facturación',
      };

  String get descripcion => switch (this) {
        Rol.paciente => 'Solicita citas y consulta el seguimiento',
        Rol.admision => 'Recibe, valida y agenda solicitudes',
        Rol.medico => 'Atiende la consulta y registra resultados',
        Rol.apoyoTecnologia => 'Facilita la videollamada simulada',
        Rol.facturacion => 'Gestiona facturas, pagos y reclamos',
      };
}

final rolActivoProvider = StateProvider<Rol?>((ref) => null);
