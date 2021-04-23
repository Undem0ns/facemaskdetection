import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite/tflite.dart';

import 'package:facemaskdetection/service/utils.dart';
import 'package:facemaskdetection/utility/style.dart';

class DetectOnCamera extends StatefulWidget {
  final List<CameraDescription> cameras;
  DetectOnCamera(this.cameras);
  @override
  _DetectOnCameraState createState() => _DetectOnCameraState();
}

class _DetectOnCameraState extends State<DetectOnCamera> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  CameraController controller;
  bool isDetecting = false;
  List<dynamic> result;
  Size screen;
  Color svgColor;
  Iterator<CameraDescription> cameraDescription;
  CameraLensDirection direction = CameraLensDirection.back;
  FlutterTts flutterTts;
  int maskState;
  int selectedIndex = 0;
  bool enableVoiceEN;
  bool enableVoiceTH;
  bool showConfidence;
  bool showResultText;

  switchCamera(Iterator cameraIterator) {
    if (!cameraIterator.moveNext()) {
      cameraDescription = widget.cameras.iterator;
      cameraDescription.moveNext();
    }
    initNewCamera(cameraDescription);
  }

  initNewCamera(Iterator cameraIterator) async {
    controller = CameraController(
      cameraIterator.current,
      ResolutionPreset.low,
      enableAudio: false,
    );
    await controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});

      controller.startImageStream((CameraImage img) {
        if (!isDetecting) {
          isDetecting = true;
          Tflite.runModelOnFrame(
            bytesList: img.planes.map((plane) {
              return plane.bytes;
            }).toList(),
            imageHeight: img.height,
            imageWidth: img.width,
            numResults: 3,
          ).then((recognitions) {
            setRecognitions(recognitions);
            isDetecting = false;
          });
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    maskState = 1;
    svgColor = Colors.black;
    isDetecting = true;
    cameraDescription = widget.cameras.iterator;
    flutterTts = FlutterTts();
    getSwitchListTile('enableVoiceEN').then((value) => enableVoiceEN = value);
    getSwitchListTile('enableVoiceTH').then((value) => enableVoiceTH = value);
    getSwitchListTile('showConfidence').then((value) => showConfidence = value);
    getSwitchListTile('showResultText').then((value) => showResultText = value);
    loadModel().then((val) {
      setState(() {
        isDetecting = false;
      });
    });
    cameraDescription.moveNext();
    initNewCamera(cameraDescription);
  }

  Future loadModel() async {
    Tflite.close();
    try {
      String res = await Tflite.loadModel(
          model: "assets/model/masknew.tflite",
          labels: "assets/model/model.txt");
      print('loadModel $res');
    } on PlatformException {
      print('Failed to load model.');
    }
  }

  Future _speak() async {
    if (enableVoiceEN) {
      flutterTts.setLanguage('en');
      await flutterTts.awaitSpeakCompletion(true);
      await flutterTts.speak('Please wear a face mask.');
    }
  }

  Future speakThai() async {
    if (enableVoiceTH) {
      flutterTts.setLanguage('th');
      await flutterTts.awaitSpeakCompletion(true);
      await flutterTts.speak('กรุณาสวมหน้ากากอนามัย');
    }
  }

  setRecognitions(recognitions) {
    if (recognitions.first["confidence"] >= 0.98) {
      setState(() {
        result = recognitions;
        if (result.first["index"] == 2) {
          if (result.first["index"] != maskState) {
            changeToNoMask();
          }
        } else {
          changeToMask();
        }
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: buildFloatingActionButton(
        () => switchCamera(cameraDescription),
      ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 10,
        shape: CircularNotchedRectangle(),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Setting",
            ),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: Style().primaryColor,
          unselectedItemColor: Colors.black,
          onTap: itenOnTap,
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      endDrawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeArea(child: Container()),
              Card(
                  child: Center(
                child: Style().titleH1('Setting'),
              )),
              Card(
                  child: SwitchListTile(
                value: showResultText,
                onChanged: (bool value) {
                  changeSwitchListTile('showResultText', value);
                  setState(() {
                    showResultText = value;
                  });
                },
                title: Style().titleH3('Show result text'),
                secondary: Icon(Icons.format_color_text),
              )),
              Card(
                child: SwitchListTile(
                  value: enableVoiceEN,
                  onChanged: (bool value) {
                    changeSwitchListTile('enableVoiceEN', value);
                    setState(() {
                      enableVoiceEN = value;
                    });
                  },
                  title: Style().titleH3('Enable voice EN'),
                  secondary: Icon(Icons.record_voice_over_outlined),
                ),
              ),
              Card(
                child: SwitchListTile(
                  value: enableVoiceTH,
                  onChanged: (bool value) {
                    changeSwitchListTile('enableVoiceTH', value);
                    setState(() {
                      enableVoiceTH = value;
                    });
                  },
                  title: Style().titleH3('Enable voice TH'),
                  secondary: Icon(Icons.record_voice_over),
                ),
              ),
              Card(
                child: SwitchListTile(
                  value: showConfidence,
                  onChanged: (bool value) {
                    changeSwitchListTile('showConfidence', value);
                    setState(() {
                      showConfidence = value;
                    });
                  },
                  title: Style().titleH3('Show confidence'),
                  secondary: Icon(Icons.person_search_outlined),
                ),
              ),
            ],
          ),
        ),
        // child: Container(
        //   decoration: Style().decoration(),
        //   child: Column(
        //     children: [
        //       Container(
        //         child: SafeArea(child: Style().titleH1('Settings')),
        //         height: screen.height * 0.1,
        //       ),
        //       Text('data'),
        //       Text('data'),
        //       Text('data'),
        //       Text('data'),
        //     ],
        //   ),
        // ),
      ),
      body: controller != null
          ? Stack(
              children: [
                Container(
                  decoration: Style().decoration(),
                ),
                OverflowBox(
                  // minHeight: screen.height,
                  minWidth: screen.width,
                  child: CameraPreview(controller),
                ),
                Container(
                    height: screen.height,
                    width: screen.width,
                    child: svgPicture('assets/image/test2.svg')),
                buildTextPreview(),
                buildTextConfident(),
                // buildButton(
                //   Alignment.bottomRight,
                //   Style().darkColor,
                //   Style().lighColor,
                //   Icons.switch_camera_outlined,
                //   () => switchCamera(cameraDescription),
                // ),

                // ElevatedButton(
                //   onPressed: () => _speak(),
                //   child: Icon(Icons.adb_sharp),
                // ),
              ],
            )
          : CircularProgressIndicator(),
    );
  }

  Container buildButton(
    AlignmentGeometry location,
    Color color,
    Color splashColor,
    IconData icon,
    Function onTab,
  ) {
    return Container(
      alignment: location,
      child: ClipOval(
        child: Material(
          color: color,
          child: InkWell(
            splashColor: splashColor,
            child: SizedBox(
              height: screen.height * 0.1,
              width: screen.height * 0.1,
              child: Icon(
                icon,
                size: screen.width * 0.1,
              ),
            ),
            onTap: () => onTab(),
          ),
        ),
      ),
    );
  }

  SizedBox buildFloatingActionButton(
    Function onTab,
  ) {
    return SizedBox(
      width: screen.width * 0.15,
      height: screen.width * 0.15,
      child: FloatingActionButton(
        child: Icon(
          Icons.switch_camera_outlined,
          size: screen.width * 0.1,
        ),
        onPressed: onTab,
        backgroundColor: Style().lighColor,
      ),
    );
  }

  Widget buildTextPreview() {
    String res = '';
    if (result != null && showResultText) {
      if (result.first["index"] == 1) {
        res = 'No Face Found\nScanning...';
      } else {
        if (result.first["index"] == 0) {
          res = 'Face Scan Result\nMask wearing';
        } else {
          res = 'Face Scan Result\nNot wearing mask';
        }
      }
    } else {
      res = '';
    }
    return buildTextResult(res);
  }

  Widget buildTextResult(String text) {
    return Positioned.fromRect(
      rect: Rect.fromCenter(
        center: Offset(screen.width / 2, screen.width / 2),
        width: screen.width * 0.6,
        height: screen.width * 0.6,
      ),
      child: Text(
        text,
        style: TextStyle(
            color: svgColor,
            fontSize: 30,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, blurRadius: 2)],
            wordSpacing: 1),
      ),
    );
  }

  Widget buildTextConfident() {
    if (result != null && showConfidence) {
      return Positioned(
        bottom: 3,
        child: (result.first["index"] != 1)
            ? Text(
                '${(result.first["confidence"] * 100).toStringAsFixed(2)}%',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                    wordSpacing: 1),
              )
            : Text(''),
      );
    } else {
      return Text('');
    }
  }

  SvgPicture svgPicture(String assets) {
    return buildSvgPicture(
        result != null ? result.map((e) => '${e["index"]}').first : '', assets);
  }

  Widget buildCameraPreview() {
    if (controller != null) {
      return CameraPreview(controller);
    } else {
      return Text('');
    }
  }

  SvgPicture buildSvgPicture(String result, String assets) {
    if (result.isNotEmpty) {
      if (result == '0') {
        svgColor = Colors.green;
      } else if (result == '1') {
        svgColor = Colors.black;
      } else {
        svgColor = Colors.red;
      }
    }
    return SvgPicture.asset(
      assets,
      color: svgColor,
    );
  }

  changeToNoMask() async {
    setState(() {
      maskState = 2;
      _speak().then((value) => speakThai());
    });
  }

  changeToMask() {
    setState(() {
      maskState = 3;
    });
  }

  void itenOnTap(int value) {
    // Scaffold.of(context).openDrawer();
    setState(() {
      selectedIndex = value;
    });
    if (value == 0) {
      Navigator.of(context).pop();
    } else {
      _scaffoldKey.currentState.openEndDrawer();
    }
  }

  // saveValue(String key, String value) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setString(key, value);
  // }

  // getValue(String key) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   //Return String
  //   String stringValue = prefs.getString(key);
  //   return stringValue;
  // }
  //
  changeSwitchListTile(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // bool value = (prefs.getBool(key) ?? false);
    print('value is : $value');
    await prefs.setBool(key, value);
    print('getBool : ${prefs.getBool(key)}');
  }

  Future getSwitchListTile(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool value = (prefs.getBool(key) ?? false);
    print('value is : $value');
    return value;
  }
}
