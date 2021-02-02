import 'dart:io';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
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

  Widget showImage(double width, double height, File file) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: FileImage(file),
            fit: BoxFit.cover,
          ),
        ),
      );

  // Widget showImageCrop(double width, double height, File file, Rect rect) {
  //   // cropImage = img.copyCrop(imgImage, x, y, w, h)
  //   return Container(
  //     child: Column(
  //       children: [],
  //     ),
  //     width: width,
  //     height: height,
  //     decoration: BoxDecoration(
  //       image: DecorationImage(
  //         image: FileImage(file),
  //         fit: BoxFit.cover,
  //       ),
  //     ),
  //   );
  // }

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

  Widget button(Function navigation, String string) => ElevatedButton(
        onPressed: navigation,
        child: Style().titleH2(string),
        style: ElevatedButton.styleFrom(
          primary: Style().buttonlighColor,
          elevation: 20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );

  Decoration decoration() => BoxDecoration(
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

  Style();
}
