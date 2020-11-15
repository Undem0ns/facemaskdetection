import 'package:flutter/material.dart';
import 'package:facemaskdetection/pages/home_page.dart';

void main() {
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
