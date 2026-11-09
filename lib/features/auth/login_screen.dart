import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/session_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  Rol _seleccionado = Rol.paciente;
  final _usuario = TextEditingController(text: 'demo');
  final _clave = TextEditingController(text: '1234');

  @override
  void dispose() {
    _usuario.dispose();
    _clave.dispose();
    super.dispose();
  }

  void _ingresar() {
    if (_usuario.text.trim() != 'demo' || _clave.text != '1234') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario o clave de demostración incorrectos.')),
      );
      return;
    }
    ref.read(rolActivoProvider.notifier).state = _seleccionado;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 35,
                        child: Icon(Icons.monitor_heart_outlined, size: 38),
                      ),
                      const SizedBox(height: 18),
                      Text('TeleSalud',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 4),
                      const Text('Simulador académico de telemedicina',
                          textAlign: TextAlign.center),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _usuario,
                        decoration: const InputDecoration(
                          labelText: 'Usuario de demostración',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _clave,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña de demostración',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text('Credenciales de prueba: demo / 1234',
                          style: TextStyle(fontSize: 12, color: Colors.black54)),
                      const SizedBox(height: 18),
                      Text('Selecciona un rol para ingresar',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      ...Rol.values.map((rol) => RadioListTile<Rol>(
                            value: rol,
                            groupValue: _seleccionado,
                            title: Text(rol.nombre),
                            subtitle: Text(rol.descripcion),
                            onChanged: (valor) {
                              if (valor != null) setState(() => _seleccionado = valor);
                            },
                          )),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: _ingresar,
                        icon: const Icon(Icons.login),
                        label: const Text('Ingresar al simulador'),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Acceso simulado: las credenciales no protegen datos reales. '
                        'No ingresar información de pacientes verdaderos.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
