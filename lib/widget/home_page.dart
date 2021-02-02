import 'package:camera/camera.dart';
import 'package:facemaskdetection/utility/style.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  HomePage(this.cameras);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double screen;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
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
                Style().showLogo(screen * 0.5, screen * 0.5),
                SizedBox(height: 50),
                buildBotton('Detect On Image', '/detectimage'),
                SizedBox(height: 25),
                buildBotton('Detect On Camera', '/detectoncamera'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container buildBotton(String text, String route) {
    return Container(
      height: 100,
      width: screen * 0.7,
      child: Style().button(() {
        Navigator.pushNamed(context, route);
      }, text),
    );
  }
}
