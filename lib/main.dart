import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:facemaskdetection/pages/home_page.dart';

List<CameraDescription> cameras;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(HomePage());
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //routes: {},
      home: Home(),
      theme: ThemeData(
        canvasColor: Color(0xFF61A4F1),
      ),
    );
  }
}
