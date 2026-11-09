import '../modelos/modelos.dart';
import 'api_client.dart';

class PanelDatos {
  final List<Cita> citas;
  final List<Paciente> pacientes;
  final List<Seguro> seguros;
  final List<Receta> recetas;
  final List<OrdenMedica> ordenes;
  final List<Factura> facturas;
  final List<Reclamacion> reclamaciones;
  final List<Seguimiento> seguimientos;

  const PanelDatos({
    required this.citas,
    required this.pacientes,
    required this.seguros,
    required this.recetas,
    required this.ordenes,
    required this.facturas,
    required this.reclamaciones,
    required this.seguimientos,
  });

  Paciente pacienteDe(Cita cita) =>
      pacientes.firstWhere((p) => p.id == cita.pacienteId);

  Seguro? seguroDe(Paciente paciente) {
    for (final seguro in seguros) {
      if (seguro.id == paciente.seguroId) return seguro;
    }
    return null;
  }

  Factura? facturaDe(Cita cita) {
    for (final factura in facturas) {
      if (factura.citaId == cita.id) return factura;
    }
    return null;
  }

  Reclamacion? reclamacionDe(Cita cita) {
    for (final reclamacion in reclamaciones) {
      if (reclamacion.citaId == cita.id) return reclamacion;
    }
    return null;
  }

  Seguimiento? seguimientoDe(Cita cita) {
    for (final seguimiento in seguimientos) {
      if (seguimiento.citaId == cita.id) return seguimiento;
    }
    return null;
  }
}

/// Repositorio: toda la comunicación HTTP se concentra aquí.
class TelemedicinaRepository {
  final ApiClient api;
  TelemedicinaRepository(this.api);

  Future<List<Map<String, dynamic>>> _lista(String ruta) async {
    final datos = await api.get(ruta) as List<dynamic>;
    return datos.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<List<Paciente>> obtenerPacientes() async =>
      (await _lista('/pacientes')).map(Paciente.fromJson).toList();

  Future<List<Seguro>> obtenerSeguros() async =>
      (await _lista('/seguros')).map(Seguro.fromJson).toList();

  Future<List<Cita>> obtenerCitas() async =>
      (await _lista('/citas')).map(Cita.fromJson).toList();

  Future<List<Receta>> obtenerRecetas() async =>
      (await _lista('/recetas')).map(Receta.fromJson).toList();

  Future<List<OrdenMedica>> obtenerOrdenes() async =>
      (await _lista('/ordenes')).map(OrdenMedica.fromJson).toList();

  Future<List<Factura>> obtenerFacturas() async =>
      (await _lista('/facturas')).map(Factura.fromJson).toList();

  Future<List<Reclamacion>> obtenerReclamaciones() async =>
      (await _lista('/reclamaciones')).map(Reclamacion.fromJson).toList();

  Future<List<Seguimiento>> obtenerSeguimientos() async =>
      (await _lista('/seguimientos')).map(Seguimiento.fromJson).toList();

  Future<PanelDatos> cargarPanel() async {
    // Las ocho peticiones son independientes y se hacen en paralelo.
    final resultados = await Future.wait<dynamic>([
      obtenerCitas(),
      obtenerPacientes(),
      obtenerSeguros(),
      obtenerRecetas(),
      obtenerOrdenes(),
      obtenerFacturas(),
      obtenerReclamaciones(),
      obtenerSeguimientos(),
    ]);
    return PanelDatos(
      citas: resultados[0] as List<Cita>,
      pacientes: resultados[1] as List<Paciente>,
      seguros: resultados[2] as List<Seguro>,
      recetas: resultados[3] as List<Receta>,
      ordenes: resultados[4] as List<OrdenMedica>,
      facturas: resultados[5] as List<Factura>,
      reclamaciones: resultados[6] as List<Reclamacion>,
      seguimientos: resultados[7] as List<Seguimiento>,
    );
  }

  Future<Factura> crearFactura(Factura factura) async => Factura.fromJson(
        await api.post('/facturas', factura.toJson()),
      );

  Future<Factura> registrarPagoSimulado(Factura factura) async =>
      Factura.fromJson(await api.patch('/facturas/${factura.id}', {
        'estado': 'pagada',
        'fechaPago': DateTime.now().toIso8601String().split('T').first,
      }));

  Future<Reclamacion> crearReclamacion(Reclamacion reclamacion) async =>
      Reclamacion.fromJson(
        await api.post('/reclamaciones', reclamacion.toJson()),
      );

  Future<Seguimiento> crearSeguimiento(Seguimiento seguimiento) async =>
      Seguimiento.fromJson(
        await api.post('/seguimientos', seguimiento.toJson()),
      );

  Future<Seguimiento> registrarEncuesta(
    Seguimiento seguimiento, {
    required int puntuacion,
    required String comentario,
  }) async => Seguimiento.fromJson(
        await api.patch('/seguimientos/${seguimiento.id}', {
          'encuestaPuntuacion': puntuacion,
          'encuestaComentario': comentario,
          'estado': 'encuesta_completada',
        }),
      );
}

/// Extensión utilizada por los pasos 1 a 8. Se reutilizan los mismos
/// modelos Cita/Paciente y el mismo cliente HTTP que los pasos 9 y 10.
extension ProcesoRepository on TelemedicinaRepository {
  Future<Paciente> crearPaciente(Paciente paciente) async =>
      Paciente.fromJson(await api.post('/pacientes', paciente.toJson()));

  Future<Cita> crearCita(Cita cita) async =>
      Cita.fromJson(await api.post('/citas', cita.toJson()));

  Future<Paciente> actualizarPaciente(String id, Map<String, dynamic> cambios) async =>
      Paciente.fromJson(await api.patch('/pacientes/$id', cambios));

  Future<Cita> actualizarCita(String id, Map<String, dynamic> cambios) async =>
      Cita.fromJson(await api.patch('/citas/$id', cambios));

  Future<Map<String, dynamic>> crearRegistro(
      String coleccion, Map<String, dynamic> registro) =>
      api.post('/$coleccion', registro);

  Future<List<Map<String, dynamic>>> listarRegistros(String coleccion) async {
    final datos = await api.get('/$coleccion') as List<dynamic>;
    return datos.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
