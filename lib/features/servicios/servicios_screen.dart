import 'package:flutter/material.dart';

class ServiciosScreen extends StatelessWidget {
  const ServiciosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categorias = <(String, IconData, List<String>)>[
      ('Servicios clínicos', Icons.medical_services_outlined, [
        'Consulta general por telemedicina',
        'Evaluación médica de seguimiento',
        'Orientación clínica por especialidad',
      ]),
      ('Servicios asistenciales', Icons.support_agent_outlined, [
        'Agendamiento y confirmación de citas',
        'Admisión virtual y verificación de identidad',
        'Orientación sobre autorizaciones de seguros',
      ]),
      ('Servicios derivados de la consulta', Icons.assignment_outlined, [
        'Receta de demostración',
        'Órdenes de estudios y referimientos',
        'Recordatorios y encuesta de satisfacción',
      ]),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo de servicios')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const Text('Servicios de telemedicina disponibles en la demo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              for (final item in categorias)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(item.$2),
                          const SizedBox(width: 10),
                          Text(item.$1,
                              style: Theme.of(context).textTheme.titleMedium),
                        ]),
                        const SizedBox(height: 7),
                        for (final servicio in item.$3)
                          ListTile(
                            dense: true,
                            leading: const Icon(Icons.check_circle_outline, size: 20),
                            title: Text(servicio),
                          ),
                      ],
                    ),
                  ),
                ),
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Los servicios son ejemplos académicos. '
                    'No se presta atención sanitaria real mediante esta aplicación.'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
