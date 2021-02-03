import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:tflite/tflite.dart';

class DetectOnCamera extends StatefulWidget {
  final List<CameraDescription> cameras;
  DetectOnCamera(this.cameras);
  @override
  _DetectOnCameraState createState() => _DetectOnCameraState();
}

class _DetectOnCameraState extends State<DetectOnCamera> {
  CameraController controller;
  bool isDetecting = false;
  List<dynamic> result;
  double screen;
  Iterator<CameraDescription> cameraDescription;

  switchCamera(Iterator cameraIterator) {
    if (!cameraIterator.moveNext()) {
      cameraDescription = widget.cameras.iterator;
      cameraDescription.moveNext();
    }
    initNewCamera(cameraDescription);
  }

  initNewCamera(Iterator cameraIterator) {
    controller = CameraController(
      cameraIterator.current,
      ResolutionPreset.medium,
    );
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});

      controller.startImageStream((CameraImage img) {
        if (!isDetecting) {
          isDetecting = true;

          Tflite.runModelOnFrame(
            bytesList: img.planes.map((plane) {
              return plane.bytes;
            }).toList(),
            imageHeight: img.height,
            imageWidth: img.width,
            numResults: 2,
          ).then((recognitions) {
            setRecognitions(recognitions);
            isDetecting = false;
          });
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();

    isDetecting = true;
    cameraDescription = widget.cameras.iterator;

    loadModel().then((val) {
      setState(() {
        isDetecting = false;
      });
    });
    cameraDescription.moveNext();
    initNewCamera(cameraDescription);
  }

  Future loadModel() async {
    Tflite.close();
    try {
      String res = await Tflite.loadModel(
          model: "assets/model/model.tflite", labels: "assets/model/model.txt");
      print('loadModel result : $res');
    } on PlatformException {
      print('Failed to load model.');
    }
  }

  setRecognitions(recognitions) {
    setState(() {
      result = recognitions;
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    if (!controller.value.isInitialized) {
      return Container();
    }
    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller.value.previewSize;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return Scaffold(
      body: Stack(
        children: [
          OverflowBox(
            maxHeight: screenRatio > previewRatio
                ? screenH
                : screenW / previewW * previewH,
            maxWidth: screenRatio > previewRatio
                ? screenH / previewH * previewW
                : screenW,
            child: CameraPreview(controller),
          ),
          Container(
            child: SvgPicture.asset(
              'assets/image/test2.svg',
              color: Colors.red,
            ),
          ),
          Stack(
            children: result != null ? _renderStrings() : [],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => switchCamera(cameraDescription),
        child: Icon(Icons.flip_camera_android),
      ),
    );
  }

  List<Widget> _renderStrings() {
    double offset = -10;
    return result.map((re) {
      offset = offset + 14;
      return Positioned(
        left: 50,
        top: offset,
        child: Text(
          "${re["label"]} ${(re["confidence"] * 100).toStringAsFixed(0)}%",
          style: TextStyle(
            color: Color.fromRGBO(37, 213, 253, 1.0),
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }).toList();
  }
}
