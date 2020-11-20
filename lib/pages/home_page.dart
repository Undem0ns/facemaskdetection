import 'package:facemaskdetection/pages/predict_image_page.dart';
import 'package:facemaskdetection/pages/predict_on_video.dart';
import 'package:facemaskdetection/service/utils.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  CameraLensDirection _direction = CameraLensDirection.front;
  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  _initCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
    CameraDescription description = await getCamera(_direction);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF73AEF5), Color(0xFF398AE5), Colors.blue],
                ),
              ),
            ),
            Container(
              height: 70,
              width: 300,
              margin: EdgeInsets.fromLTRB(30, 560, 30, 0),
              child: RaisedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PredictImage())),
                //pickImage
                child: Text(
                  'Detect On Image',
                  style: TextStyle(
                    fontSize: 24,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
            Container(
              height: 70,
              width: 300,
              margin: EdgeInsets.fromLTRB(30, 470, 30, 0),
              child: RaisedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PredictVideo())),
                child: Text(
                  'Detect On Video',
                  style: TextStyle(
                    fontSize: 24,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
            Container(
              height: 250,
              width: 250,
              margin: EdgeInsets.fromLTRB(0, 150, 0, 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 1000,
                  )
                ],
                image: DecorationImage(
                  image: AssetImage(
                    'assets/image/maskface.png',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              height: 50,
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(0, 70, 0, 0),
              child: FlatButton(
                onPressed: () {},
                color: Colors.white70,
                child: Text(
                  'Face Mask Detector',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
        //drawer: _drawer(),
      ),
    );
  }
}
