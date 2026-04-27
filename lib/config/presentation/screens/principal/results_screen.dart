import 'package:easycoutcol/app/resultadoMuestra.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResultsScreen extends StatefulWidget {
  static const String name = 'results_screen';

  final int idMuestra;

  const ResultsScreen({super.key, required this.idMuestra});

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

            return Container(
                padding: const EdgeInsets.all(20),
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(resultado.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            )),
                      ),
                      const SizedBox(height: 15),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.5,
                        children: [
                          _infoChip(Icons.calendar_today, 'Fecha:',
                              resultado.dateSample),
                          _infoChip(Icons.access_time, 'Hora:',
                              resultado.formattedTime),
                          _infoChip(Icons.science, 'Conteo de UFC',
                              '${resultado.count} UFC'),
                          _infoChip(Icons.hub, 'Clusters óptimos',
                              '${resultado.optimalClusters} clusters'),
                        ],
                      ),
                      // ⏱️ TIEMPO
                      _processingTimeItem(resultado.processingTime),

                      const SizedBox(height: 20),

                      // 📸 IMAGEN
                      // const Text(
                      //   'Imagen procesada',
                      //   style: TextStyle(
                      //     fontSize: 16,
                      //     fontWeight: FontWeight.bold,
                      //     color: Colors.white,
                      //   ),
                      // ),
                      // const SizedBox(height: 10),

                      // ClipRRect(
                      //   borderRadius: BorderRadius.circular(12),
                      //   child: Image.memory(
                      //     resultado.processedImage,
                      //     fit: BoxFit.cover,
                      //   ),
                      // ),
                      SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [

      _imageCard('Muestra Procesada', resultado.processedImage),

      const SizedBox(width: 12),

      _imageCard('Imagen Original', resultado.originalImage),
    ],
  ),
),
                      const SizedBox(height: 20),

                      // 📊 CLUSTERS
                      const Text(
                        'Distribución de colonias',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 10),

                      _buildClustersPro(resultado.clustersDetail),
                    ],
                  ),
                ));
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


Widget _infoChip(IconData icon, String label, String value) {
  
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildClustersPro(Map<String, dynamic> clusters) {
  final sortedKeys = clusters.keys.toList()
    ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
  final List<dynamic> colors = [
    Colors.red,
    Colors.blue,
    Colors.yellow,
    Colors.green,
  ];

  return Column(
    children: sortedKeys.map((key) {
      final data = clusters[key];
      final percentage = data['percentage'].toDouble();

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏷️ Título
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cluster $key',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(2)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // 📊 Barra visual
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                color: colors[int.parse(key) % colors.length], // Color dinámico por cluster
              ),
            ),

            const SizedBox(height: 6),

            // 🔢 Datos
            Text(
              '${data['count']} colonias',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    }).toList(),
  );
}

///PENDIENTEs

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
Widget _imageCard(String title, image) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          image,
          width: 350, // 🔥 importante para scroll
          height: 300,
          fit: BoxFit.cover,
        ),
      ),
    ],
  );
}