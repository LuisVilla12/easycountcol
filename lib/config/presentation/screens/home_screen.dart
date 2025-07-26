import 'dart:io';

import 'package:easycoutcol/app/registerSample.dart';
import 'package:easycoutcol/config/menu/side_menu.dart';
import 'package:easycoutcol/config/presentation/providers/login_provider.dart';
import 'package:easycoutcol/config/presentation/screens/overlay_screen.dart';
import 'package:easycoutcol/config/presentation/screens/results_screen.dart';
import 'package:easycoutcol/config/presentation/wigets/input_custom.dart';
import 'package:easycoutcol/config/services/camera_services_implementation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:shared_preferences/shared_preferences.dart';
class HomeScreen extends StatelessWidget {
  static const String name = 'home_screen';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Saber la referencia actual
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      // resizeToAvoidBottomInset: true, // permite que se ajuste con el teclado
      appBar: AppBar(
        title: const Text('Registar muestra '),
      ),
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      body: const _ViewCamera(),
    );
  }
}

class _ViewCamera extends StatefulWidget {
  const _ViewCamera();

  @override
  State<_ViewCamera> createState() => _ViewCameraState();
}

class _ViewCameraState extends State<_ViewCamera>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final GlobalKey<FormState> formKeySample = GlobalKey<FormState>();
  final TextEditingController nameSampleController = TextEditingController();
  final TextEditingController typeSampleController = TextEditingController();
  final TextEditingController factorSampleController = TextEditingController();
  final TextEditingController volumenSampleController = TextEditingController();

  String imagePath = '';
  int? idUser;
  String? nameUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // cambiar el state del tab
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    nameSampleController.dispose();
    typeSampleController.dispose();
    factorSampleController.dispose();
    volumenSampleController.dispose();
    super.dispose();
  }

  Widget buildImageView() {
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Form(
        key: formKeySample,
        child: Column(
          children: [
            InputCustom(
              labelInput: 'Nombre de la muestra',
              hintInput: 'Ingrese el nombre de la muestra',
              iconInput: Icon(Icons.label_important, color: colors.primary),
              controller: nameSampleController,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'El campo es requerido.';
                if (value.length < 2)
                  return 'El campo debe  tener una longitud valida.';
                return null;
              },
            ),
            const SizedBox(height: 12),
            InputCustom(
              labelInput: 'Tipo de muestra',
              hintInput: 'Ingrese el tipo de muestra',
              iconInput: Icon(Icons.category, color: colors.primary),
              controller: typeSampleController,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'El campo es requerido.';
                if (value.length < 2)
                  return 'El campo debe  tener una longitud valida.';
                return null;
              },
            ),
            const SizedBox(height: 12),
            InputCustom(
              labelInput: 'Volumen de sembrado',
              hintInput: 'Ingrese el volumen de sembrado de la muestra',
              iconInput: Icon(Icons.local_drink, color: colors.primary),
              controller: volumenSampleController,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'El campo es requerido.';
                if (value.length < 2)
                  return 'El campo debe  tener una longitud valida.';
                return null;
              },
            ),
            const SizedBox(
              height: 12,
            ),
            InputCustom(
              labelInput: 'Factor de dilución',
              hintInput: 'Ingrese el factor de dilución la muestra',
              iconInput: Icon(Icons.science, color: colors.primary),
              controller: factorSampleController,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'El campo es requerido.';
                if (value.length < 2)
                  return 'El campo debe  tener una longitud valida.';
                return null;
              },
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              onTap: (_) => setState(() {}), // Importante para refrescar
              tabs: const [
                Tab(text: 'Cámara'),
                Tab(text: 'Subir'),
              ],
            ),
            const SizedBox(height: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _tabController.index == 0
                  ? Center(
                      child: Column(children: [
                        const SizedBox(
                          height: 5,
                        ),
                        FilledButton.icon(
                            onPressed: () {
                              showCaptureRecommendations(context);
                            },
                            icon: const Icon(Icons.camera_alt_rounded),
                            label: imagePath == ''
                                ? const Text('Capturar una imagen')
                                : const Text('Volver a tomar una imagen')),
                      ]),
                    )
                  : Center(
                      child: Column(children: [
                        const SizedBox(
                          height: 5,
                        ),
                        FilledButton.icon(
                            onPressed: () async {
                              final photoPath =
                                  await CameraServicesImplementation()
                                      .selectPhoto();
                              if (photoPath == null) return null;
                              photoPath;
                              setState(() {
                                imagePath = photoPath;
                              });
                            },
                            icon: const Icon(Icons.photo_library_sharp),
                            label: imagePath == ''
                                ? const Text('Seleccionar una imagen')
                                : const Text(
                                    'Volver a seleccionar una imagen')),
                      ]),
                    ),
            ),
            buildImageView(),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
                width: double.infinity,
                child: Consumer(
                  builder: (context, ref, child) {
                    final idUser =
                        ref.watch(idUserProvider); // Obtener el ID de Riverpod
                    return FilledButton.icon(
                      onPressed: () async {
                        final isValid = formKeySample.currentState!.validate();
                        if (!isValid) return;

                        if (imagePath == '') {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Imagen requerida'),
                              content: const Text(
                                  'Por favor selecciona o toma una imagen antes de continuar.'),
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
                          final result = await uploadSampleWithFile(
                            sampleName: nameSampleController.text,
                            idUser: idUser,
                            typeSample: typeSampleController.text,
                            volumenSample: volumenSampleController.text,
                            factorSample: factorSampleController.text,
                            sampleFile: imagePath,
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
                            nameSampleController.clear();
                            typeSampleController.clear();
                            volumenSampleController.clear();
                            factorSampleController.clear();
                            formKeySample.currentState!.reset();
                            imagePath = '';
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
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Registrarse'),
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
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }

  void showCaptureRecommendations(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.tips_and_updates_outlined, color: colors.primary),
            const SizedBox(width: 8),
            const Text('Recomendaciones'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Icon(Icons.wb_sunny_outlined, color: Colors.amber),
                title: Text('Iluminación'),
                subtitle: Text(
                  'Asegúrate de tener buena iluminación uniforme. Evita sombras y reflejos directos sobre la placa.',
                ),
              ),
              ListTile(
                leading: Icon(Icons.social_distance, color: Colors.green),
                title: Text('Distancia'),
                subtitle: Text(
                  'Mantén la cámara a una distancia de 15–20 cm de la placa para capturar todos los detalles.',
                ),
              ),
              ListTile(
                leading: Icon(Icons.center_focus_strong, color: Colors.blue),
                title: Text('Enfoque'),
                subtitle: Text(
                  'Asegúrate de que la imagen esté bien enfocada. Toca la pantalla para ajustar el enfoque si es necesario.',
                ),
              ),
              ListTile(
                leading: Icon(Icons.crop_square, color: Colors.purple),
                title: Text('Posición'),
                subtitle: Text(
                  'Coloca la placa de Petri dentro del marco guía. Mantén la cámara paralela a la superficie de la placa.',
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Card(
                  color: Color(0xFFF0F4F8),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      '💡 Consejo profesional: Para obtener resultados óptimos, utiliza un fondo blanco o negro uniforme detrás de la placa.',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final imagePathOverlay = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OverlayScreen()),
              );
              if (imagePath != null) {
                setState(() {
                  imagePath = imagePathOverlay;
                });
              }
            },
            child: const Text('Entendido, capturar imagen'),
          ),
        ],
      ),
    );
  }
}
