import 'package:easycoutcol/app/Records.dart';
import 'package:easycoutcol/config/presentation/providers/theme_provider.dart';
import 'package:easycoutcol/config/presentation/screens/records/add_record_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';


// ignore: must_be_immutable
class RecordsScreen extends ConsumerStatefulWidget {
  static const String name = 'records_screen';
  int followID;
  RecordsScreen({super.key, required this.followID});

  @override
  ConsumerState<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends ConsumerState<RecordsScreen> {
  int? idUser;
  
  @override
  void initState() {
    super.initState();
    // Saber el calor actual del id_usuario que inicio sesión directamente desde riverpod
    // idUser = ref.read(idUserProvider);
  }

  // Obtener las muestras de la API
  Future<List<Records>> fetchRecords() async {

    // Utilizar dotenv para manejar la URL de la API
    final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000';
    final response = await http.get(Uri.parse('$apiUrl/records/${widget.followID}'));

    // print(response.body);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      final List<dynamic> recordsList = jsonData['records'] ?? [];
      // print(recordsList);
      // Mapea cada sublista a un objeto Records
      return recordsList.map((item) => Records.fromJsonList(item)).toList();
    } else {
      throw Exception('Error al cargar los registros: ${response.statusCode}');
    }
  }

  //Actualizar el estado de la muestra
  Future<void> updateStateRecord(Records record) async {
    final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000';
    final response = await http.put(
      Uri.parse('$apiUrl/record/state/${record.id}'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el registro: ${response.statusCode}');
    }
  }

  // Construir listado de muestras
  Widget buildRecordsList() {
    final colors = Theme.of(context).colorScheme;
    return FutureBuilder<List<Records>>(
      future: fetchRecords(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay siguimientos disponibles'));
        } else {
          // Obtener todas las muestras
          final allRecords = snapshot.data!;       
          return ListView.builder(
            itemCount: allRecords.length,
            itemBuilder: (context, index) {
              final record = allRecords[index];
              // print(sample.creationDate);
              final timeRecord = record.creationTime;
              // Convertir el dato que viene de la base de datos a datatime
              final DateTime now = DateTime.now();
              // Convertir de string a DateTime
              final DateTime creationTime = DateTime(now.year, now.month, now.day).add(Duration(seconds: timeRecord.toInt()));

              final DateTime creationDate = DateTime.parse(record.creationDate);
              // Dar formato a la fecha de creación
              String creacionDateFormat = DateFormat('dd-MM-yyyy').format(creationDate);

              // Convertir el datatime a time formateado
              final String formattedTime =
                  DateFormat('HH:mm:ss').format(creationTime);
              return Dismissible(
                key: Key(
                    record.id.toString()), // Asegúrate que record.id sea único

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
                        content: const Text('¿Quieres eliminar este record?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('No')),
                          TextButton(
                            onPressed: () async {
                             // Cierra el diálogo primero
                              // try {
                              //   await updateStateFollow(record); // Espera la actualización
                              //   Navigator.pop(context, true); 
                              // } catch (e) {
                              //   // Manejo de error, por ejemplo:
                              //   ScaffoldMessenger.of(context).showSnackBar(
                              //     SnackBar(content: Text('Error al actualizar el seguimiento')),);
                              // }
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
                        content: const Text('¿Quieres editar este record?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('No')),
                          TextButton(
                              onPressed: () => {
                                
                            //     Navigator.pop(context, true),
                            //     Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) =>
                            //         EditFollowScreen(idFollow: record.id),
                            //   ),
                            // )
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
                      allRecords.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Record eliminado')),
                    );
                    // Aquí podrías llamar a tu API para borrar permanentemente
                  }
                },

                child: recordTile(
                  context,
                  record,
                  colors.primary,
                  creacionDateFormat,
                  formattedTime
                ),
              );
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
          title: const Text('Listado de registros'),
          actions: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddRecordScreen(),
                      ),
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
        body: buildRecordsList());
  }
}

Widget recordTile(BuildContext context, Records record, Color tagColor,
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
              record.dayNumber.toString(),
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
              record.dayNumber == 0 ? 'Día de la siembra' : 'Día ${record.dayNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold),
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
        // Navigator.pop(context);
        // Navegar a la pantalla de resultados del seguimiento
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => ResultsScreen(idMuestra: record.id),
        //   ),
        // );
      },
    ),
  );
}
