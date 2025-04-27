import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class ResultsScreen extends StatefulWidget {
  static const String name = 'results_screen';
  
  final int idMuestra;

  const ResultsScreen({Key? key, required this.idMuestra}) : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late Future<Map<String, dynamic>> data;
   @override
  void initState() {
    super.initState();
    data = fetchData();
  }

  Future<Map<String, dynamic>> fetchData() async {
    final originalUrl = 'http://10.0.2.2:8000/imagen-original/${widget.idMuestra}';
    final processedUrl = 'http://10.0.2.2:8000/imagen-procesada/${widget.idMuestra}';
    final infoUrl = 'http://10.0.2.2:8000/muestra-info/${widget.idMuestra}'; 

    final responses = await Future.wait([
      http.get(Uri.parse(originalUrl)),
      http.get(Uri.parse(processedUrl)),
      http.get(Uri.parse(infoUrl)),
    ]);

    if (responses.any((res) => res.statusCode != 200)) {
      throw Exception('Error al cargar datos');
    }

    final originalImage = responses[0].bodyBytes;
    final processedImage = responses[1].bodyBytes;
    final infoData = jsonDecode(responses[2].body);

    return {
      'originalImage': originalImage,
      'processedImage': processedImage,
      'processingTime': infoData['processing_time'], // segundos
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
            automaticallyImplyLeading: false,// Desactiva el botón de retroceso
            title: const Text('Resultados')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final originalImage = snapshot.data!['originalImage'] as Uint8List;
            final processedImage = snapshot.data!['processedImage'] as Uint8List;
            final processingTime = snapshot.data!['processingTime'];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Imagen Original:', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(originalImage),
                  ),
                  const SizedBox(height: 30),
                  const Text('Imagen Procesada (Escala de Grises):', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(processedImage),
                  ),
                  const SizedBox(height: 30),
                  Text('⏱ Tiempo de procesamiento: ${processingTime.toString()} segundos', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 20,)
                ],
              ),
            );
          } else {
            return const Center(child: Text('No se encontraron datos.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        Navigator.pop(context);
      }, child: const Icon(Icons.arrow_back_ios_new_rounded),),
    );
  }
}
