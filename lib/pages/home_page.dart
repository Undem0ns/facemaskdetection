import 'package:facemaskdetection/pages/predict_image_page.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

Widget _drawer() {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/image/upload.png',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Text(''),
          padding: EdgeInsets.all(8),
        ),
        ListTile(
          leading: Icon(Icons.message),
          title: Text('Messages'),
        ),
        ListTile(
          leading: Icon(Icons.account_circle),
          title: Text('Profile'),
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
        ),
      ],
    ),
  );
}

class _HomeState extends State<Home> {
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
                onPressed: () {},
                child: Text(
                  'Upload Video',
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
        drawer: _drawer(),
      ),
    );
  }
}
