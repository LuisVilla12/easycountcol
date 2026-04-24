import 'dart:convert';
import 'dart:io';

import 'package:easycoutcol/app/resultadoFollow.dart';
import 'package:easycoutcol/app/updatesFollow.dart';
import 'package:easycoutcol/config/presentation/wigets/input_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddFollowScreen extends StatefulWidget {
  static const String name = 'add_follow_screen';
  const AddFollowScreen({super.key});

  @override
  State<AddFollowScreen> createState() => _AddFollowScreenState();
}

class _AddFollowScreenState extends State<AddFollowScreen> {
  final GlobalKey<FormState> formKeyFollow = GlobalKey<FormState>();
  final TextEditingController idFollowController = TextEditingController();
  final TextEditingController nameFollowController = TextEditingController();
  final TextEditingController descripcionFollowController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  late Future<Map<String, dynamic>> data;
  @override
  void initState() {
    super.initState();
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


  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // Desactiva el botón de retroceso
        foregroundColor: Colors.white,
        title:
            const Text('Agregar  Seguimiento', style: TextStyle(color: Colors.white)),
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
            final resultado = ResultadoFollow.fromMap(snapshot.data!);
            // Asignar el valor por defecto si aún no se ha seleccionado
            idFollowController.text = resultado.id.toString();
            nameFollowController.text = resultado.name;
            descripcionFollowController.text = resultado.description;
            timeController.text=resultado.formattedTime;
            dateController.text=resultado.dateFollow;

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
                            labelInput: 'Nombre del seguimiento',
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
                          InputCustom(
                            labelInput: 'Descripción del seguimiento',
                            iconInput: Icon(Icons.label_important,
                                color: colors.primary),
                            controller: descripcionFollowController,
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
                          
                          const SizedBox(height: 30),
                    SizedBox(
                  width: double.infinity,
                  child: Consumer(
                    builder: (context, ref, child) {
                      return FilledButton.icon(
                        onPressed: () async {
                          // Solicita al usuario la confirmación antes de registrar la muestra
                          final confirmSendFollow = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmar'),
                            content: const Text(
                                '¿Deseas actualizar el seguimiento?'),
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
                          if (confirmSendFollow == true) {
                          final isValid = formKeyFollow.currentState!.validate();
                          if (!isValid) return;
                          try {
                            final result = await updatesFollow(
                              followID: int.parse(idFollowController.text),
                              followName: nameFollowController.text,
                              followDescription: descripcionFollowController.text,
                              );
                            if (result['success']) {
                              // final int idSample = result['idSample'];
                              await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Éxito"),
                                  content: const Text(
                                      "Seguimiento actualizado correctamente"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(
                                            true); 
                                      },
                                      child: const Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Error"),
                                  content: const Text(
                                      'Ocurrió un error al actualizar el seguimiento. Por favor intenta nuevamente.'),
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

