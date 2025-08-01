import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> updateSample({
  required String sampleName,
  required int idUser,
  required String typeSample,
  required String volumenSample,
  required String factorSample,
  required String medioSample,

}) async {
  // Utilizar dotenv para manejar la URL de la API
  final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000';
  final url = Uri.parse('$apiUrl/update/'); // Asegúrate de que coincida con tu ruta

  // Prepara la solicitud con multipart/form-dat  .
  final request = http.MultipartRequest('POST', url)
    ..fields['sampleName'] = sampleName
    ..fields['idUser'] = idUser.toString()
    ..fields['typeSample'] = typeSample
    ..fields['volumenSample'] = volumenSample
    ..fields['factorSample'] = factorSample
    ..fields['medioSample'] = medioSample;

  final response = await request.send();

  if (response.statusCode == 200) {
    final respStr = await response.stream.bytesToString();
    final jsonData = jsonDecode(respStr);
    return jsonData; // Regresa  todo el mapa: success, id_sample, message
  } else {
    throw Exception('Error al subir muestra: ${response.statusCode}');
  }
}
