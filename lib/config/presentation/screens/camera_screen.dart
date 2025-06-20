import 'package:easycoutcol/config/services/camera_test.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CircularCameraGuide extends StatefulWidget {
  static const String name='test_camera';
  
  @override
  _CircularCameraGuideState createState() => _CircularCameraGuideState();
}

class _CircularCameraGuideState extends State<CircularCameraGuide> {
  CameraController? controller;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    controller = CameraController(cameras.first, ResolutionPreset.medium);
    await controller?.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: Text('camara'),),
      body: Stack(
        children: [
          CameraPreview(controller!),
          Positioned.fill(
            child: CustomPaint(
              painter: CircularOverlay(),
            ),
          ),
          const Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Coloca la caja Petri en el círculo',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
