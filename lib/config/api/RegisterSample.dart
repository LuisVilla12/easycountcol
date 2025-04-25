import 'package:http/http.dart' as http;
import 'dart:convert';

Future<bool> sentSampleRegister({
  required String sample_name,
  required int id_user,
  required String type_sample,
  required String volumen_sample,
  required String factor_sample,
  required String sample_route,
  
}) async {
  final url = Uri.parse('http://10.0.2.2:8000/registrar-muesta'); // Cambia por IP real si usas emulador

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "sample_name": sample_name,
      "id_user": id_user,
      "type_sample": type_sample,
      "volumen_sample": volumen_sample,
      "factor_sample": factor_sample,
      "sample_route": sample_route,
      "creation_date": DateTime.now().toIso8601String().split('T')[0], // "2025-04-23"
    }),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    print('Error al registrar: ${response.body}');
    return false;
  }
}
