import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; 

class CameraViewPage extends StatefulWidget {
  final String cameraTitle;

  const CameraViewPage({super.key, required this.cameraTitle});

  @override
  State<CameraViewPage> createState() => _CameraViewPageState();
}

class _CameraViewPageState extends State<CameraViewPage> {
  CameraController? controller;
  List<CameraDescription>? cameras;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      controller = CameraController(cameras![0], ResolutionPreset.medium);
      await controller!.initialize();
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.cameraTitle)),
      body:
          controller == null || !controller!.value.isInitialized
              ? const Center(child: CircularProgressIndicator())
              : CameraPreview(controller!),
    );
  }
}
