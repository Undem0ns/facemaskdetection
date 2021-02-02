import 'dart:io';

import 'package:facemaskdetection/utility/style.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class DetectImage extends StatefulWidget {
  @override
  _DetectImageState createState() => _DetectImageState();
}

class _DetectImageState extends State<DetectImage> {
  final ImagePicker imagepicker = ImagePicker();

  File imageFile;
  double screenHeight;
  double screenWidth;
  bool isImagePorcessing;
  bool showImage;
  List<Face> faces;
  img.Image image;

  @override
  void initState() {
    super.initState();
    isImagePorcessing = false;
    showImage = false;
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButton:
          isImagePorcessing ? Text('') : buildFloatingActionButton(),
      body: isImagePorcessing
          ? Container(
              decoration: Style().decoration(),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Style().titleH1('Processing....'),
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
                        ),
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

  SizedBox buildFloatingActionButton() {
    return SizedBox(
      width: screenWidth * 0.25,
      height: screenWidth * 0.25,
      child: FloatingActionButton(
        child: Icon(
          Icons.image_search,
          size: screenWidth * 0.15,
        ),
        onPressed: () async {
          final pickedFile =
              await imagepicker.getImage(source: ImageSource.gallery);
          if (pickedFile != null) {
            setState(() {
              imageFile = File(pickedFile.path);
              isImagePorcessing = true;
              print(isImagePorcessing);
            });
            final firebaseImage =
                FirebaseVisionImage.fromFilePath(imageFile.path);
            final faceDetector = FirebaseVision.instance.faceDetector();
            faces = await faceDetector.processImage(firebaseImage);
            setState(() {
              isImagePorcessing = false;
              showImage = true;
              print(isImagePorcessing);
              print(faces.first);
            });
          }
        },
        backgroundColor: Style().lighColor,
      ),
    );
  }
}
