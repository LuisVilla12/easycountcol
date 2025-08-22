import 'package:easycoutcol/app/Samples.dart';
import 'package:easycoutcol/config/presentation/providers/login_provider.dart';
import 'package:easycoutcol/config/presentation/providers/theme_provider.dart';
import 'package:easycoutcol/config/presentation/screens/edit.screen.dart';
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

  // Obtener las muestras de la API
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

  //Actualizar el estado de la muestra
  Future<void> updateStateSample(Sample sample) async {
    final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000';
    final response = await http.put(
      Uri.parse('$apiUrl/sample/state/${sample.id}'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar la muestra');
    }
  }

  // Colores de la clasificacion
  final Map<String, Map<String, dynamic>> classification = {
    'Clinica - Biológica': {
      'color': Colors.red.shade700,
      'icon': Icons.medical_services_outlined,
    },
    'Ambiental': {
      'color': Colors.green.shade700,
      'icon': Icons.public_outlined,
    },
    'Alimentos': {
      'color': Colors.purple.shade700,
      'icon': Icons.restaurant_outlined,
    },
    'Material': {
      'color': Colors.blue.shade700,
      'icon': Icons.build_outlined,
    },
    'Otras muestras': {
      'color': Colors.grey.shade700,
      'icon': Icons.category_outlined,
    },
  };
  String? _selectedFilter; // null significa "sin filtro"

  // Construir listado de muestras
  Widget buildSampleList() {
    final colors = Theme.of(context).colorScheme;
    return FutureBuilder<List<Sample>>(
      future: fetchSamples(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay muestras disponibles'));
        } else {
          // Obtener todas las muestras
          final allSamples = snapshot.data!;
          // Filtra las muestras según el fPiltro seleccionado
          final samplesFilter = (_selectedFilter == null)
              ? allSamples
              : allSamples
                  .where((s) => s.typeSample == _selectedFilter)
                  .toList();
          if (samplesFilter.isEmpty) {
            return const Center(
                child: Text('No hay muestras para esta categoría'));
          }
          return ListView.builder(
            itemCount: samplesFilter.length,
            itemBuilder: (context, index) {
              final sample = samplesFilter[index];
              // print(sample.creationDate);
              final timeSample = sample.creationTime;

              // Convertir el dato que viene de la base de datos a datatime
              final DateTime now = DateTime.now();
              final DateTime creationTime = DateTime(now.year, now.month, now.day).add(Duration(seconds: timeSample.toInt()));
              // Convertir de string a DateTime
              final DateTime creationDate = DateTime.parse(sample.creationDate);
              // Dar formato a la fecha de creación
              String creacionDateFormat = DateFormat('dd-MM-yyyy').format(creationDate);

              // Convertir el datatime a time formateado
              final String formattedTime =
                  DateFormat('HH:mm:ss').format(creationTime);
              return Dismissible(
                key: Key(
                    sample.id.toString()), // Asegúrate que sample.id sea único

                // Permitir swipe en ambos lados:
                direction: DismissDirection.horizontal,

                // Swipe de izquierda a derecha (startToEnd): editar
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.green,
                  child: const Icon(Icons.edit, color: Colors.white),
                ),

                // Swipe de derecha a izquierda (endToStart): borrar
                secondaryBackground: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),

                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    final bool? confirmarEdit = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirmar'),
                        content: const Text('¿Quieres eliminar esta muestra?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('No')),
                          TextButton(
                            onPressed: () async {
                             // Cierra el diálogo primero
                              try {
                                await updateStateSample(sample); // Espera la actualización
                                Navigator.pop(context, true); 
                              } catch (e) {
                                // Manejo de error, por ejemplo:
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error al actualizar la muestra')),);
                              }
                            },
                            child: const Text('Sí'),
                          ),
                        ],
                      ),
                    );
                    return confirmarEdit; // No eliminar
                  } else if (direction == DismissDirection.startToEnd) {
                    // Swipe para borrar: confirmamos eliminar
                    final bool? confirmarDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirmar'),
                        content: const Text('¿Quieres editar esta muestra?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('No')),
                          TextButton(
                              onPressed: () => {
                                
                                Navigator.pop(context, true),
                                Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditSample(idMuestra: sample.id),
                              ),
                            )
                              },
                              child: const Text('Sí')),
                        ],
                      ),
                    );
                    return confirmarDelete ?? false;
                  }
                  return false;
                },

                onDismissed: (direction) {
                  if (direction == DismissDirection.endToStart) {
                    // Solo borrar cuando swipe sea de derecha a izquierda
                    setState(() {
                      samplesFilter.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Muestra eliminada')),
                    );
                    // Aquí podrías llamar a tu API para borrar permanentemente
                  }
                },

                child: sampleTile(
                  context,
                  sample,
                  classification[sample.typeSample]?['color'] ?? colors.primary,
                  creacionDateFormat,
                  formattedTime
                ),
              );
              // return sampleTile(
              //   context,
              //   sample,
              //   classification[sample.typeSample]?['color'] ?? colors.primary,
              //   DateFormat('dd/MM/yyyy').format(creationTime),
              //   formattedTime,
              // );
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkmode = ref.watch(isDarkModeProvider);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Historial'),
          actions: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.filter_alt_outlined),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: isDarkmode
                          ? Colors.black
                          : Colors.white, // Cambia el color de fondo
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      isScrollControlled: true, // permite ajustar el tamaño
                      builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                          // Ocupa solo el tamaño necesario
                          child: Wrap(
                            children: [
                              ...classification.entries.map((entry) {
                                final category = entry.key;
                                final color = entry.value['color'];
                                final icon = entry.value['icon'];
                                return Center(
                                  child: ListTile(
                                    selectedTileColor:
                                        color, // si deseas que al tocar se quede así
                                    leading: CircleAvatar(
                                      backgroundColor: color,
                                      child: Icon(icon, color: Colors.white),
                                    ),
                                    title: Text(category),
                                    onTap: () {
                                      setState(() {
                                        _selectedFilter = category;
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                );
                              }),
                              ListTile(
                                leading: const Icon(Icons.clear),
                                title: const Text('Quitar filtro'),
                                onTap: () {
                                  setState(() {
                                    _selectedFilter = null;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    setState(
                        () {}); // Refresca la pantalla al presionar el botón
                  },
                ),
              ],
            )
          ],
        ),
        body: buildSampleList());
  }
}

Widget sampleTile(BuildContext context, Sample sample, Color tagColor,
    String formattedDate, String formattedTime) {
  final colors = Theme.of(context).colorScheme;
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    elevation: 0,
    color: colors.primary.withOpacity(0.05),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      leading: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            backgroundColor: colors.primary,
            radius: 24,
            child: Text(
              sample.sampleName.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w900),
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
              sample.typeSample,
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
