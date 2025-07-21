import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> loginUsuario({
  required String email,
  required String password,
}) async {
  // Utilizar dotenv para manejar la URL de la API
  final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000';
  final url = Uri.parse('$apiUrl/login');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return {
      'ok': true,
      'message': data['message'],
      'idUser': data['idUser'],
      'name': data['name'],
      'lastname': data['lastname'],
      'username': data['username'],
    };
  } else {
    final data = jsonDecode(response.body);
    return {
      'ok': false,
      'message': data['detail'],
    };
  }
}
