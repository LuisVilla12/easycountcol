import 'package:easycoutcol/app/Follows.dart';
import 'package:easycoutcol/config/presentation/providers/login_provider.dart';
import 'package:easycoutcol/config/presentation/screens/follows/edit_follow_screen.dart';
import 'package:easycoutcol/config/presentation/screens/follows/add_follow_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../records/records_screen.dart';

class FollowsScreen extends ConsumerStatefulWidget {
  static const String name = 'follow_screen';
  const FollowsScreen({super.key});

  @override
  ConsumerState<FollowsScreen> createState() => _FollowsScreenState();
}

class _FollowsScreenState extends ConsumerState<FollowsScreen> {
  int? idUser;
  
  @override
  void initState() {
    super.initState();
    // Saber el calor actual del id_usuario que inicio sesión directamente desde riverpod
    idUser = ref.read(idUserProvider);
  }

  // Obtener las muestras de la API
  Future<List<Follows>> fetchFollows() async {

    // Utilizar dotenv para manejar la URL de la API
    final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000';
    final response = await http.get(Uri.parse('$apiUrl/follows/$idUser'));

    // print(response.body);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      final List<dynamic> followsList = jsonData['follows'] ?? [];
      // print(followsList);
      // Mapea cada sublista a un objeto Follows
      return followsList.map((item) => Follows.fromJsonList(item)).toList();
    } else {
      throw Exception('Error los siguimientos');
    }
  }

  //Actualizar el estado de la muestra
  Future<void> updateStateFollow(Follows follow) async {
    final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000';
    final response = await http.put(
      Uri.parse('$apiUrl/follow/state/${follow.id}'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el seguimiento: ${response.statusCode}');
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
    'Otro': {
      'color': Colors.grey.shade700,
      'icon': Icons.category_outlined,
    },
  };

  // Construir listado de muestras
  Widget buildSampleList() {
    final colors = Theme.of(context).colorScheme;
    return FutureBuilder<List<Follows>>(
      future: fetchFollows(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay siguimientos disponibles'));
        } else {
          // Obtener todas las muestras
          final allFollows = snapshot.data!;       
          return ListView.builder(
            itemCount: allFollows.length,
            itemBuilder: (context, index) {
              final follow = allFollows[index];
              // print(sample.creationDate);
              final timeFollow = follow.creationTime;
              // Convertir el dato que viene de la base de datos a datatime
              final DateTime now = DateTime.now();
              // Convertir de string a DateTime
              final DateTime creationTime = DateTime(now.year, now.month, now.day).add(Duration(seconds: timeFollow.toInt()));

              final DateTime creationDate = DateTime.parse(follow.creationDate);
              // Dar formato a la fecha de creación
              String creacionDateFormat = DateFormat('dd-MM-yyyy').format(creationDate);

              // Convertir el datatime a time formateado
              final String formattedTime =
                  DateFormat('HH:mm:ss').format(creationTime);
              return Dismissible(
                key: Key(
                    follow.id.toString()), // Asegúrate que follow.id sea único

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
                        content: const Text('¿Quieres eliminar este seguimiento?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('No')),
                          TextButton(
                            onPressed: () async {
                             // Cierra el diálogo primero
                              try {
                                await updateStateFollow(follow); // Espera la actualización
                                Navigator.pop(context, true); 
                              } catch (e) {
                                // Manejo de error, por ejemplo:
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error al actualizar el seguimiento')),);
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
                        content: const Text('¿Quieres editar este seguimiento?'),
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
                                    EditFollowScreen(idFollow: follow.id),
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
                      allFollows.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Seguimiento eliminado')),
                    );
                    // Aquí podrías llamar a tu API para borrar permanentemente
                  }
                },

                child: followTile(
                  context,
                  follow,
                  classification[follow.nameFollow]?['color'] ?? colors.primary,
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
    return Scaffold(
        appBar: AppBar(
          title: const Text('Seguimientos'),
          actions: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddFollowScreen(),
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
        body: buildSampleList());
  }
}

Widget followTile(BuildContext context, Follows follow, Color tagColor,
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
              follow.nameFollow.substring(0, 1).toUpperCase(),
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
              follow.nameFollow,
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
        Navigator.pop(context);
        // Navegar a la pantalla de records del seguimiento
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecordsScreen(followID: follow.id),
          ),
        );
      },
    ),
  );
}
