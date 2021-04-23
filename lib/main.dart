import 'package:camera/camera.dart';
import 'package:facemaskdetection/route.dart';
import 'package:facemaskdetection/widget/home_page.dart';
import 'package:flutter/material.dart';

List<CameraDescription> cameras;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  getCamera() {
    return cameras;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: routes,
      home: HomePage(cameras), debugShowCheckedModeBanner: false,
    );
  }
}
