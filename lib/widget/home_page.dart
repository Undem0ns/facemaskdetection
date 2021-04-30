import 'package:camera/camera.dart';
import 'package:facemaskdetection/model/model.dart';
import 'package:facemaskdetection/utility/style.dart';
import 'package:facemaskdetection/widget/detect_image.dart';
import 'package:facemaskdetection/widget/detect_on_camera.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;
  HomePage(this.cameras);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Model maskModel = Model();
  double screenWidth = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        decoration: Style().decoration(),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Style().titleH1('Face Mask Detector'),
                SizedBox(height: 50),
                Style().showLogo(screenWidth * 0.5, screenWidth * 0.5),
                SizedBox(height: 50),
                buildBotton('Detect On Image', DetectImage(maskModel)),
                SizedBox(height: 25),
                buildBotton('Detect On Camera', DetectOnCamera(widget.cameras)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container buildBotton(String text, var pageclass) {
    return Container(
      height: 100,
      width: screenWidth * 0.7,
      child: Style().button(() {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => pageclass));
      }, text),
    );
  }
}
