import 'package:flutter_test/flutter_test.dart';
import 'package:telemedicina_integral/core/modelos/modelos.dart';

void main() {
  test('Cita serializa y deserializa los campos comunes', () {
    const cita = Cita(
      id: 'c1',
      pacienteId: 'p1',
      fechaHora: '2026-11-10T09:00:00',
      motivo: 'Consulta simulada',
      estado: 'solicitada',
      medico: 'Por asignar',
      canal: 'WhatsApp',
    );
    final restaurada = Cita.fromJson(cita.toJson());
    expect(restaurada.id, 'c1');
    expect(restaurada.pacienteId, 'p1');
    expect(restaurada.canal, 'WhatsApp');
    expect(restaurada.estado, 'solicitada');
  });

  test('Nuevo paciente y cita omiten IDs vacíos para json-server', () {
    const paciente = Paciente(id: '', nombre: 'Prueba',
      correo: 'prueba@example.com', telefono: '000');
    const cita = Cita(pacienteId: 'p1', fechaHora: '', motivo: 'demo',
      estado: 'solicitada', medico: 'Por asignar');
    expect(paciente.toJson().containsKey('id'), isFalse);
    expect(cita.toJson().containsKey('id'), isFalse);
  });

  test('Citas viejas sin canal son compatibles', () {
    final c = Cita.fromJson({
      'id':'c9', 'pacienteId':'p3', 'fechaHora':'2026-11-10T10:00:00',
      'motivo':'demo', 'estado':'realizada', 'medico':'Dra. Demo',
    });
    expect(c.canal, 'Portal');
  });

  test('Factura mantiene números decimales y estado de pago', () {
    final factura = Factura.fromJson({
      'id':'f1','citaId':'c1','pacienteId':'p1','subtotal':1800,
      'total':1800,'estado':'pagada','metodoPago':'simulado',
      'fechaEmision':'2026-11-10','fechaPago':'2026-11-10',
    });
    expect(factura.total, 1800.0);
    expect(factura.fechaPago, '2026-11-10');
  });
}
