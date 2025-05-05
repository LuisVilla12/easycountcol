import 'package:easycoutcol/config/api/models/Samples.dart';
import 'package:easycoutcol/config/presentation/providers/login_provider.dart';
import 'package:easycoutcol/config/presentation/screens/results_screen.dart';
import 'package:flutter/material.dart';
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
    // _cargarDatosUsuario(); // Cargar los datos desde el sharedpreferences
  }
  // Saber los datos directamente del shared preferences
  //   Future<void> _cargarDatosUsuario() async {
  //   final sharedDatosUsuario = await SharedPreferences.getInstance();
  //   setState(() {
  //     idUser = sharedDatosUsuario.getInt('id_usuario');
  //     });
  // }

  Future<List<Sample>> fetchSamples() async {
    final response =
        await http.get(Uri.parse('http://13.59.165.189:8000/samples/$idUser'));
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
      appBar: AppBar(title: const Text('Historial')),
      body: FutureBuilder<List<Sample>>(
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
                    final DateTime creationTime = DateTime(now.year,now.month,now.day).add(Duration(seconds: timeSample.toInt()));
                    // Convertir el datatime a time formateado            
                    final String formattedTime = DateFormat('HH:mm:ss').format(creationTime);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: sample.type == 'agua'
                            ? Colors.lightBlue.shade100
                            : colors.primary,
                        child: Icon(
                          sample.type == 'agua' ? Icons.opacity : Icons.science,
                          color: sample.type == 'agua'
                              ? Colors.blue
                              : Colors.white,
                        ),
                      ),
                      title: Text(
                        sample.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 14, color: colors.primary),
                          const SizedBox(width: 4),
                          Text(
                            sample.date,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.access_time,
                              size: 14, color: colors.primary),
                          const SizedBox(width: 4),
                          Text(
                            formattedTime,
                            style: TextStyle(color: colors.primary),
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward_ios,
                          size: 16, color: colors.primary),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ResultsScreen(idMuestra: sample.id),
                          ),
                        );
                      },
                    );
                  },
                );
              }
            },
          )
    );
  }
}
