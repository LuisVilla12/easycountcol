import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

import 'package:intl/intl.dart';

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
    final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000';
    final originalUrl = '$apiUrl/imagen-original/${widget.idMuestra}';
    final processedUrl = '$apiUrl/imagen-procesada/${widget.idMuestra}';
    final infoUrl = '$apiUrl/muestra-info/${widget.idMuestra}';

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
    final sample = jsonDecode(responses[2].body);
    return {
      'originalImage': originalImage,
      'processedImage': processedImage,
      'sample': sample['sample'],
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false, // Desactiva el botón de retroceso
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
            final processedImage =
                snapshot.data!['processedImage'] as Uint8List;
            final name = snapshot.data!['sample'][1];
            final typeSample = snapshot.data!['sample'][3];
            final volumenSample = snapshot.data!['sample'][4];
            final factorSample = snapshot.data!['sample'][5];
            final dateSample = snapshot.data!['sample'][7];
            final processingTime = snapshot.data!['sample'][8];
            final count = snapshot.data!['sample'][9];
            final timeSample = snapshot.data!['sample'][10];
            // Convertir el dato que viene de la base de datos a datatime
            final DateTime now = DateTime.now();
            final DateTime creationTime = DateTime(now.year, now.month, now.day)
                .add(Duration(seconds: timeSample.toInt()));
            // Convertir el datatime a time formateado
            final String formattedTime =
                DateFormat('HH:mm:ss').format(creationTime);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarjeta de Información
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título principal
                        Center(
                          child: Text(
                            name,
                            style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Detalles',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        _infoItem(Icons.calendar_today_rounded,
                            'Fecha de realización', dateSample),
                        const SizedBox(height: 12),
                        _infoItem(
                            Icons.timer, 'Hora de realización', formattedTime),
                        const SizedBox(height: 12),
                        _infoItem(Icons.science, 'Tipo de muestra', typeSample),
                        const SizedBox(height: 12),
                        _infoItem(Icons.local_drink, 'Factor de dilución',
                            factorSample),
                        const SizedBox(height: 12),
                        _infoItem(Icons.water, 'Volumen de la muestra',
                            volumenSample),
                        const SizedBox(height: 12),
                        _infoItem(
                            Icons.zoom_in_sharp,
                            'Unidades formadoras de colonias',
                            count.toString()),
                        const SizedBox(height: 12),
                        _processingTimeItem(processingTime),
                        const SizedBox(height: 30),

                        // Imagen Original
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Imagen original:',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  originalImage,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Imagen Original
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Imagen procesada:',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  processedImage,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No se encontraron datos.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: colors.primary,
        ),
      ),
    );
  }
}

Widget _infoItem(IconData icon, String title, String value) {
  return Row(
    children: [
      Icon(icon, color: Colors.white, size: 24),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _processingTimeItem(double time) {
  return Row(
    children: [
      const Icon(Icons.av_timer, color: Colors.white, size: 24),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tiempo de procesamiento',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                Text(
                  '${time.toStringAsFixed(6)} segundos',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Rápido',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}
