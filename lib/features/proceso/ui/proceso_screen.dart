import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/modelos/modelos.dart';
import '../../../core/providers/persona4_providers.dart';
import '../../../core/repositorio/telemedicina_repository.dart';

/// Pantallas 1 a 8. Todos los cambios se realizan desde Repositorio (HTTP),
/// nunca directamente desde los widgets sobre db.json.
class ProcesoScreen extends ConsumerStatefulWidget {
  final int pasoInicial;
  const ProcesoScreen({super.key, this.pasoInicial = 1});

  @override
  ConsumerState<ProcesoScreen> createState() => _ProcesoScreenState();
}

class _ProcesoScreenState extends ConsumerState<ProcesoScreen> {
  late int _paso;
  String? _citaSeleccionada;
  bool _ocupado = false;
  bool _consentimiento = false;
  bool _llamadaIniciada = false;
  String _canal = 'Portal';
  String _viaConfirmacion = 'WhatsApp';
  String _tipoOrden = 'Laboratorio';
  DateTime _fecha = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _hora = const TimeOfDay(hour: 10, minute: 0);

  final _nombre = TextEditingController(text: 'María Ejemplo (demo)');
  final _correo = TextEditingController(text: 'maria.ejemplo@example.com');
  final _telefono = TextEditingController(text: '809-000-0099');
  final _motivo = TextEditingController(text: 'Consulta general de demostración');
  final _notas = TextEditingController(text: 'Datos recibidos correctamente (demo)');
  final _medico = TextEditingController(text: 'Dra. Rivera (demo)');
  final _identificacion = TextEditingController(text: 'Identidad verificada de forma simulada');
  final _medicamentos = TextEditingController(text: 'Tratamiento ficticio, sin validez clínica');
  final _indicaciones = TextEditingController(text: 'Instrucciones solo para fines académicos');
  final _orden = TextEditingController(text: 'Estudio de laboratorio ficticio');
  final _referimiento = TextEditingController(text: 'No requerido');

  static const _titulos = [
    'Solicitud de cita',
    'Recepción de datos',
    'Validación de seguro',
    'Agendamiento',
    'Confirmación al paciente',
    'Consentimiento y admisión',
    'Consulta de telemedicina',
    'Resultado de la consulta',
  ];

  @override
  void initState() {
    super.initState();
    _paso = widget.pasoInicial.clamp(1, 8).toInt();
  }

