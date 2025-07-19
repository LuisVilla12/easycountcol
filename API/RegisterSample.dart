import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> uploadSampleWithFile({
  required String sample_name,
  required int id_user,
  required String type_sample,
  required String volumen_sample,
  required String factor_sample,
  required String sample_file, 
}) async {
  final uri = Uri.parse('http://13.59.165.189:8000/registrar-muestra-file'); // Asegúrate de que coincida con tu ruta

  // Prepara la solicitud con multipart/form-data.
  final request = http.MultipartRequest('POST', uri)
    ..fields['sample_name'] = sample_name
    ..fields['id_user'] = id_user.toString()
    ..fields['type_sample'] = type_sample
    ..fields['volumen_sample'] = volumen_sample
    ..fields['factor_sample'] = factor_sample
    ..files.add(await http.MultipartFile.fromPath('sample_file', sample_file));
  
  final response = await request.send();

  if (response.statusCode == 200) {
    final respStr = await response.stream.bytesToString();
    final jsonData = jsonDecode(respStr);
    return jsonData; // Regresa  todo el mapa: success, id_sample, message
  } else {
    throw Exception('Error al subir muestra: ${response.statusCode}');
  }
}
