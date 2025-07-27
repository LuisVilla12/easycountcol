import 'package:easycoutcol/app/resultadoMuestra.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
        automaticallyImplyLeading: true, // Desactiva el botón de retroceso
        foregroundColor: Colors.white,
        title: const Text('Resultados', style: TextStyle(color: Colors.white)),
        backgroundColor: colors.primary,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            // Usamos el modelo para parsear los datos
            final resultado = ResultadoMuestra.fromMap(snapshot.data!);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarjeta de Información
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoItem(Icons.calendar_today_rounded,
                            'Fecha de realización', resultado.dateSample),
                        const SizedBox(height: 12),
                        _infoItem(Icons.timer, 'Hora de realización',
                            resultado.formattedTime),
                        const SizedBox(height: 12),
                        _infoItem(Icons.science, 'Tipo de muestra',
                            resultado.typeSample),
                        const SizedBox(height: 12),
                        _infoItem(Icons.local_drink, 'Factor de dilución',
                            resultado.factorSample),
                        const SizedBox(height: 12),
                        _infoItem(Icons.water, 'Volumen de la muestra',
                            resultado.volumenSample),
                        const SizedBox(height: 12),
                        _infoItem(Icons.trending_up, 'Medio de crecimiento',
                            resultado.medioSample),
                        const SizedBox(height: 12),
                        _infoItem(
                            Icons.zoom_in_sharp,
                            'Unidades formadoras de colonias',
                            resultado.count.toString()),
                        const SizedBox(height: 12),
                        _processingTimeItem(resultado.processingTime),
                        const SizedBox(height: 12),

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
                                  resultado.originalImage,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

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
                                  resultado.processedImage,
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
