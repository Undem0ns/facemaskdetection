import 'package:facemaskdetection/pages/home_page.dart';
import 'package:facemaskdetection/widget/mainpage.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> routes = {
  '/home': (BuildContext context) => Home(),
  '/mainpage': (BuildContext context) => MainPage(),
};
