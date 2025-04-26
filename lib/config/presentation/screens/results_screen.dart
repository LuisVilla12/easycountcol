import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class ResultsScreen extends StatelessWidget {
  static const String name = 'results_screen';
  final int idMuestra;

  const ResultsScreen({Key? key, required this.idMuestra}) : super(key: key);

  // Función para obtener cualquier imagen dado el endpoint
  Future<Uint8List> fetchImage(String tipo) async {
    final url = 'http://10.0.2.2:8000/$tipo/$idMuestra';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Error al cargar imagen: $tipo');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultados')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Imagen Original:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            FutureBuilder<Uint8List>(
              future: fetchImage('imagen-original'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(snapshot.data!),
                  );
                } else {
                  return const Center(child: Text('No se encontró imagen.'));
                }
              },
            ),
            const SizedBox(height: 30),
            const Text('Imagen Procesada (Escala de Grises):', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            FutureBuilder<Uint8List>(
              future: fetchImage('imagen-procesada'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(snapshot.data!),
                  );
                } else {
                  return const Center(child: Text('No se encontró imagen.'));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