  @override
  void dispose() {
    for (final ctrl in [
      _nombre, _correo, _telefono, _motivo, _notas, _medico,
      _identificacion, _medicamentos, _indicaciones, _orden, _referimiento,
    ]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  String _soloFecha(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _fechaHora() =>
      '${_soloFecha(_fecha)}T${_hora.hour.toString().padLeft(2, '0')}:${_hora.minute.toString().padLeft(2, '0')}:00';

  Widget _campo(TextEditingController ctrl, String etiqueta,
      {int lineas = 1, TextInputType? tipo}) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextField(
      controller: ctrl,
      maxLines: lineas,
      keyboardType: tipo,
      decoration: InputDecoration(labelText: etiqueta),
    ),
  );

  Widget _selector(String etiqueta, String valor, List<String> opciones,
      ValueChanged<String?> cambiar) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: DropdownButtonFormField<String>(
      value: valor,
      isExpanded: true,
      decoration: InputDecoration(labelText: etiqueta),
      items: opciones.map((texto) => DropdownMenuItem(
        value: texto, child: Text(texto),
      )).toList(),
      onChanged: cambiar,
    ),
  );

  void _mensaje(String texto, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: error ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  Future<void> _elegirFecha() async {
    final nueva = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (nueva != null && mounted) setState(() => _fecha = nueva);
  }

  Future<void> _elegirHora() async {
    final nueva = await showTimePicker(context: context, initialTime: _hora);
    if (nueva != null && mounted) setState(() => _hora = nueva);
  }

  /// Permite terminar el circuito desde una nueva cita sin depender de p1/p2.
  Future<void> _crearSeguroDemo(Paciente paciente) async {
    setState(() => _ocupado = true);
    try {
      final repo = ref.read(telemedicinaRepositoryProvider);
      final idAfiliacion = DateTime.now().millisecondsSinceEpoch.toString();
      final registrado = await repo.crearRegistro('seguros', {
        'pacienteId': paciente.id,
        'aseguradora': 'ARS TeleSalud (demo)',
        'numeroAfiliacion': 'AF-$idAfiliacion',
        'coberturaPorcentaje': 80,
        'autorizacion': 'AUT-DEMO-$idAfiliacion',
        'vigente': true,
      });
      await repo.actualizarPaciente(paciente.id, {
        'seguroId': registrado['id'].toString(),
      });
      if (!mounted) return;
      ref.invalidate(panelDatosProvider);
      _mensaje('Seguro ficticio asociado. Pulsa Guardar y continuar para validarlo.');
    } catch (e) {
      _mensaje('No se pudo crear el seguro de demostración: $e', error: true);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _guardar(PanelDatos panel, Cita? cita, Paciente? paciente) async {
    // Validación simple y visible. Los datos no se usan con pacientes reales.
    if (_paso == 1 && (_nombre.text.trim().isEmpty ||
        !_correo.text.contains('@') || _motivo.text.trim().isEmpty)) {
      _mensaje('Completa nombre, correo válido y motivo.', error: true);
      return;
    }
    if (_paso > 1 && (cita == null || paciente == null)) {
      _mensaje('Selecciona una cita antes de continuar.', error: true);
      return;
    }
    if (_paso == 6 && !_consentimiento) {
      _mensaje('Debes marcar el consentimiento simulado.', error: true);
      return;
    }
    if (_paso == 7 && !_llamadaIniciada) {
      _mensaje('Primero inicia la simulación de videollamada.', error: true);
      return;
    }
    if (_paso == 8 && (_medicamentos.text.trim().isEmpty || _orden.text.trim().isEmpty)) {
      _mensaje('Completa los campos de receta y orden.', error: true);
      return;
    }

    setState(() => _ocupado = true);
    try {
      final repo = ref.read(telemedicinaRepositoryProvider);
      final ahora = DateTime.now().toIso8601String();
      String? nuevoId;
      switch (_paso) {
        case 1:
          final nuevoPaciente = await repo.crearPaciente(Paciente(
            id: '',
            nombre: _nombre.text.trim(),
            correo: _correo.text.trim(),
            telefono: _telefono.text.trim(),
          ));
          final nuevaCita = await repo.crearCita(Cita(
            pacienteId: nuevoPaciente.id,
            fechaHora: _fechaHora(),
            motivo: _motivo.text.trim(),
            estado: 'solicitada',
            medico: 'Por asignar',
            canal: _canal,
          ));
          nuevoId = nuevaCita.id;
          break;
        case 2:
          await repo.crearRegistro('recepciones', {
            'citaId': cita!.id,
            'pacienteId': paciente!.id,
            'motivoConfirmado': cita.motivo,
            'observaciones': _notas.text.trim(),
            'fechaRecepcion': ahora,
          });
          await repo.actualizarCita(cita.id, {'estado': 'recibida'});
          break;
        case 3:
          final seguro = panel.seguroDe(paciente!);
          final aprobada = seguro != null && seguro.vigente &&
              seguro.coberturaPorcentaje > 0;
          await repo.crearRegistro('validaciones', {
            'citaId': cita!.id,
            'pacienteId': paciente.id,
            'seguroId': seguro?.id,
            'afiliacion': seguro?.numeroAfiliacion ?? 'Sin afiliación',
            'coberturaPorcentaje': seguro?.coberturaPorcentaje ?? 0,
            'autorizacion': aprobada ? seguro.autorizacion : 'Pendiente',
            'resultado': aprobada ? 'aprobada' : 'pendiente',
            'fechaValidacion': ahora,
          });
          await repo.actualizarCita(cita.id, {
            'estado': aprobada ? 'seguro_validado' : 'pendiente_seguro',
          });
          break;
        case 4:
          await repo.actualizarCita(cita!.id, {
            'fechaHora': _fechaHora(),
            'medico': _medico.text.trim().isEmpty
                ? 'Médico por confirmar' : _medico.text.trim(),
            'estado': 'agendada',
          });
          break;
        case 5:
          await repo.crearRegistro('confirmaciones', {
            'citaId': cita!.id,
            'pacienteId': paciente!.id,
            'canal': _viaConfirmacion,
            'mensaje': 'Cita confirmada (envío simulado)',
            'fechaConfirmacion': ahora,
          });
          await repo.actualizarCita(cita.id, {'estado': 'confirmada'});
          break;
        case 6:
          await repo.crearRegistro('admisiones', {
            'citaId': cita!.id,
            'pacienteId': paciente!.id,
            'identificacion': _identificacion.text.trim(),
            'consentimiento': true,
            'fechaAdmision': ahora,
          });
          await repo.actualizarCita(cita.id, {'estado': 'admitida'});
          break;
        case 7:
          await repo.crearRegistro('consultas', {
            'citaId': cita!.id,
            'pacienteId': paciente!.id,
            'medio': 'Videollamada simulada',
            'fechaFinalizacion': ahora,
            'estado': 'finalizada',
          });
          await repo.actualizarCita(cita.id, {'estado': 'consulta_realizada'});
          break;
        case 8:
          await repo.crearRegistro('recetas', {
            'citaId': cita!.id,
            'medicamentos': [_medicamentos.text.trim()],
            'instrucciones': _indicaciones.text.trim(),
            'fecha': _soloFecha(DateTime.now()),
          });
          await repo.crearRegistro('ordenes', {
            'citaId': cita.id,
            'tipo': _tipoOrden,
            'descripcion': _orden.text.trim(),
            'estado': 'emitida',
          });
          await repo.crearRegistro('resultados', {
            'citaId': cita.id,
            'referimiento': _referimiento.text.trim(),
            'fecha': ahora,
          });
          await repo.actualizarCita(cita.id, {'estado': 'realizada'});
          break;
      }

      if (!mounted) return;
      ref.invalidate(panelDatosProvider);
      setState(() {
        if (nuevoId != null) _citaSeleccionada = nuevoId;
        if (_paso < 8) _paso++;
        _llamadaIniciada = false;
      });
      _mensaje('Registro guardado en json-server correctamente.');
    } catch (e) {
      _mensaje('No se pudo completar la operación: $e', error: true);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Widget _contenidoPaso(PanelDatos panel, Cita? cita, Paciente? paciente) {
    switch (_paso) {
      case 1:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Crea una solicitud y un paciente ficticio. '
              'Puedes elegir un canal de contacto.'),
          const SizedBox(height: 16),
          _campo(_nombre, 'Nombre del paciente (demo)'),
          _campo(_correo, 'Correo ficticio', tipo: TextInputType.emailAddress),
          _campo(_telefono, 'Teléfono ficticio', tipo: TextInputType.phone),
          _campo(_motivo, 'Motivo de consulta'),
          _selector('Canal de solicitud', _canal,
            ['Celular', 'Correo', 'WhatsApp', 'Portal', 'Teléfono'],
            (v) { if (v != null) setState(() => _canal = v); }),
          const Text('El agendamiento definitivo se realiza en el paso 4.'),
        ]);
      case 2:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('El área de admisión recibe los datos y verifica el motivo de consulta.'),
          const SizedBox(height: 14),
          Text('Paciente: ${paciente?.nombre ?? '-'}'),
          Text('Motivo registrado: ${cita?.motivo ?? '-'}'),
          const SizedBox(height: 14),
          _campo(_notas, 'Observaciones de recepción', lineas: 2),
        ]);
      case 3:
        final seguro = paciente == null ? null : panel.seguroDe(paciente);
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Se comprueban afiliación, cobertura y autorización usando '
              'datos de la aseguradora ficticia.'),
          const SizedBox(height: 14),
          _dato('Aseguradora', seguro?.aseguradora ?? 'Sin seguro registrado'),
          _dato('Afiliación', seguro?.numeroAfiliacion ?? 'No disponible'),
          _dato('Cobertura', '${seguro?.coberturaPorcentaje ?? 0}%'),
          _dato('Autorización', seguro?.autorizacion ?? 'Pendiente'),
          _dato('Vigencia', seguro?.vigente == true ? 'Vigente' : 'No disponible'),
          const SizedBox(height: 10),
          if (seguro == null && paciente != null) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _ocupado ? null : () => _crearSeguroDemo(paciente),
              icon: const Icon(Icons.add_card_outlined),
              label: const Text('Asociar seguro ficticio (80% de cobertura)'),
            ),
          ],
          const Text('Un paciente sin seguro se registra como pendiente. '
              'Este proceso no consulta aseguradoras verdaderas.'),
        ]);
      case 4:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Selecciona una fecha, hora y profesional para la cita.'),
          const SizedBox(height: 14),
          _campo(_medico, 'Médico asignado'),
          Wrap(spacing: 12, children: [
            OutlinedButton.icon(
              onPressed: _elegirFecha,
              icon: const Icon(Icons.calendar_month),
              label: Text('Fecha: ${_soloFecha(_fecha)}'),
            ),
            OutlinedButton.icon(
              onPressed: _elegirHora,
              icon: const Icon(Icons.schedule),
              label: Text('Hora: ${_hora.format(context)}'),
            ),
          ]),
        ]);
      case 5:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('La confirmación se registra en la API. No se envía '
              'ningún WhatsApp, correo ni SMS real.'),
          const SizedBox(height: 14),
          _dato('Paciente', paciente?.nombre ?? '-'),
          _dato('Correo', paciente?.correo ?? '-'),
          _dato('Fecha de la cita', cita?.fechaHora ?? '-'),
          _selector('Canal de confirmación', _viaConfirmacion,
            ['WhatsApp', 'Correo', 'SMS', 'Llamada'],
            (v) { if (v != null) setState(() => _viaConfirmacion = v); }),
        ]);
      case 6:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Admisión virtual: se revisa la identidad y se simula '
              'la aceptación del consentimiento.'),
          const SizedBox(height: 14),
          _campo(_identificacion, 'Verificación de identidad (simulada)'),
          CheckboxListTile(
            value: _consentimiento,
            onChanged: (v) => setState(() => _consentimiento = v ?? false),
            title: const Text('Acepto el consentimiento informado de demostración'),
            subtitle: const Text('No constituye un consentimiento médico real.'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ]);
      case 7:
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            height: 230,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF163642),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_llamadaIniciada ? Icons.video_camera_front : Icons.videocam_off,
                    size: 72, color: Colors.white),
                const SizedBox(height: 14),
                Text(_llamadaIniciada ? 'Videollamada de prueba en curso'
                        : 'Sala de telemedicina (simulación)',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 17)),
                const Text('Sin transmisión de video o audio',
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => setState(() => _llamadaIniciada = !_llamadaIniciada),
            icon: Icon(_llamadaIniciada ? Icons.pause_circle_outline : Icons.play_circle_outline),
            label: Text(_llamadaIniciada ? 'Detener simulación' : 'Iniciar simulación'),
          ),
          const SizedBox(height: 8),
          const Text('Al finalizar la simulación se registra la consulta '
              'en la API y se actualiza el estado de la cita.'),
        ]);
      case 8:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Registra un resultado ficticio: receta, orden y referimiento. '
              'No escribir tratamientos o datos clínicos reales.'),
          const SizedBox(height: 14),
          _campo(_medicamentos, 'Receta simulada'),
          _campo(_indicaciones, 'Indicaciones (ficticias)', lineas: 2),
          _selector('Tipo de orden', _tipoOrden,
              ['Laboratorio', 'Imagen', 'Interconsulta', 'Otro'],
              (v) { if (v != null) setState(() => _tipoOrden = v); }),
          _campo(_orden, 'Orden o estudio simulado'),
          _campo(_referimiento, 'Referimiento (opcional)'),
        ]);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _dato(String nombre, String valor) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      SizedBox(width: 125, child: Text('$nombre:',
          style: const TextStyle(fontWeight: FontWeight.w600))),
      Expanded(child: Text(valor)),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(panelDatosProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Paso $_paso · ${_titulos[_paso - 1]}'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(panelDatosProvider),
            tooltip: 'Actualizar datos',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: estado.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off, size: 54),
                const SizedBox(height: 12),
                const Text('No se pudo conectar con json-server.'),
                const Text('Inicia la API con npm start en la carpeta api.'),
                const SizedBox(height: 8),
                Text('$e', textAlign: TextAlign.center),
                const SizedBox(height: 15),
                FilledButton(
                  onPressed: () => ref.invalidate(panelDatosProvider),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (panel) {
          final id = panel.citas.any((c) => c.id == _citaSeleccionada)
              ? _citaSeleccionada
              : (panel.citas.isNotEmpty ? panel.citas.last.id : null);
          Cita? cita;
          Paciente? paciente;
          for (final c in panel.citas) {
            if (c.id == id) {
              cita = c;
              for (final p in panel.pacientes) {
                if (p.id == c.pacienteId) paciente = p;
              }
              break;
            }
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  SizedBox(
                    height: 52,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 8,
                      separatorBuilder: (_, __) => const SizedBox(width: 7),
                      itemBuilder: (context, i) => ChoiceChip(
                        label: Text('Paso ${i + 1}'),
                        selected: _paso == i + 1,
                        onSelected: (_) => setState(() => _paso = i + 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(children: [
                            CircleAvatar(child: Text('$_paso')),
                            const SizedBox(width: 12),
                            Expanded(child: Text(_titulos[_paso - 1],
                              style: Theme.of(context).textTheme.titleLarge)),
                          ]),
                          const SizedBox(height: 17),
                          if (_paso > 1) ...[
                            if (panel.citas.isEmpty)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 14),
                                child: Text('Primero crea una cita en el paso 1.'),
                              )
                            else
                              DropdownButtonFormField<String>(
                                value: id,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'Cita de trabajo',
                                ),
                                items: panel.citas.map((c) {
                                  final p = panel.pacientes.where(
                                    (p) => p.id == c.pacienteId,
                                  );
                                  final nombre = p.isEmpty ? c.pacienteId : p.first.nombre;
                                  return DropdownMenuItem(
                                    value: c.id,
                                    child: Text('$nombre · ${c.id}',
                                        overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                onChanged: (v) => setState(() => _citaSeleccionada = v),
                              ),
                            const SizedBox(height: 12),
                            if (cita != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Text('Estado actual: ${cita.estado}   ·   '
                                    'Médico: ${cita.medico}',
                                    style: const TextStyle(fontWeight: FontWeight.w500)),
                              ),
                          ],
                          _contenidoPaso(panel, cita, paciente),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            key: Key('guardar_paso_$_paso'),
                            onPressed: _ocupado ? null : () => _guardar(panel, cita, paciente),
                            icon: _ocupado
                                ? const SizedBox(width: 16, height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.save_outlined),
                            label: Text(_paso == 7
                                ? 'Finalizar consulta de prueba'
                                : (_paso == 8 ? 'Guardar resultados' : 'Guardar y continuar')),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Todos los pasos usan registros simulados. '
                      'Los cambios se almacenan en la API JSON local.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
