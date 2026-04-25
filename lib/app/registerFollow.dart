import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<bool> setFollowRegister({
  required String followName,
  required String followDescription,
  required int idUser,
}) async {

  final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000';
  final url = Uri.parse('$apiUrl/registrar-follow');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "followName": followName,
      "followDescription": followDescription,
      "idUser": idUser
    }),
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception(data['detail'] ?? 'Error desconocido');
  }
}