import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> loginUsuario({
  required String email,
  required String password,
}) async {
  final url = Uri.parse('http://13.59.165.189:8000/login'); // o tu IP en red local

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
      'id_user': data['id_user'],
      'name': data['name'],
    };
  } else {
    final data = jsonDecode(response.body);
    return {
      'ok': false,
      'message': data['detail'],
    };
  }
}
