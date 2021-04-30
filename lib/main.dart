import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:facemaskdetection/widget/home_page.dart';

List<CameraDescription> cameras;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get camera detail from device.
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(cameras),
      debugShowCheckedModeBanner: false,
    );
  }
}
