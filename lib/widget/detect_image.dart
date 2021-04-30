import 'dart:io';

import 'package:facemaskdetection/model/model.dart';
import 'package:facemaskdetection/utility/style.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DetectImage extends StatefulWidget {
  final Model maskModel;

  const DetectImage(this.maskModel);
  @override
  _DetectImageState createState() => _DetectImageState();
}

class _DetectImageState extends State<DetectImage> {
  List<Widget> faceMaskResult = [];
  final ImagePicker imagepicker = ImagePicker();
  File imageFile;
  double screenHeight;
  double screenWidth;
  bool imagePicked = false;
  List<dynamic> result;

  @override
  void initState() {
    super.initState();
    createFaceMaskResult();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    if (widget.maskModel.canLoadModel) {
      return buildModelCanLoadScaffold();
    } else {
      return buildModelCanNotLoadScaffold();
    }
  }

  Scaffold buildModelCanLoadScaffold() {
    return Scaffold(
      floatingActionButton: buildFloatingActionButton(),
      body: imagePicked ? buildImagePicked() : buildImageNotPick(),
    );
  }

  Scaffold buildModelCanNotLoadScaffold() {
    return Scaffold(
      body: Container(
        decoration: Style().decoration(),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Style().titleH1('Model can not load'),
              Style().titleH1('Please restart application'),
              CircularProgressIndicator(
                backgroundColor: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildImagePicked() {
    return SingleChildScrollView(
      child: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: Style().decoration(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // show selected image.
              showImage(),
              // show result icon&text.
              faceMaskResult[result.first["index"]],
              // show confidence.
              Style().titleH2(
                  'Confidence : ${(result.first["confidence"] * 100).toStringAsFixed(2)}%'),
            ],
          ),
        ),
      ),
    );
  }

  Container showImage() {
    return Container(
      width: screenWidth,
      height: screenHeight * 0.5,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: FileImage(imageFile),
          alignment: Alignment.center,
        ),
      ),
    );
  }

  Widget buildImageNotPick() {
    return Container(
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
    );
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
      imageQuality: 30,
    );
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      imagePicked = true;
      // Call Model() to predict Image.
      widget.maskModel.predictOnImage(imageFile.path).then((result) {
        setState(() {
          this.result = result;
        });
        print('result ${this.result}');
      });
    }
  }

  void createFaceMaskResult() {
    setState(() {
      faceMaskResult.add(buildResult(
        Icons.assignment_turned_in_rounded,
        Colors.greenAccent[400],
        "Wearing face mask.",
      ));
      faceMaskResult.add(buildResult(
        Icons.info,
        Colors.yellowAccent[400],
        "No face found.",
      ));
      faceMaskResult.add(buildResult(
        Icons.do_disturb_on_rounded,
        Colors.redAccent[400],
        "Not wearing mask.",
      ));
    });
  }

  Widget buildResult(
    IconData icon,
    Color color,
    String text,
  ) {
    return Column(
      children: [
        Style().titleH1("Face Mask Result"),
        Icon(icon, size: 100, color: color),
        Style().titleH1(text),
      ],
    );
  }
}
