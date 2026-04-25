import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

Future<Map<String, dynamic>> loginUsuario({
  required String email,
  required String password,
}) async {
  final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000';
  final url = Uri.parse('$apiUrl/login');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    debugPrint('STATUS: ${response.statusCode}');
    debugPrint('BODY: ${response.body}');

    // ✅ Intentar decodificar solo si es posible
    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = null;
    }
    if (response.statusCode == 200) {
      return {
        'ok': true,
        'message': data?['message'] ?? 'Login exitoso',
        'idUser': data?['idUser'],
        'name': data?['name'],
        'lastname': data?['lastname'],
        'username': data?['username'],
        'email': data?['email'],
      };
    }

    if (data != null) {
      return {
        'ok': false,
        'message': data['detail'] ?? data['message'] ?? 'Error desconocido',
      };
    }

    // ❌ Error cuando NO viene JSON (tu caso actual)
    return {
      'ok': false,
      'message': 'Error del servidor: ${response.body}',
    };
  } catch (e) {
    debugPrint('Error de conexión: $e');
    return {
      'ok': false,
      'message': 'Error de conexión: $e',
    };
  }
}