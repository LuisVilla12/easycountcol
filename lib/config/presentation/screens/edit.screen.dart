import 'dart:convert';
import 'dart:io';

import 'package:easycoutcol/app/resultadoMuestra.dart';
import 'package:easycoutcol/app/updateSample.dart';
import 'package:easycoutcol/config/presentation/providers/login_provider.dart';
import 'package:easycoutcol/config/presentation/screens/results_screen.dart';
import 'package:easycoutcol/config/presentation/wigets/input_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class EditSample extends StatefulWidget {
  static const String name = 'edit_sample';
  final int idMuestra;
  const EditSample({super.key, required this.idMuestra});

  @override
  State<EditSample> createState() => _EditSampleState();
}

class _EditSampleState extends State<EditSample> {
  final GlobalKey<FormState> formKeySample = GlobalKey<FormState>();
  final TextEditingController nameSampleController = TextEditingController();
  final TextEditingController typeSampleController = TextEditingController();
  final TextEditingController factorSampleController = TextEditingController();
  final TextEditingController volumenSampleController = TextEditingController();
  final TextEditingController mediumController = TextEditingController();
  final TextEditingController countController = TextEditingController();
  final TextEditingController timeProcesingController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  String? selectedMedium;
  String? selectedClasification;
  String imagePath = '';
  int? idUser;

  final List<String> mediumList = [
    'Agar MacConkey',
    'Agar nutritivo',
    'Agar sangre',
    'Agar Sabouraud',
  ];

  final List<String> clasificationList = [
    'Clinica - Biológica', //Sangre, saliva, orina, hisopados
    'Ambiental', //Aire, superficies, agua, suelo
    'Alimentos', //Leches, frutas, verduras, carnes
    'Material', //Guantes, ropa de laboratorio, utensilios
    'Otras muestras', //Otros tipos de muestras
  ];
  late Future<Map<String, dynamic>> data;
  @override
  void initState() {
    super.initState();
    data = fetchData();
  }

  @override
  void dispose() {
    nameSampleController.dispose();
    typeSampleController.dispose();
    factorSampleController.dispose();
    volumenSampleController.dispose();
    mediumController.dispose();
    countController.dispose();
    timeProcesingController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  void cleanControllers() {
    nameSampleController.clear();
    typeSampleController.clear();
    factorSampleController.clear();
    volumenSampleController.clear();
    mediumController.clear();
    countController.clear();
    timeProcesingController.clear();
    dateController.clear();
    timeController.clear();
    imagePath = '';
    setState(() {
      selectedMedium = null;
      selectedClasification = null;
    });
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
            final resultado = ResultadoMuestra.fromMap(snapshot.data!);
            // Asignar el valor por defecto si aún no se ha seleccionado
            nameSampleController.text = resultado.name;
            volumenSampleController.text = resultado.volumenSample;
            timeProcesingController.text = resultado.processingTime.toString();
            countController.text = resultado.count.toString();
            factorSampleController.text = resultado.factorSample;
            timeController.text=resultado.formattedTime;
            dateController.text=resultado.dateSample;
            selectedMedium ??= resultado.medioSample;
            mediumController.text = selectedMedium!;

            selectedClasification ??= resultado.typeSample;
            typeSampleController.text = selectedClasification!;

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
                            controller: nameSampleController,
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
                          DropdownButtonFormField<String>(
                            initialValue: selectedClasification,
                            decoration: InputDecoration(
                              labelText: 'Tipo de muestra',
                              prefixIcon:
                                  Icon(Icons.science, color: colors.primary),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: colors.primary,
                                    width: 2), // cuando NO está enfocado
                              ),
                            ),
                            items: clasificationList.map((String medium) {
                              return DropdownMenuItem<String>(
                                value: medium,
                                child: Text(medium),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedClasification = value;
                                typeSampleController.text = value ?? '';
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Seleccione el tipo de muestra.';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          InputCustom(
                            labelInput: 'Volumen de sembrado (mL)',
                            iconInput: Icon(Icons.water, color: colors.primary),
                            controller: volumenSampleController,
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
                            labelInput: 'Factor de dilución',
                            iconInput:
                                Icon(Icons.local_drink, color: colors.primary),
                            controller: factorSampleController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El campo es requerido.';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          DropdownButtonFormField<String>(
                            initialValue: selectedMedium,
                            decoration: InputDecoration(
                              labelText: 'Medio de cultivo',
                              prefixIcon:
                                  Icon(Icons.trending_up, color: colors.primary),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: colors.primary,
                                    width: 2), // cuando NO está enfocado
                              ),
                            ),
                            items: mediumList.map((String medium) {
                              return DropdownMenuItem<String>(
                                value: medium,
                                child: Text(medium),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedMedium = value;
                                mediumController.text = value ?? '';
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Seleccione un medio de cultivo.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          InputCustom(
                            labelInput: 'Tiempo de procesamiento',
                            readOnly: true,
                            iconInput:
                                Icon(Icons.timer_outlined, color: colors.primary),
                            controller: timeProcesingController,
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
                            labelInput: 'Conteo de UFC',
                            readOnly: true,
                            iconInput:
                                Icon(Icons.calculate_outlined, color: colors.primary),
                            controller: countController,
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
                                '¿Deseas registrar la muestra?'),
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
                          if (selectedMedium == null ||
                              selectedMedium == 'Sin seleccionar') {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Medio de cultivo requerido'),
                                content: const Text(
                                    'Por favor selecciona un medio de cultivo antes de continuar.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Aceptar'),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }
                          if (!context.mounted) return;
                          try {
                            final result = await updateSample(
                              // idSample=
                              sampleName: nameSampleController.text,
                              idUser: idUser,
                              typeSample: typeSampleController.text,
                              volumenSample: volumenSampleController.text,
                              factorSample: factorSampleController.text,
                              medioSample: mediumController.text,
                            );
                            if (result['success']) {
                              final int idSample = result['idSample'];
                              await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Éxito"),
                                  content: const Text(
                                      "Muestra almacenada correctamente, continúa su análisis."),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ResultsScreen(idMuestra: idSample),
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Error"),
                                  content: const Text(
                                      'Ocurrió un error al registrarse'),
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
                        label: const Text('Registrar muestra'),
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
