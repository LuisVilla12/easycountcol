import 'dart:convert';
import 'dart:io';

import 'package:easycoutcol/app/resultadoMuestra.dart';
import 'package:easycoutcol/app/updatesFollow.dart';
import 'package:easycoutcol/config/presentation/providers/login_provider.dart';
import 'package:easycoutcol/config/presentation/wigets/input_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class EditFollowScreen extends StatefulWidget {
  static const String name = 'edit_follow_screen';
  final int idFollow;
  const EditFollowScreen({super.key, required this.idFollow});

  @override
  State<EditFollowScreen> createState() => _EditFollowScreenState();
}

class _EditFollowScreenState extends State<EditFollowScreen> {
  final GlobalKey<FormState> formKeySample = GlobalKey<FormState>();
  final TextEditingController idFollowController = TextEditingController();
  final TextEditingController nameFollowController = TextEditingController();
  final TextEditingController descripcionFollowController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  int? idUser;

  late Future<Map<String, dynamic>> data;
  @override
  void initState() {
    super.initState();
    data = fetchData();
  }

  @override
  void dispose() {
    idFollowController.dispose();
    nameFollowController.dispose();
    descripcionFollowController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  void cleanControllers() {
    idFollowController.clear();
    nameFollowController.clear();
    descripcionFollowController.clear();
    dateController.clear();
    timeController.clear();
  }

  Future<Map<String, dynamic>> fetchData() async {
    final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000';
        final infoUrl = '$apiUrl/follows/info/${widget.idFollow}';

    final responses = await Future.wait([
      http.get(Uri.parse(infoUrl)),
    ]);

    if (responses.any((res) => res.statusCode != 200)) {
      throw Exception('Error al cargar datos');
    }
    final follow = jsonDecode(responses[0].body);
    return {
      'follow': follow['follow'],
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // Desactiva el botón de retroceso
        foregroundColor: Colors.white,
        title:
            const Text('Editar Muestra', style: TextStyle(color: Colors.white)),
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
            // Asignar el valor por defecto si aún no se ha seleccionado
            idFollowController.text = resultado.id.toString();
            nameFollowController.text = resultado.name;
            timeController.text=resultado.formattedTime;
            dateController.text=resultado.dateSample;
            // descripcionFollowController.text = resultado.description;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(4),
              child: Form(
                key: formKeySample,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tarjeta de Información
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Nombre de la muestra
                          InputCustom(
                            labelInput: 'Nombre de la muestra',
                            iconInput: Icon(Icons.label_important,
                                color: colors.primary),
                            controller: nameFollowController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El campo es requerido.';
                              }
                              if (value.length < 2) {
                                return 'El campo debe  tener una longitud valida.';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          // Tipo de muestra
                          const SizedBox(
                            height: 12,
                          ),
                          InputCustom(
                            labelInput: 'Fecha de realización',
                            readOnly: true,
                            iconInput:
                                Icon(Icons.date_range_outlined, color: colors.primary),
                            controller: dateController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El campo es requerido.';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          InputCustom(
                            labelInput: 'Hora de realización',
                            readOnly: true,
                            iconInput:
                                Icon(Icons.date_range_outlined, color: colors.primary),
                            controller: timeController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El campo es requerido.';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 20,),
                          // Imagen Original
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                          const SizedBox(height: 30),
                    SizedBox(
                  width: double.infinity,
                  child: Consumer(
                    builder: (context, ref, child) {
                      final idUser =
                          ref.watch(idUserProvider); // Obtener el ID de Riverpod
                      return FilledButton.icon(
                        onPressed: () async {
                          // Solicita al usuario la confirmación antes de registrar la muestra
                          final confirmSendSample = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmar'),
                            content: const Text(
                                '¿Deseas actualizar la muestra?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(
                                        false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(
                                        true),
                                child: const Text('Aceptar'),
                              ),
                            ],
                          ),                        
                          );
                          if (confirmSendSample == true) {
                          final isValid = formKeySample.currentState!.validate();
                          if (!isValid) return;
                          if (!context.mounted) return;
                          try {
                            final result = await updatesFollow(
                              followID: int.parse(idFollowController.text),
                              followName: nameFollowController.text,
                              followDescription: descripcionFollowController.text,
                              );
                            if (result['success']) {
                              final int idSample = result['idSample'];
                              await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Éxito"),
                                  content: const Text(
                                      "Muestra actualizada correctamente"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(
                                            true); // Devuelve un valor al cerrar el diálogo
                                      },
                                      child: const Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                              cleanControllers();
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) =>
                              //         ResultsScreen(idFollow: idSample),
                              //   ),
                              // );
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Error"),
                                  content: const Text(
                                      'Ocurrió un error al actualizar la muestra. Por favor intenta nuevamente.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                            }
                          } catch (e) {
                            // print(e);
                          }
                        }
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Actualizar muestra'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  )),
                  const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ],
                ),
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
