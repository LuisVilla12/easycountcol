import 'dart:convert';
import 'dart:io';
import 'package:easycoutcol/app/resultadoRecord.dart';
import 'package:easycoutcol/app/updatesRecords.dart';
import 'package:easycoutcol/config/presentation/wigets/input_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:easycoutcol/config/functions/dialog_helper.dart';

class EditRecordScreen extends StatefulWidget {
  static const String name = 'edit_record';
  final int idMuestra;
  const EditRecordScreen({super.key, required this.idMuestra});

  @override
  State<EditRecordScreen> createState() => _EditRecordScreenState();
}

class _EditRecordScreenState extends State<EditRecordScreen> {
  final GlobalKey<FormState> formKeySample = GlobalKey<FormState>();
  final TextEditingController idRecordController = TextEditingController();
  final TextEditingController dayNumberController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  
  String imagePath = '';

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
    imagePath = '';
    setState(() {
    });
  }

  Future<Map<String, dynamic>> fetchData() async {
    final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000';
    final originalUrl = '$apiUrl/record/imagen-original/${widget.idMuestra}';
    final processedUrl = '$apiUrl/record/imagen-inferencia/${widget.idMuestra}';
    final infoUrl = '$apiUrl/record-info/${widget.idMuestra}';

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

  Widget showImageView() {
    if (imagePath == '') return const SizedBox.shrink();
    final file = File(imagePath);
    if (!file.existsSync()) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Text("La imagen no existe o no se pudo cargar."),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Image.file(
        file,
        width: 200,
        height: 200,
        fit: BoxFit.cover,
      ),
    );
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
            final resultado = ResultadoRecord.fromMap(snapshot.data!);
            // Asignar el valor por defecto si aún no se ha seleccionado
            idRecordController.text = resultado.id.toString();
            dayNumberController.text = 1.toString();           
            timeController.text = resultado.formattedTime;
            dateController.text = resultado.dateSample;

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
                            labelInput: 'Número de día',
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
                                  return FilledButton.icon(
                                    onPressed: () async {
                                      // Solicita al usuario la confirmación antes de registrar la muestra
                                      final confirmSendSample =
                                          await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Confirmar'),
                                          content: const Text(
                                              '¿Deseas actualizar la muestra?'),
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
                                      if (confirmSendSample == true) {
                                        final isValid = formKeySample
                                            .currentState!
                                            .validate();
                                        if (!isValid) return;
                                        
                                        if (!context.mounted) return;
                                        try {
                                          final result = await updateRecord(
                                            recordID: int.parse(
                                                idRecordController.text),
                                            dayNumber:
                                                dayNumberController.text,
                                          );
                                          if (result['success']) {
                                            final res = await mostrarDialogo(
                                              context: context,
                                              titulo: "Éxito",
                                              mensaje:
                                                  "Seguimiento actualizado correctamente",
                                            );

                                            if (res == true) {
                                              Navigator.of(context).pop(
                                                  true); // ← regresa a pantalla anterior
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
