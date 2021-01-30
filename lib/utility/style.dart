import 'package:flutter/material.dart';

class Style {
  Color darkColor = Colors.blue[800];
  Color primaryColor = Colors.blue;
  Color lighColor = Colors.blue[300];
  Color buttonlighColor = Colors.blue[100];

  Widget showLogo(double width, double height) => Container(
        width: width,
        height: height,
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
      );

  Widget titleH1(String string) => Text(
        string,
        style: TextStyle(
          color: Colors.black,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget titleH2(String string) => Text(
        string,
        style: TextStyle(
          color: Colors.black,
          fontSize: 26,
          fontWeight: FontWeight.w500,
        ),
      );

  Widget titleH3(String string) => Text(
        string,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          // fontWeight: FontWeight.bold,
        ),
      );

  Style();
}
