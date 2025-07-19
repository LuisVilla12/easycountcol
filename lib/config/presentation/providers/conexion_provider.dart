import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final conexionProvider = FutureProvider<bool>((ref) async {
  try {
    // Utilizar dotenv para manejar la URL de la API
    final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000';
    final response = await http
        .get(Uri.parse('$apiUrl/ping'))
        .timeout(const Duration(seconds: 10));
    return response.statusCode == 200;
  } catch (_) {
    return false; // No lanzamos excepción, para poder manejarlo en `data:`
  }
});
