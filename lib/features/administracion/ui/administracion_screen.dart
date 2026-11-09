import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/modelos/modelos.dart';
import '../../../core/providers/persona4_providers.dart';
import '../../../core/repositorio/telemedicina_repository.dart';

String _hoy() => DateTime.now().toIso8601String().split('T').first;
String _fecha(DateTime valor) => valor.toIso8601String().split('T').first;
String _dinero(double monto) => 'RD\$ ${monto.toStringAsFixed(2)}';

class ModuloPersona4Screen extends ConsumerStatefulWidget {
  final int pestanaInicial;
  const ModuloPersona4Screen({super.key, this.pestanaInicial = 0});

  @override
  ConsumerState<ModuloPersona4Screen> createState() =>
      _ModuloPersona4ScreenState();
}

class _ModuloPersona4ScreenState extends ConsumerState<ModuloPersona4Screen> {
  int _pestana = 0;
  String? _citaSeleccionada;

  @override
  void initState() {
    super.initState();
    _pestana = widget.pestanaInicial.clamp(0, 1).toInt();
  }

  @override
  Widget build(BuildContext context) {
    final datos = ref.watch(panelDatosProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Telemedicina · Cierre y seguimiento'),
        actions: [
          IconButton(
            tooltip: 'Actualizar datos de la API',
            onPressed: () => ref.invalidate(panelDatosProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: datos.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'No se pudo conectar con la API simulada.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Inicia json-server en el puerto 3000 y verifica '
                  'API_BASE_URL. No se usan datos clínicos reales.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text('$error', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(panelDatosProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (panel) {
          if (panel.citas.isEmpty) {
            return const Center(child: Text('No hay citas en la API.'));
          }
          final citaId = panel.citas.any((c) => c.id == _citaSeleccionada)
              ? _citaSeleccionada!
              : panel.citas.first.id;
          final cita = panel.citas.firstWhere((c) => c.id == citaId);
          final paciente = panel.pacienteDe(cita);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expediente de demostración',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        const Text('Seleccione una cita para gestionar su cierre y seguimiento.'),
                        Row(
                          children: [
                            const Icon(Icons.event_available, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButton<String>(
                                value: citaId,
                                isExpanded: true,
                                underline: const SizedBox.shrink(),
                                items: panel.citas.map((item) {
                                  final nombre = panel.pacienteDe(item).nombre;
                                  return DropdownMenuItem<String>(
                                    value: item.id,
                                    child: Text('$nombre · ${item.id}'),
                                  );
                                }).toList(),
                                onChanged: (valor) {
                                  setState(() => _citaSeleccionada = valor);
                                },
                              ),
                            ),
                          ],
                        ),
                        Text('Motivo: ${cita.motivo} · Estado: ${cita.estado}'),
                        Text('Médico: ${cita.medico}'),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _pestana == 0
                    ? CierreAdministrativoView(
                        panel: panel,
                        cita: cita,
                        paciente: paciente,
                        alCambiar: () => ref.invalidate(panelDatosProvider),
                      )
                    : SeguimientoView(
                        panel: panel,
                        cita: cita,
                        paciente: paciente,
                        alCambiar: () => ref.invalidate(panelDatosProvider),
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pestana,
        onDestinationSelected: (valor) => setState(() => _pestana = valor),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: '9 · Cierre',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_active_outlined),
            selectedIcon: Icon(Icons.notifications_active),
            label: '10 · Seguimiento',
          ),
        ],
      ),
    );
  }
}

class CierreAdministrativoView extends ConsumerStatefulWidget {
  final PanelDatos panel;
  final Cita cita;
  final Paciente paciente;
  final VoidCallback alCambiar;

  const CierreAdministrativoView({
    super.key,
    required this.panel,
    required this.cita,
    required this.paciente,
    required this.alCambiar,
  });

  @override
  ConsumerState<CierreAdministrativoView> createState() =>
      _CierreAdministrativoViewState();
}

