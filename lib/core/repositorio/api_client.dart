import 'dart:convert';
import 'package:http/http.dart' as http;

/// En Chrome/Windows, localhost apunta a la PC que ejecuta json-server.
/// Android Emulator: usa --dart-define=API_BASE_URL=http://10.0.2.2:3000
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);

class ApiClient {
  final http.Client _http;
  final String baseUrl;

  ApiClient({http.Client? cliente, this.baseUrl = apiBaseUrl})
      : _http = cliente ?? http.Client();

  Future<dynamic> get(String ruta) async {
    final respuesta = await _http
        .get(Uri.parse('$baseUrl$ruta'))
        .timeout(const Duration(seconds: 8));
    return _procesar(respuesta);
  }

  Future<Map<String, dynamic>> post(
    String ruta,
    Map<String, dynamic> contenido,
  ) async {
    final respuesta = await _http
        .post(
          Uri.parse('$baseUrl$ruta'),
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode(contenido),
        )
        .timeout(const Duration(seconds: 8));
    return _procesar(respuesta) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> patch(
    String ruta,
    Map<String, dynamic> cambios,
  ) async {
    final respuesta = await _http
        .patch(
          Uri.parse('$baseUrl$ruta'),
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode(cambios),
        )
        .timeout(const Duration(seconds: 8));
    return _procesar(respuesta) as Map<String, dynamic>;
  }

  dynamic _procesar(http.Response respuesta) {
    if (respuesta.statusCode < 200 || respuesta.statusCode >= 300) {
      throw Exception(
        'La API devolvió HTTP ${respuesta.statusCode}. '
        'Comprueba json-server y la ruta solicitada.',
      );
    }
    if (respuesta.bodyBytes.isEmpty) return null;
    return jsonDecode(utf8.decode(respuesta.bodyBytes));
  }

  void cerrar() => _http.close();
}
