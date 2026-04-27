import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:easycoutcol/app/registerRecord.dart';
import 'package:easycoutcol/config/menu/side_menu.dart';
import 'package:easycoutcol/config/presentation/providers/login_provider.dart';
import 'package:easycoutcol/config/presentation/screens/principal/overlay_screen.dart';
import 'package:easycoutcol/config/presentation/wigets/input_custom.dart';
import 'package:easycoutcol/config/services/camera_services_implementation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easycoutcol/config/presentation/screens/records/show_record_screen.dart';

class AddRecordScreen extends StatefulWidget {
  static const String name = 'add_record_screen';
  final int followID;
  // ignore: prefer_const_constructors_in_immutables
  AddRecordScreen({super.key, required this.followID});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  @override
  Widget build(BuildContext context) {
    // Saber la referencia actual
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final GlobalKey<_ViewCameraState> cameraKey = GlobalKey<_ViewCameraState>();

    return Scaffold(
      resizeToAvoidBottomInset: true, // permite que se ajuste con el teclado
      appBar: AppBar(
        title: const Text('Registrar muestra'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh), // ícono de reset
            tooltip: 'Resetear formulario',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('¿Estás seguro?'),
                  content: const Text(
                      'Esto limpiará todos los campos del formulario.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Confirmar'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                cameraKey.currentState?.cleanControllers();
              }
            },
          ),
        ],
      ),
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      body: _ViewCamera(key: cameraKey, followID: widget.followID),
    );
  }
}

class _ViewCamera extends StatefulWidget {
    final int followID;
  const _ViewCamera({super.key, required this.followID});

  @override
  State<_ViewCamera> createState() => _ViewCameraState();
}

class _ViewCameraState extends State<_ViewCamera>
  with TickerProviderStateMixin {
  late final TabController _tabController;
  final GlobalKey<FormState> formKeySample = GlobalKey<FormState>();
  final TextEditingController nameSampleController = TextEditingController();

  
  String imagePath = ''; 
  int? followID ;

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
    super.dispose();
  }

  void cleanControllers() {
    nameSampleController.clear();
    imagePath = '';
    setState(() {
    });
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      child: Form(
        key: formKeySample,
        child: Column(
          children: [
            InputCustom(
              labelInput: 'Dia de la muestra',
              hintInput: 'Ingrese el numero de dia de la muestra',
              iconInput: Icon(Icons.label_important, color: colors.primary),
              controller: nameSampleController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El campo es requerido.';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            TabBar(
              controller: _tabController,
              onTap: (_) => setState(() {}), // Importante para refrescar
              tabs: const [
                Tab(text: 'Cámara'),
                Tab(text: 'Subir'),
              ],
            ),
            const SizedBox(height: 20),
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
                  ? takeAPhoto(context, imagePath)
                  : uploadAPhoto(context, imagePath),
            ),
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
                          // llamar a la función de carga
                          showLoadingDialog(context);
                          final result = await setRecordRegister(
                            dayNumber: nameSampleController.text,
                            followID: widget.followID,
                            sampleRoute: imagePath,
                          );
                          if (result['success']) {
                            print('Muestra registrada con ID: ${result['idSample']}');
                            // Ocultar spinner
                            Navigator.of(context).pop();
                            // Mostrar mensaje de éxito
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Muestra registrada exitosamente")),
                            );
                            // Navegar a la pantalla de resultados
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShowRecordScreen(idMuestra: result['idSample']),
                              ),
                            );
                          } else {
                            // Ocultar spinner si la respuesta no es exitosa
                             Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(" ${result['message']}")),
                            );
                          }
                          // cerrar la carga
                          Navigator.of(context).pop();
                          
                        } catch (e) {
                          print(e);
                          // Ocultar spinner si ocurre un error
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                        );
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
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }

  Widget takeAPhoto(BuildContext context, String imagenPath) {
    final colors = Theme.of(context).colorScheme;
    return DottedBorder(
      options: RectDottedBorderOptions(
        dashPattern: [10, 5],
        strokeWidth: 2,
        padding: EdgeInsets.all(30),
        color: colors.primary,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        color: colors.primary,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Si no hay imagen mostrar el icono de la camara, caso contrario mostrar el preview de la imagen
            imagePath == ''?Icon(Icons.camera_alt_outlined, color: Colors.white, size: 40):showImageView(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: colors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                showCaptureRecommendations(context);
              },
              icon: const Icon(Icons.camera_alt_outlined),
              label: imagePath == ''
                  ? const Text('Capturar una imagen')
                  : const Text('Volver a tomar una imagen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget uploadAPhoto(BuildContext context, String imagenPath) {
    final colors = Theme.of(context).colorScheme;
    return DottedBorder(
      options: RectDottedBorderOptions(
        dashPattern: [10, 5],
        strokeWidth: 2,
        padding: EdgeInsets.all(30),
        color: colors.primary,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        color: colors.primary,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            imagePath == ''?Icon(Icons.upload_file_outlined, color: Colors.white, size: 40):showImageView(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: colors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final photoPath =
                    await CameraServicesImplementation().selectPhoto();
                if (photoPath == null) return;
                photoPath;
                setState(() {
                  imagePath = photoPath;
                });
              },
              icon: const Icon(Icons.upload_outlined),
              label: imagePath == ''
                  ? const Text('Seleccionar una imagen')
                  : const Text('Seleccionar otra  imagen'),
            ),
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
                  child: Padding(
                    padding: EdgeInsets.all(5),
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
              if (imagePathOverlay != null) {
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

// Función para mostrar el diálogo de carga
void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // No se puede cerrar al tocar fuera
    builder: (context) {
      return const Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text(
                "Procesando...",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    },
  );
}
