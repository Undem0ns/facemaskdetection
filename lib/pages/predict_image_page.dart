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
      double x, y, w, h;
      x = rectangle.left;
      y = rectangle.top;
      w = rectangle.width;
      h = rectangle.height;
      //print(rawimage.width);
      //print(_image.height);
      //print(rectangle.toString());
      print(x);
      print(y);
      print(w); //right
      print(h); //botton
      await faceimage.add(
          img.copyCrop(rawimage, x.round(), y.round(), w.round(), h.round()));
      //faceimage.add(img.copyResizeCropSquare(rawimage, 200));
      //print('Width : ' + faceimage.toString());
      //print('Heigth : ' + faceimage.first.height.toString());
      //print('\n');

    }
  }

  // Future recognizeImageBinary(File image) async {
  //   int startTime = new DateTime.now().millisecondsSinceEpoch;
  //   //var imageBytes = (await rootBundle.load(image.path)).buffer;
  //   //img.Image oriImage = img.decodeJpg(imageBytes.asUint8List());
  //   img.Image resizedImage = img.copyResize(oriImage, height: 224, width: 224);
  //   var recognitions = await Tflite.runModelOnBinary(
  //     binary: imageToByteListFloat32(resizedImage, 224, 127.5, 127.5),
  //     numResults: 6,
  //     threshold: 0.05,
  //   );
  //   setState(() {
  //     _recognitions = recognitions;
  //   });
  //   int endTime = new DateTime.now().millisecondsSinceEpoch;
  //   print("Inference took ${endTime - startTime}ms");
  // }

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
                  child: Column(
                    children: [
                      FittedBox(
                        child: SizedBox(
                          width: _image.width.toDouble(),
                          height: _image.height.toDouble(),
                          child: CustomPaint(
                            painter: FacePainter(_image, _faces),
                          ),
                        ),
                      ),
                      FittedBox(
                        child: SizedBox(
                          width: _image.width.toDouble(),
                          height: _image.height.toDouble(),
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(
                                  _imageFile,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImageAndDetectFaces,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
