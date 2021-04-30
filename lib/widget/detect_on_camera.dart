import 'dart:async';

import 'package:camera/camera.dart';
import 'package:facemaskdetection/model/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:facemaskdetection/utility/style.dart';

class DetectOnCamera extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Model maskModel;
  DetectOnCamera(this.cameras, this.maskModel);
  @override
  _DetectOnCameraState createState() => _DetectOnCameraState();
}

class _DetectOnCameraState extends State<DetectOnCamera> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  CameraController controller;
  bool isDetecting = false;
  List<dynamic> result;
  Size screenSize;
  Color svgColor;
  Iterator<CameraDescription> cameraDescription;
  CameraLensDirection direction = CameraLensDirection.back;
  FlutterTts textToSpeech;
  int currentResult;
  int selectedIndex = 0;
  bool enableVoiceEN = true;
  bool enableVoiceTH = true;
  bool showConfidence = true;
  bool showResultText = true;

  @override
  void initState() {
    super.initState();
    currentResult = 1;
    svgColor = Colors.black;
    textToSpeech = FlutterTts();
    initSwitchListTile();
    cameraDescription = widget.cameras.iterator;
    cameraDescription.moveNext();
    initNewCamera(cameraDescription);
  }

  switchCamera(Iterator cameraIterator) {
    // if .moveNext() return false mean cameraDescription is the last element.
    // set new cameraDescription and call .moveNext() to start over.
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
      setState(() {});
      controller.startImageStream((CameraImage cameraImage) {
        // Detect on camera image and wait to set recognition. Then detect again.
        if (!isDetecting) {
          isDetecting = true;
          widget.maskModel.predictOnCamera(cameraImage).then((recognitions) {
            setRecognitions(recognitions);
            isDetecting = false;
          });
        }
      });
    });
  }

  Future speakEnglish() async {
    if (enableVoiceEN) {
      textToSpeech.setLanguage('en');
      await textToSpeech.awaitSpeakCompletion(true);
      await textToSpeech.speak('Please wear a face mask.');
    }
  }

  Future speakThai() async {
    if (enableVoiceTH) {
      textToSpeech.setLanguage('th');
      await textToSpeech.awaitSpeakCompletion(true);
      await textToSpeech.speak('กรุณาสวมหน้ากากอนามัย');
    }
  }

  setRecognitions(recognitions) {
    if (recognitions.first["confidence"] >= 0.98) {
      setState(() {
        result = recognitions;
        if (result.first["index"] == 2) {
          if (result.first["index"] != currentResult) {
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
    super.dispose();
    textToSpeech.stop();
    controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return Scaffold(
      key: scaffoldKey,
      floatingActionButton: buildFloatingActionButton(
          onTab: () => switchCamera(cameraDescription)),
      bottomNavigationBar: buildBottomAppBar(),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      endDrawer: buildDrawer(),
      body: Stack(
        children: [
          Container(
            decoration: Style().decoration(),
          ),
          OverflowBox(
            minWidth: screenSize.width,
            child: CameraPreview(controller),
          ),
          Container(
              height: screenSize.height,
              width: screenSize.width,
              child: svgPicture('assets/image/rectangle.svg')),
          buildTextPreview(),
          buildTextConfident(),
        ],
      ),
    );
  }

  BottomAppBar buildBottomAppBar() {
    return BottomAppBar(
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
        onTap: bottomAppBarOnTap,
      ),
    );
  }

  Drawer buildDrawer() {
    return Drawer(
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
                setSwitchListTile('showResultText', value);
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
                  setSwitchListTile('enableVoiceEN', value);
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
                  setSwitchListTile('enableVoiceTH', value);
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
                  setSwitchListTile('showConfidence', value);
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
              height: screenSize.height * 0.1,
              width: screenSize.height * 0.1,
              child: Icon(
                icon,
                size: screenSize.width * 0.1,
              ),
            ),
            onTap: () => onTab(),
          ),
        ),
      ),
    );
  }

  SizedBox buildFloatingActionButton({@required Function onTab}) {
    return SizedBox(
      width: screenSize.width * 0.15,
      height: screenSize.width * 0.15,
      child: FloatingActionButton(
        child: Icon(
          Icons.switch_camera_outlined,
          size: screenSize.width * 0.1,
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
        center: Offset(screenSize.width / 2, screenSize.width / 2),
        width: screenSize.width * 0.6,
        height: screenSize.width * 0.6,
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
      currentResult = 2;
      speakEnglish().then((_) => speakThai());
    });
  }

  changeToMask() {
    setState(() {
      currentResult = 3;
    });
  }

  void bottomAppBarOnTap(int value) {
    // value == 1 => back to home.
    // value == 2 => open end drawer.
    setState(() {
      selectedIndex = value;
    });
    if (value == 0) {
      Navigator.of(context).pop();
    } else {
      scaffoldKey.currentState.openEndDrawer();
    }
  }

  setSwitchListTile(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
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

  void initSwitchListTile() {
    getSwitchListTile('enableVoiceEN').then((value) => enableVoiceEN = value);
    getSwitchListTile('enableVoiceTH').then((value) => enableVoiceTH = value);
    getSwitchListTile('showConfidence').then((value) => showConfidence = value);
    getSwitchListTile('showResultText').then((value) => showResultText = value);
  }
}
