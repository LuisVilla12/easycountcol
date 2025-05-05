import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final conexionProvider = FutureProvider<bool>((ref) async {
  try {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:8000/ping'))
        .timeout(const Duration(seconds: 1));
    return response.statusCode == 200;
  } catch (_) {
    return false; // No lanzamos excepción, para poder manejarlo en `data:`
  }
});