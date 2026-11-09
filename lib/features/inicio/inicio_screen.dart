import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/persona4_providers.dart';
import '../../core/providers/session_provider.dart';
import '../administracion/ui/administracion_screen.dart';
import '../proceso/ui/proceso_screen.dart';
import '../servicios/servicios_screen.dart';

const etapas = <({String titulo, String descripcion, IconData icono, String actor})>[
  (titulo: 'Solicitud de cita', descripcion: 'Canal, paciente y motivo', icono: Icons.edit_calendar_outlined, actor: 'Paciente'),
  (titulo: 'Recepción hospitalaria', descripcion: 'Registro y motivo de consulta', icono: Icons.assignment_ind_outlined, actor: 'Admisión'),
  (titulo: 'Validación del seguro', descripcion: 'Afiliación, cobertura y autorización', icono: Icons.verified_user_outlined, actor: 'Admisión'),
  (titulo: 'Agendamiento', descripcion: 'Fecha, hora y profesional', icono: Icons.calendar_month_outlined, actor: 'Admisión'),
  (titulo: 'Confirmación', descripcion: 'Comunicación al paciente', icono: Icons.mark_email_read_outlined, actor: 'Admisión'),
  (titulo: 'Consentimiento y admisión', descripcion: 'Identidad y consentimiento virtual', icono: Icons.fact_check_outlined, actor: 'Paciente'),
  (titulo: 'Consulta de telemedicina', descripcion: 'Videollamada académica simulada', icono: Icons.video_call_outlined, actor: 'Médico / Apoyo'),
  (titulo: 'Resultado clínico', descripcion: 'Receta, orden y referimiento', icono: Icons.medical_information_outlined, actor: 'Médico'),
  (titulo: 'Cierre administrativo', descripcion: 'Factura, reclamación y pago', icono: Icons.receipt_long_outlined, actor: 'Facturación'),
  (titulo: 'Seguimiento', descripcion: 'Recordatorio, encuesta y próxima cita', icono: Icons.notifications_active_outlined, actor: 'Paciente / Admisión'),
];

class InicioScreen extends ConsumerWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rol = ref.watch(rolActivoProvider);
    final panel = ref.watch(panelDatosProvider);
    final ancho = MediaQuery.sizeOf(context).width;
    final columnas = ancho >= 1150 ? 3 : (ancho >= 710 ? 2 : 1);

    void navegar(int paso) {
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => paso >= 9
            ? ModuloPersona4Screen(pestanaInicial: paso == 10 ? 1 : 0)
            : ProcesoScreen(pasoInicial: paso),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.monitor_heart_outlined),
            SizedBox(width: 10),
            Text('TeleSalud · Telemedicina'),
          ],
        ),
        actions: [
          if (ancho > 620)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Chip(label: Text(rol?.nombre ?? 'Invitado')),
            ),
          IconButton(
            tooltip: 'Actualizar desde la API',
            onPressed: () => ref.invalidate(panelDatosProvider),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Cerrar sesión de demostración',
            onPressed: () => ref.read(rolActivoProvider.notifier).state = null,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 50),
            children: [
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bienvenido, ${rol?.nombre ?? 'Usuario'}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 7),
                      const Text('Recorre los 10 pasos del proceso de telemedicina. '
                          'Todos los registros son ficticios para la exposición.'),
                      const SizedBox(height: 15),
                      panel.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (e, st) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('API desconectada. Ejecuta npm start en la carpeta api.',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('$e', maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                        data: (p) => Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            Chip(avatar: const Icon(Icons.person_outline, size: 18),
                                label: Text('${p.pacientes.length} pacientes')),
                            Chip(avatar: const Icon(Icons.event_available_outlined, size: 18),
                                label: Text('${p.citas.length} citas')),
                            Chip(avatar: const Icon(Icons.receipt_outlined, size: 18),
                                label: Text('${p.facturas.length} facturas')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 17),
              Text('Proceso de atención · 10 etapas',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              const Text('Selecciona cualquier etapa para probarla. '
                  'Para seguir el recorrido completo, comienza por la solicitud de cita.'),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: etapas.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columnas,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 158,
                ),
                itemBuilder: (context, index) {
                  final etapa = etapas[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      key: Key('abrir_paso_${index + 1}'),
                      onTap: () => navegar(index + 1),
                      child: Padding(
                        padding: const EdgeInsets.all(17),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              CircleAvatar(
                                radius: 19,
                                child: Icon(etapa.icono, size: 21),
                              ),
                              const Spacer(),
                              Text('${index + 1}/10',
                                  style: Theme.of(context).textTheme.labelMedium),
                            ]),
                            const SizedBox(height: 9),
                            Text(etapa.titulo,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            Text(etapa.descripcion,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(etapa.actor, style: TextStyle(
                                fontSize: 11, color: Theme.of(context).colorScheme.primary)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const ServiciosScreen()),
                ),
                icon: const Icon(Icons.medical_services_outlined),
                label: const Text('Ver catálogo de servicios de telemedicina'),
              ),
              const SizedBox(height: 12),
              const Text('Aviso: la autenticación, videollamada, pagos, seguros y '
                  'notificaciones se simulan. No es un sistema médico de producción.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}
