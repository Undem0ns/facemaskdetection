import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';

class Model {
  bool canLoadModel = true;
  Model() {
    loadModel();
  }

  loadModel() async {
    Tflite.close();
    try {
      String res = await Tflite.loadModel(
          model: "assets/model/masknew.tflite",
          labels: "assets/model/model.txt");

      print('loadModel $res');
    } on PlatformException {
      this.canLoadModel = false;
      print('Failed to load model.');
    }
  }

  Future predictOnImage(String path) {
    var result = Tflite.runModelOnImage(
      path: path,
      numResults: 3,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    return result;
  }
}
