import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/session_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/inicio/inicio_screen.dart';

void main() => runApp(const ProviderScope(child: TelemedicinaApp()));

class TelemedicinaApp extends ConsumerWidget {
  const TelemedicinaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rol = ref.watch(rolActivoProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TeleSalud · Telemedicina',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF077D83),
          surface: const Color(0xFFF7FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F8FB),
        appBarTheme: const AppBarTheme(centerTitle: false),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE3EAEC)),
          ),
        ),
      ),
      home: rol == null ? const LoginScreen() : const InicioScreen(),
    );
  }
}
