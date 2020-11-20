import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras;

class PredictVideo extends StatefulWidget {
  @override
  _PredictVideoState createState() => _PredictVideoState();
}

class _PredictVideoState extends State<PredictVideo> {
  CameraLensDirection _direction = CameraLensDirection.front;
  CameraController cameraController;
  @override
  void initState() {
    super.initState();
    cameraController =
        CameraController(cameras.first, ResolutionPreset.ultraHigh);
    cameraController.initialize().then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!cameraController.value.isInitialized) {
      return Container();
    }
    return AspectRatio(
      aspectRatio: cameraController.value.aspectRatio,
      child: CameraPreview(cameraController),
    );
  }
}
