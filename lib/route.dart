import 'package:camera/camera.dart';
import 'package:facemaskdetection/main.dart';
import 'package:facemaskdetection/widget/detect_image.dart';
import 'package:facemaskdetection/widget/detect_on_camera.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> routes = {
  '/detectimage': (BuildContext context) => DetectImage(),
  // '/detectoncamera': (BuildContext context) =>
  //     DetectOnCamera(MyApp().getCamera()),
};
