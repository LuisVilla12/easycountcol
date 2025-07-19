import 'package:http/http.dart' as http;
import 'dart:convert';

Future<bool> sentUserRegister({
  required String name,
  required String lastname,
  required String username,
  required String email,
  required String password,
}) async {
  final url = Uri.parse('http://13.59.165.189:8000/registro'); // Cambia por IP real si usas emulador

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
    print('Error al registrar: ${response.body}');
    return false;
  }
}