class _CierreAdministrativoViewState
    extends ConsumerState<CierreAdministrativoView> {
  bool _ocupado = false;

  Future<void> _ejecutar(Future<void> Function() operacion) async {
    setState(() => _ocupado = true);
    try {
      await operacion();
      if (!mounted) return;
      widget.alCambiar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos guardados en json-server.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $error')),
      );
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _crearFactura() async {
    final controlador = TextEditingController(text: '1800');
    try {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (contexto) => AlertDialog(
          title: const Text('Emitir factura de demostración'),
          content: TextField(
            controller: controlador,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Monto total (RD\$)',
              helperText: 'Usar datos ficticios',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(contexto, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(contexto, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      );
      if (!mounted || confirmar != true) return;
      final total = double.tryParse(controlador.text.replaceAll(',', '.'));
      if (total == null || total <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Indique un monto válido mayor que cero.')),
        );
        return;
      }
      await _ejecutar(() async {
        await ref.read(telemedicinaRepositoryProvider).crearFactura(Factura(
              citaId: widget.cita.id,
              pacienteId: widget.paciente.id,
              subtotal: total,
              total: total,
              estado: 'pendiente',
              metodoPago: 'simulado',
              fechaEmision: _hoy(),
            ));
      });
    } finally {
      controlador.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cita = widget.cita;
    final factura = widget.panel.facturaDe(cita);
    final reclamacion = widget.panel.reclamacionDe(cita);
    final seguro = widget.panel.seguroDe(widget.paciente);
    final habilitada = cita.estado == 'realizada';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text('Paso 9. Cierre administrativo',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text('Se registran factura, reclamación a la ARS y pago simulado.'),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('1. Facturación',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 8),
                if (factura == null) ...[
                  const Text('Esta cita todavía no tiene factura.'),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: _ocupado || !habilitada ? null : _crearFactura,
                    icon: const Icon(Icons.add),
                    label: const Text('Generar factura'),
                  ),
                ] else ...[
                  Text('Factura: ${factura.id}'),
                  Text('Monto: ${_dinero(factura.total)}'),
                  Text('Estado: ${factura.estado.toUpperCase()}'),
                  Text('Emitida: ${factura.fechaEmision}'),
                  if (factura.fechaPago != null)
                    Text('Fecha de pago: ${factura.fechaPago}'),
                  const SizedBox(height: 10),
                  FilledButton.tonalIcon(
                    onPressed: _ocupado || factura.estado == 'pagada'
                        ? null
                        : () => _ejecutar(() async {
                              await ref
                                  .read(telemedicinaRepositoryProvider)
                                  .registrarPagoSimulado(factura);
                            }),
                    icon: const Icon(Icons.payments_outlined),
                    label: const Text('Simular pago'),
                  ),
                ],
                if (!habilitada)
                  const Text('Solo se factura una cita marcada como realizada.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('2. Reclamación al seguro',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 8),
                Text(seguro == null
                    ? 'Paciente sin seguro asociado.'
                    : '${seguro.aseguradora} · Cobertura ${seguro.coberturaPorcentaje.toStringAsFixed(0)}%'),
                if (reclamacion != null) ...[
                  const SizedBox(height: 6),
                  Text('Reclamación: ${reclamacion.id}'),
                  Text('Monto reclamado: ${_dinero(reclamacion.montoReclamado)}'),
                  Text('Estado: ${reclamacion.estado}'),
                ] else ...[
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: _ocupado || factura == null || seguro == null || !seguro.vigente
                        ? null
                        : () => _ejecutar(() async {
                              final monto = factura.total *
                                  (seguro.coberturaPorcentaje / 100);
                              await ref
                                  .read(telemedicinaRepositoryProvider)
                                  .crearReclamacion(Reclamacion(
                                    citaId: cita.id,
                                    facturaId: factura.id,
                                    seguroId: seguro.id,
                                    montoReclamado: monto,
                                    estado: 'enviada_simulada',
                                    fechaEnvio: _hoy(),
                                  ));
                            }),
                    icon: const Icon(Icons.shield_outlined),
                    label: const Text('Registrar reclamación simulada'),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Nota: esta demostración no cobra dinero real ni envía '
          'reclamaciones a aseguradoras.',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

class _DatosSeguimiento {
  final DateTime fecha;
  final DateTime? proximaCita;
  final String canal;
  const _DatosSeguimiento(this.fecha, this.proximaCita, this.canal);
}

class _DatosEncuesta {
  final int puntuacion;
  final String comentario;
  const _DatosEncuesta(this.puntuacion, this.comentario);
}

class SeguimientoView extends ConsumerStatefulWidget {
  final PanelDatos panel;
  final Cita cita;
  final Paciente paciente;
  final VoidCallback alCambiar;

  const SeguimientoView({
    super.key,
    required this.panel,
    required this.cita,
    required this.paciente,
    required this.alCambiar,
  });

  @override
  ConsumerState<SeguimientoView> createState() => _SeguimientoViewState();
}

class _SeguimientoViewState extends ConsumerState<SeguimientoView> {
  bool _ocupado = false;

  Future<void> _ejecutar(Future<void> Function() operacion) async {
    setState(() => _ocupado = true);
    try {
      await operacion();
      if (!mounted) return;
      widget.alCambiar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seguimiento guardado en json-server.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $error')),
      );
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _programarSeguimiento() async {
    DateTime fecha = DateTime.now().add(const Duration(days: 7));
    DateTime? proxima;
    String canal = 'Correo';

    final datos = await showDialog<_DatosSeguimiento>(
      context: context,
      builder: (contexto) => StatefulBuilder(
        builder: (contexto, actualizarDialogo) => AlertDialog(
          title: const Text('Programar seguimiento'),
          content: SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: canal,
                  decoration: const InputDecoration(labelText: 'Canal del recordatorio'),
                  items: ['Correo', 'WhatsApp', 'Teléfono']
                      .map((valor) => DropdownMenuItem(
                            value: valor,
                            child: Text(valor),
                          ))
                      .toList(),
                  onChanged: (valor) {
                    if (valor != null) actualizarDialogo(() => canal = valor);
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.notifications_outlined),
                  label: Text('Recordatorio: ${_fecha(fecha)}'),
                  onPressed: () async {
                    final elegida = await showDatePicker(
                      context: contexto,
                      initialDate: fecha,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2035),
                    );
                    if (elegida != null) actualizarDialogo(() => fecha = elegida);
                  },
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.event_outlined),
                  label: Text(proxima == null
                      ? 'Próxima cita (opcional)'
                      : 'Próxima cita: ${_fecha(proxima!)}'),
                  onPressed: () async {
                    final elegida = await showDatePicker(
                      context: contexto,
                      initialDate: proxima ?? DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2035),
                    );
                    if (elegida != null) actualizarDialogo(() => proxima = elegida);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(contexto),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                contexto,
                _DatosSeguimiento(fecha, proxima, canal),
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || datos == null) return;
    await _ejecutar(() async {
      await ref.read(telemedicinaRepositoryProvider).crearSeguimiento(
            Seguimiento(
              citaId: widget.cita.id,
              pacienteId: widget.paciente.id,
              fechaRecordatorio: _fecha(datos.fecha),
              canal: datos.canal,
              proximaCita: datos.proximaCita == null
                  ? null
                  : _fecha(datos.proximaCita!),
              estado: 'programado',
            ),
          );
    });
  }

  Future<void> _registrarEncuesta(Seguimiento seguimiento) async {
    int puntuacion = 5;
    final comentario = TextEditingController();
    try {
      final datos = await showDialog<_DatosEncuesta>(
        context: context,
        builder: (contexto) => StatefulBuilder(
          builder: (contexto, actualizarDialogo) => AlertDialog(
            title: const Text('Encuesta de satisfacción'),
            content: SizedBox(
              width: 350,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Valoración: $puntuacion / 5'),
                  Slider(
                    value: puntuacion.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: '$puntuacion',
                    onChanged: (valor) =>
                        actualizarDialogo(() => puntuacion = valor.round()),
                  ),
                  TextField(
                    controller: comentario,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Comentario opcional',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(contexto),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(
                  contexto,
                  _DatosEncuesta(puntuacion, comentario.text.trim()),
                ),
                child: const Text('Guardar encuesta'),
              ),
            ],
          ),
        ),
      );
      if (!mounted || datos == null) return;
      await _ejecutar(() async {
        await ref.read(telemedicinaRepositoryProvider).registrarEncuesta(
              seguimiento,
              puntuacion: datos.puntuacion,
              comentario: datos.comentario,
            );
      });
    } finally {
      comentario.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final seguimiento = widget.panel.seguimientoDe(widget.cita);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text('Paso 10. Seguimiento al paciente',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text('Recordatorios, encuesta de satisfacción y próxima cita.'),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Plan de seguimiento',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 8),
                if (seguimiento == null) ...[
                  const Text('Esta cita no tiene seguimiento programado.'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _ocupado || widget.cita.estado != 'realizada'
                        ? null
                        : _programarSeguimiento,
                    icon: const Icon(Icons.add_alert_outlined),
                    label: const Text('Programar recordatorio'),
                  ),
                ] else ...[
                  Text('ID: ${seguimiento.id}'),
                  Text('Recordatorio: ${seguimiento.fechaRecordatorio}'),
                  Text('Canal: ${seguimiento.canal}'),
                  Text('Estado: ${seguimiento.estado}'),
                  Text('Próxima cita: ${seguimiento.proximaCita ?? 'Sin fecha'}'),
                  const SizedBox(height: 10),
                  const Divider(),
                  const Text('Encuesta de satisfacción',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  if (seguimiento.encuestaPuntuacion != null) ...[
                    Text('Valoración: ${seguimiento.encuestaPuntuacion}/5'),
                    Text('Comentario: ${seguimiento.encuestaComentario ?? '-'}'),
                  ] else ...[
                    const Text('Todavía no se ha registrado una valoración.'),
                    const SizedBox(height: 8),
                    FilledButton.tonalIcon(
                      onPressed: _ocupado
                          ? null
                          : () => _registrarEncuesta(seguimiento),
                      icon: const Icon(Icons.rate_review_outlined),
                      label: const Text('Completar encuesta'),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Nota: los recordatorios y las próximas citas solo se registran '
          'en la API de demostración; no se envían mensajes ni se crea '
          'automáticamente una nueva cita.',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
