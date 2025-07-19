import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<bool> sentUserRegister({
  required String name,
  required String lastname,
  required String username,
  required String email,
  required String password,
}) async {
  // Utilizar dotenv para manejar la URL de la API
  final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000';
  final url = Uri.parse('$apiUrl/registro');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "name": name,
      "lastname": lastname,
      "username": username,
      "email": email,
      "password": password
    }),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}
