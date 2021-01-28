import 'dart:io';

import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image_picker/image_picker.dart';

import 'package:facemaskdetection/service/painter.dart';

class PredictImage extends StatefulWidget {
  @override
  _PredictImageState createState() => _PredictImageState();
}

class _PredictImageState extends State<PredictImage> {
  File _imageFile;
  List<Face> _faces;
  bool isLoading = false;
  ui.Image _image;
  img.Image rawimage;
  List<img.Image> _faceimage;
  List<Rect> rec;

  _getImageAndDetectFaces() async {
    final imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      isLoading = true;
    });
    final image = FirebaseVisionImage.fromFile(imageFile);
    final faceDetector = FirebaseVision.instance.faceDetector();
    List<Face> faces = await faceDetector.processImage(image);
    if (mounted) {
      setState(() {
        _imageFile = imageFile;
        _faces = faces;
        _loadImage(imageFile);
      });
    }
  }

  prepareFaceImage(File file) async {
    rec = FacePainter(_image, _faces).getListRects();
    final data = await file.readAsBytes();
    List<img.Image> faceimage = [];
    rawimage = img.Image.fromBytes(_image.width, _image.height, data);
    print('width ' + rawimage.width.toString());
    print('height ' + rawimage.height.toString());
    for (Rect rectangle in rec) {
      int x, y, w, h;
      x = rectangle.left.toInt();
      y = rectangle.top.toInt();
      w = rectangle.width.toInt();
      h = rectangle.height.toInt();
      //print(rawimage.width);
      //print(_image.height);
      //print(rectangle.toString());
      print(x);
      print(y);
      print('width ' + w.toString()); //right
      print('height ' + h.toString());
      print(rectangle.bottomRight); //botton
      print(rectangle.topLeft);
      // faceimage.add(img.copyCrop(rawimage, 0, 0, 50, 50));
    }
  }

  _loadImage(File file) async {
    final data = await file.readAsBytes();
    await decodeImageFromList(data).then(
      (value) => setState(() {
        _image = value;
        prepareFaceImage(file);
        isLoading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : (_imageFile == null)
              ? Center(child: Text('No image selected'))
              : Center(
                  child: FittedBox(
                    child: SizedBox(
                      width: _image.width.toDouble(),
                      height: _image.height.toDouble(),
                      child: CustomPaint(
                        painter: FacePainter(_image, _faces),
                      ),
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImageAndDetectFaces,
        tooltip: 'Pick Image',
        child: Icon(Icons.image),
      ),
    );
  }
}
