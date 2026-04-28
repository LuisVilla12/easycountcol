import 'dart:convert';
import 'dart:io';

import 'package:easycoutcol/config/presentation/wigets/input_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:easycoutcol/config/functions/dialog_helper.dart';
import 'package:easycoutcol/app/showRecord.dart';


class EditRecordScreen extends StatefulWidget {
  static const String name = 'edit_record_screen';
  final int idRecord;
  const EditRecordScreen({super.key, required this.idRecord});

  @override
  State<EditRecordScreen> createState() => _EditRecordScreenState();
}

class _EditRecordScreenState extends State<EditRecordScreen> {
  final GlobalKey<FormState> formKeyFollow = GlobalKey<FormState>();
  final TextEditingController idRecordController = TextEditingController();
  final TextEditingController dayNumberController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  late Future<Map<String, dynamic>> data;
  @override
  void initState() {
    super.initState();
    data = fetchData();
  }

  @override
  void dispose() {
    idRecordController.dispose();
    dayNumberController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  void cleanControllers() {
    idRecordController.clear();
    dayNumberController.clear();
    dateController.clear();
    timeController.clear();
  }

  Future<Map<String, dynamic>> fetchData() async {
    final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000';
    final infoUrl = '$apiUrl/record-show/${widget.idRecord}';

    final responses = await Future.wait([
      http.get(Uri.parse(infoUrl)),
    ]);

    if (responses.any((res) => res.statusCode != 200)) {
      throw Exception('Error al cargar datos');
    }
    final record = jsonDecode(responses[0].body);
    return {
      'record': record['record'],
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // Desactiva el botón de retroceso
        foregroundColor: Colors.white,
        title: const Text('Editar Seguimiento',
            style: TextStyle(color: Colors.white)),
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
            final resultado = ShowRecord.fromMap(snapshot.data!);
            // Asignar el valor por defecto si aún no se ha seleccionado
            idRecordController.text = resultado.id.toString();
            dayNumberController.text =  resultado.dayNumber.toString();
            // timeController.text = resultado.formattedTime;
            dateController.text = resultado.dateSample;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(4),
              child: Form(
                key: formKeyFollow,
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
                            labelInput: 'Día del seguimiento',
                            iconInput: Icon(Icons.label_important,
                                color: colors.primary),
                            controller: dayNumberController,
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
                          InputCustom(
                            labelInput: 'Fecha de realización',
                            readOnly: true,
                            iconInput: Icon(Icons.date_range_outlined,
                                color: colors.primary),
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
                            iconInput: Icon(Icons.date_range_outlined,
                                color: colors.primary),
                            controller: timeController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El campo es requerido.';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          // Imagen Original

                          const SizedBox(height: 30),
                          SizedBox(
                              width: double.infinity,
                              child: Consumer(
                                builder: (context, ref, child) {
                                  return FilledButton.icon(
                                    onPressed: () async {
                                      // Solicita al usuario la confirmación antes de registrar la muestra
                                      final confirmSendFollow =
                                          await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Confirmar'),
                                          content: const Text(
                                              '¿Deseas actualizar el seguimiento?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: const Text('Aceptar'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmSendFollow == true) {
                                        final isValid = formKeyFollow
                                            .currentState!
                                            .validate();
                                        if (!isValid) return;
                                        try {
                                          final result = true;
                                          // await updatesFollow(
                                          //   followID: int.parse(
                                          //       idFollowController.text),
                                          //   followName:
                                          //       nameFollowController.text,
                                          //   followDescription:
                                          //       descripcionFollowController
                                          //           .text,
                                          // );
                                          if (result) {
                                            final res = await mostrarDialogo(
                                              context: context,
                                              titulo: "Éxito",
                                              mensaje:
                                                  "Seguimiento actualizado correctamente",
                                            );

                                            if (res == true) {
                                              Navigator.of(context).pop(true); 
                                              
                                            }
                                          } else {
                                            await mostrarDialogo(
                                              context: context,
                                              titulo: "Error",
                                              mensaje:
                                                  "Ocurrió un error. Intenta nuevamente.",
                                            );
                                          }
                                        } catch (e) {
                                          // print(e);
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.save),
                                    label: const Text('Actualizar seguimiento'),
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

