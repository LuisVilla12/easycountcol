import 'package:easycoutcol/config/presentation/wigets/input_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easycoutcol/app/registerFollow.dart';
import 'package:easycoutcol/config/presentation/providers/login_provider.dart';
import 'package:easycoutcol/config/functions/dialog_helper.dart';

class AddFollowScreen extends StatefulWidget {
  static const String name = 'add_follow_screen';
  const AddFollowScreen({super.key});

  @override
  State<AddFollowScreen> createState() => _AddFollowScreenState();
}

class _AddFollowScreenState extends State<AddFollowScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKeyFollow = GlobalKey<FormState>();
  final TextEditingController nameFollowController = TextEditingController();
  final TextEditingController descripcionFollowController =
      TextEditingController();
  int? idUser;
  late Future<Map<String, dynamic>> data;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nameFollowController.dispose();
    descripcionFollowController.dispose();
    super.dispose();
  }

  void cleanControllers() {
    nameFollowController.clear();
    descripcionFollowController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // Desactiva el botón de retroceso
        foregroundColor: Colors.white,
        title: const Text('Registrar Seguimiento',
            style: TextStyle(color: Colors.white)),
        backgroundColor: colors.primary,
      ),
      body: SingleChildScrollView(
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
                      iconInput:
                          Icon(Icons.label_important, color: colors.primary),
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
                      maxLines: 4,
                      iconInput:
                          Icon(Icons.label_important, color: colors.primary),
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

                    const SizedBox(height: 30),
                    SizedBox(
                        width: double.infinity,
                        child: Consumer(
                          builder: (context, ref, child) {
                            final idUser = ref.watch(
                                idUserProvider); // Obtener el ID de Riverpod
                            return FilledButton.icon(
                              onPressed: () async {
                                // Solicita al usuario la confirmación antes de registrar la muestra
                                final confirmSendFollow =
                                    await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirmar'),
                                    content: const Text(
                                        '¿Deseas guardar el seguimiento?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text('Aceptar'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmSendFollow == true) {
                                  final isValid =
                                      formKeyFollow.currentState!.validate();
                                  if (!isValid) return;
                                  try {
                                    final result = await setFollowRegister(
                                      followName: nameFollowController.text,
                                      followDescription:
                                          descripcionFollowController.text,
                                      idUser: idUser,
                                    );
                                    if (result) {
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
                              label: const Text('Guardar'),
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

