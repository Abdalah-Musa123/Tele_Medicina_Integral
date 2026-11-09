import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:telemedicina_integral/core/modelos/modelos.dart';
import 'package:telemedicina_integral/core/repositorio/api_client.dart';
import 'package:telemedicina_integral/core/repositorio/telemedicina_repository.dart';

void main() {
  test('Repositorio crea pacientes/citas y actualiza estado vía REST', () async {
    final llamadas = <String>[];
    final cliente = MockClient((request) async {
      llamadas.add('${request.method} ${request.url.path}');
      final body = request.body.isEmpty
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(jsonDecode(request.body) as Map);
      if (request.method == 'POST' && request.url.path == '/pacientes') {
        return http.Response(jsonEncode({...body, 'id':'pNuevo'}), 201);
      }
      if (request.method == 'POST' && request.url.path == '/citas') {
        return http.Response(jsonEncode({...body, 'id':'cNuevo'}), 201);
      }
      if (request.method == 'PATCH') {
        return http.Response(jsonEncode({
          'id':'cNuevo','pacienteId':'pNuevo','fechaHora':'2026-11-10T10:00:00',
          'motivo':'Control','medico':'Dra. Prueba',...body,
        }), 200);
      }
      return http.Response('No encontrada', 404);
    });
    final repo = TelemedicinaRepository(ApiClient(
      cliente: cliente, baseUrl: 'http://localhost:3000'));
    final paciente = await repo.crearPaciente(const Paciente(
      id:'',nombre:'Prueba',correo:'prueba@example.com',telefono:'000'));
    final cita = await repo.crearCita(Cita(pacienteId: paciente.id,
      fechaHora: '2026-11-10T10:00:00', motivo:'Control',
      estado:'solicitada', medico:'Por asignar'));
    final actualizada = await repo.actualizarCita(cita.id,
      {'estado':'agendada'});
    expect(paciente.id, 'pNuevo');
    expect(cita.id, 'cNuevo');
    expect(actualizada.estado, 'agendada');
    expect(llamadas, ['POST /pacientes', 'POST /citas', 'PATCH /citas/cNuevo']);
    cliente.close();
  });
}
