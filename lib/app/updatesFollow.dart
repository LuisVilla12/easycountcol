import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> updatesFollow({
  required int followID,
  required String followName,
  required String followDescription,
}) async {
  // Utilizar dotenv para manejar la URL de la API
  final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000';
  final url = Uri.parse('$apiUrl/follows/update/$followID'); // Endpoint para actualizar seguimiento

  // Prepara la solicitud con multipart/form-dat  .
  final request = http.MultipartRequest('PUT', url)
    ..fields['followName'] = followName
    ..fields['description'] = followDescription;

  final response = await request.send();

  if (response.statusCode == 200) {
    final respStr = await response.stream.bytesToString();
    final jsonData = jsonDecode(respStr);
    return jsonData; // Regresa  todo el mapa: success, id_sample, message
  } else {
    throw Exception('Error al actualizar seguimiento: ${response.statusCode}');
  }
}
