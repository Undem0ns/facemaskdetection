import 'package:facemaskdetection/utility/style.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  double screen;

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        decoration: buildBoxDecoration(),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Style().titleH1('Face Mask Detector'),
                SizedBox(height: 70),
                Style().showLogo(screen * 0.5, screen * 0.5),
                SizedBox(height: 100),
                buildButton()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row buildButton() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          child: ElevatedButton(
            onPressed: () {},
            child: Style().titleH2('Detect On Image'),
            style: ElevatedButton.styleFrom(
              primary: Style().buttonlighColor,
              elevation: 20,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          height: 100,
          width: screen * 0.7,
        ),
      ],
    );
  }

  BoxDecoration buildBoxDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Style().lighColor,
          Style().primaryColor,
          Style().darkColor,
        ],
      ),
    );
  }
}
