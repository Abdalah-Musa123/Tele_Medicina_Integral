import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telemedicina_integral/main.dart';

void main() {
  testWidgets('Pantalla inicial muestra los cinco roles', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TelemedicinaApp()));
    expect(find.text('TeleSalud'), findsOneWidget);
    expect(find.text('Selecciona un rol para ingresar'), findsOneWidget);
    expect(find.text('Paciente'), findsOneWidget);
    expect(find.text('Admisión'), findsOneWidget);
    expect(find.text('Médico'), findsOneWidget);
    expect(find.text('Facturación'), findsOneWidget);
    expect(find.byIcon(Icons.login), findsOneWidget);
  });
}
