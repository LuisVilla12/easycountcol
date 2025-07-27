import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class OverlayScreen extends StatefulWidget {
  static const String name = 'overlay_name';

  const OverlayScreen({Key? key}) : super(key: key);

  @override
  State<OverlayScreen> createState() => _OverlayScreenState();
}

class _OverlayScreenState extends State<OverlayScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.first;

      _controller = CameraController(
        camera,
        ResolutionPreset.ultraHigh,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      setState(() {});
    } catch (e) {
      print('Error al inicializar la cámara: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (_controller == null || _initializeControllerFuture == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                // CameraPreview(_controller!),
                SizedBox.expand(
                  child: CameraPreview(_controller!),
                ),
                // Overlay personalizado
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.primary, width: 4),
                    ),
                    child: Center(
                      child: Text(
                        "Coloca aquí la muestra",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FloatingActionButton(
                      heroTag: 'take_photo',
                      backgroundColor: colors.primary,
                      onPressed: () async {
                        try {
                          await _initializeControllerFuture;
                          final picture = await _controller!.takePicture();

                          if (context.mounted) {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PreviewScreen(imagePath: picture.path),
                              ),
                            );
                            // Solo si se confirmó la imagen
                            if (result != null && result is String) {
                              Navigator.pop(context,
                                  result); // Regresa a Home con la imagen
                            }
                          }
                        } catch (e) {
                          print('Error al tomar foto: $e');
                        }
                      },
                      child: Icon(Icons.camera, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class PreviewScreen extends StatelessWidget {
  final String imagePath;

  const PreviewScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vista previa")),
      body: Column(
        children: [
          // Imagen en la parte superior (toma todo el espacio disponible arriba)
          Center(
            child: Image.file(
              File(imagePath),
              fit: BoxFit.contain,
              width: double.infinity,
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'repetir',
            onPressed: () {
              Navigator.pop(context); // Volver a tomar
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Repetir"),
            backgroundColor: Colors.red,
          ),
          FloatingActionButton.extended(
            heroTag: 'usar',
            onPressed: () {
              Navigator.pop(context, imagePath); // Confirmar imagen
            },
            icon: const Icon(Icons.check),
            label: const Text("Usar imagen"),
            backgroundColor: Colors.green,
          ),
        ],
      ),
    );
  }
}
