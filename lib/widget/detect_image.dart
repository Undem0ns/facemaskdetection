import 'dart:io';

import 'package:facemaskdetection/utility/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class DetectImage extends StatefulWidget {
  @override
  _DetectImageState createState() => _DetectImageState();
}

class _DetectImageState extends State<DetectImage> {
  final ImagePicker imagepicker = ImagePicker();
  File imageFile;
  double screenHeight;
  double screenWidth;
  bool loadModelError;
  bool showImage;
  int imageW;
  List<dynamic> result;

  @override
  void initState() {
    super.initState();
    loadModelError = false;
    showImage = false;
    loadModel();
  }

  Future loadModel() async {
    Tflite.close();
    try {
      String res = await Tflite.loadModel(
          model: "assets/model/masknew.tflite",
          labels: "assets/model/model.txt");
      print('loadModel $res');
    } on PlatformException {
      print('Failed to load model.');
      setState(() {
        loadModelError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButton:
          loadModelError ? Text('') : buildFloatingActionButton(),
      body: loadModelError
          ? Container(
              decoration: Style().decoration(),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Style().titleH1('Model can not load'),
                    Style().titleH1('Please restart application'),
                    SizedBox(
                      height: 20,
                    ),
                    CircularProgressIndicator(
                      backgroundColor: Colors.black,
                    ),
                  ],
                ),
              ),
            )
          : showImage
              ? Container(
                  decoration: Style().decoration(),
                  child: Center(
                    child: Column(
                      children: [
                        Style().showImage(
                          screenWidth,
                          screenHeight * 0.5,
                          imageFile,
                          imageW,
                        ),
                        SizedBox(
                          height: screenHeight * 0.05,
                        ),
                        Container(child: Style().titleH1("Face Mask Result")),
                        buildResult(),
                      ],
                    ),
                  ),
                )
              : Container(
                  decoration: Style().decoration(),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Style().titleH1('Tap To'),
                        Style().titleH1('Select Image'),
                        Style().titleH1('Below'),
                      ],
                    ),
                  ),
                ),
    );
  }

  Column buildResult() {
    if (result != null) {
      // if (result.first["index"] == 2) {
      //   return Column(
      //     children: [
      //       Icon(
      //         Icons.do_disturb_on_rounded,
      //         size: screenHeight * 0.2,
      //         color: Colors.red,
      //       ),
      //       Style().titleH1("Not wearing mask"),
      //       Style().titleH1(
      //           '${(result.first["confidence"] * 100).toStringAsFixed(0)}%'),
      //     ],
      //   );
      // } else if ((result.first["index"] == 1)) {
      //   return Column(
      //     children: [
      //       Icon(
      //         Icons.info,
      //         size: screenHeight * 0.2,
      //         color: Colors.yellow,
      //       ),
      //       Style().titleH1("No face found"),
      //     ],
      //   );
      // } else {
      //   return Column(
      //     children: [
      //       Icon(
      //         Icons.assignment_turned_in_rounded,
      //         size: screenHeight * 0.2,
      //         color: Colors.greenAccent[400],
      //       ),
      //       Style().titleH1("Wearing face mask"),
      //       Style().titleH1(
      //           '${(result.first["confidence"] * 100).toStringAsFixed(0)}%'),
      //     ],
      //   );
      // }
      if (result.first["index"] == 2) {
        return Column(
          children: [
            Icon(
              Icons.do_disturb_on_rounded,
              size: screenHeight * 0.2,
              color: Colors.red,
            ),
            Style().titleH1("Not wearing mask"),
            Style().titleH1(
                '${(result.first["confidence"] * 100).toStringAsFixed(0)}%'),
          ],
        );
      } else if ((result.first["index"] == 1)) {
        return Column(
          children: [
            Icon(
              Icons.info,
              size: screenHeight * 0.2,
              color: Colors.yellow,
            ),
            Style().titleH1("No face found"),
          ],
        );
      } else {
        return Column(
          children: [
            Icon(
              Icons.assignment_turned_in_rounded,
              size: screenHeight * 0.2,
              color: Colors.greenAccent[400],
            ),
            Style().titleH1("Wearing face mask"),
            Style().titleH1(
                '${(result.first["confidence"] * 100).toStringAsFixed(0)}%'),
          ],
        );
      }
    } else {
      return Column();
    }
  }

  SizedBox buildFloatingActionButton() {
    return SizedBox(
      width: screenWidth * 0.15,
      height: screenWidth * 0.15,
      child: FloatingActionButton(
        child: Icon(
          Icons.image_search,
          size: screenWidth * 0.1,
        ),
        onPressed: pickImage,
        backgroundColor: Style().lighColor,
      ),
    );
  }

  void pickImage() async {
    final pickedFile = await imagepicker.getImage(
      source: ImageSource.gallery,
      maxHeight: screenHeight / 2,
      maxWidth: screenWidth,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
        showImage = true;
      });
      Tflite.runModelOnImage(
        path: imageFile.path,
        numResults: 3,
        imageMean: 127.5,
        imageStd: 127.5,
      ).then((recognitions) => setRecognitions(recognitions));
    }
  }

  setRecognitions(recognitions) {
    setState(() {
      result = recognitions;
    });
  }
}
