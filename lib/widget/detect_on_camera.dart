import 'package:camera/camera.dart';
import 'package:facemaskdetection/service/utils.dart';
import 'package:facemaskdetection/utility/style.dart';
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
  Size screen;
  Color svgColor;
  Iterator<CameraDescription> cameraDescription;
  CameraLensDirection direction = CameraLensDirection.back;
  List<Face> faces;

  switchCamera(Iterator cameraIterator) {
    if (!cameraIterator.moveNext()) {
      cameraDescription = widget.cameras.iterator;
      cameraDescription.moveNext();
    }
    initNewCamera(cameraDescription);
  }

  initNewCamera(Iterator cameraIterator) async {
    CameraDescription description = await getCamera(direction);
    ImageRotation rotation = rotationIntToImageRotation(
      description.sensorOrientation,
    );

    controller = CameraController(
      cameraIterator.current,
      ResolutionPreset.medium,
    );
    await controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});

      controller.startImageStream((CameraImage img) {
        if (!isDetecting) {
          isDetecting = true;

          // detect(img, FirebaseVision.instance.faceDetector().processImage,
          //         rotation)
          //     .then(
          //   (dynamic result) {
          //     setState(() {
          //       faces = result;
          //     });
          //   },
          // );

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
    svgColor = Colors.black;
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
          model: "assets/model/masknew.tflite",
          labels: "assets/model/model.txt");
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
    screen = MediaQuery.of(context).size;
    return Scaffold(
      body: controller != null
          ? Stack(
              children: [
                OverflowBox(
                  // minHeight: screen.height,
                  minWidth: screen.width,
                  child: CameraPreview(controller),
                ),
                Container(
                    height: screen.height,
                    width: screen.width,
                    child: svgPicture('assets/image/test2.svg')),
                Text(result != null
                    ? result.map((e) => '${e["index"]}').first
                    : ''),
                Stack(
                  children: result != null ? _renderStrings() : [],
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  child: ClipOval(
                    child: Material(
                      color: Style().darkColor,
                      child: InkWell(
                        splashColor: Style().lighColor,
                        child: SizedBox(
                          height: screen.height * 0.1,
                          width: screen.height * 0.1,
                          child: Icon(Icons.switch_camera_outlined),
                        ),
                        onTap: () => switchCamera(cameraDescription),
                      ),
                    ),
                  ),
                )
              ],
            )
          : CircularProgressIndicator(),
    );
  }

  SvgPicture svgPicture(String assets) {
    return buildSvgPicture(
        result != null ? result.map((e) => '${e["index"]}').first : '', assets);
  }

  Widget buildCameraPreview() {
    if (controller != null) {
      return CameraPreview(controller);
    } else {
      return Text('');
    }
  }

  SvgPicture buildSvgPicture(String result, String assets) {
    if (result.isNotEmpty) {
      if (result == '0') {
        svgColor = Colors.green;
      } else if (result == '1') {
        svgColor = Colors.black;
      } else {
        svgColor = Colors.red;
      }
    }
    return SvgPicture.asset(
      assets,
      color: svgColor,
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
