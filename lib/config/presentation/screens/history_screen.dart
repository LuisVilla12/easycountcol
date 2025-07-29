import 'package:easycoutcol/app/Samples.dart';
import 'package:easycoutcol/config/presentation/providers/login_provider.dart';
import 'package:easycoutcol/config/presentation/screens/results_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  static const String name = 'history_screen';
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  int? idUser;
  @override
  void initState() {
    super.initState();
    // Saber el calor actual del id_usuario que inicio sesión directamente desde riverpod
    idUser = ref.read(idUserProvider);
  }
  Future<List<Sample>> fetchSamples() async {
    // Utilizar dotenv para manejar la URL de la API
    final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000';
    // final response = await http.get(Uri.parse('$apiUrl/samples/$idUser'));
    final response = await http.get(Uri.parse('$apiUrl/samples'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      final List<dynamic> samplesList = jsonData['samples'];

      // Mapea cada sublista a un objeto Sample
      return samplesList.map((item) => Sample.fromJsonList(item)).toList();
    } else {
      throw Exception('Error al cargar las muestras');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
        appBar: AppBar(title: const Text('Historial'),
        actions: [
          Row(
            children: [
            IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () {
              setState(() {}); // Refresca la pantalla al presionar el botón
            },
            ),
            IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
            },
            ),
            ],
          )
        ],),
        body:  FutureBuilder<List<Sample>>(
            future: fetchSamples(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No hay muestras disponibles'));
              } else {
                final samples = snapshot.data!;
                return ListView.builder(
                  itemCount: samples.length,
                  itemBuilder: (context, index) {
                    final sample = samples[index];
                    final timeSample = sample.creationTime;
                    // Convertir el dato que viene de la base de datos a datatime
                    final DateTime now = DateTime.now();
                    final DateTime creationTime =
                        DateTime(now.year, now.month, now.day)
                            .add(Duration(seconds: timeSample.toInt()));
                    // Convertir el datatime a time formateado
                    final String formattedTime =
                        DateFormat('HH:mm:ss').format(creationTime);
          
                    return sampleTile(
                      context,
                      sample,
                      sample.typeSample == 'agua'
                          ? colors.primary
                          : Colors.green,
                      DateFormat('dd/MM/yyyy').format(creationTime),
                      formattedTime,
                    );
                  },
                );
              }
            },
          ),
        );
  }
}

Widget sampleTile(BuildContext context, Sample sample, Color tagColor, String formattedDate, String formattedTime) {
  final colors=Theme.of(context).colorScheme;
  return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 0,
      color: colors.primary.withOpacity(0.05),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              backgroundColor: colors.primary,
              radius: 24,
              child: Text(
                sample.sampleName.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                sample.sampleName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: tagColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                sample.typeSample == 'agua' ? 'Muestra' : 'Generación',
                style: TextStyle(
                  color: tagColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(formattedDate, style: const TextStyle(color: Colors.grey)),
              const SizedBox(width: 12),
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(formattedTime, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultsScreen(idMuestra: sample.id),
            ),
          );
        },
      ),
    );
}