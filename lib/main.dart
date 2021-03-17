import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import 'package:rawimage/test_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<TestWidget> _testWidgets = [];
  List<ARKitNode> _nodes = [];
  ARKitController arKitController;

  @override
  void dispose() {
    arKitController?.dispose();
    super.dispose();
  }

  void _onArKitViewCreated(ARKitController controller) {
    arKitController = controller;
    Future.delayed(Duration(seconds: 2), () => addObjectsAround());
  }

  Future<void> addObjectsAround() async {
    var cameraPose = await arKitController.getCameraEulerAngles();

    _testWidgets.add(TestWidget());

    setState(() {});

    // Wait for render
    Future.delayed(
        Duration(milliseconds: 1000),
        () async => await Future.forEach(_testWidgets, (element) async {
              await _addWidgetNodeARView(
                element.getGlobalKey(),
                vector.Vector3(-0.1, -0.1, -0.5),
              );
            }).then((_) {
              _nodes.forEach((node) async {
                await arKitController.add(node);
              });
            }));
  }

  // Ajoute le widget en image bytes à la liste de ArCoreNodes
  Future<void> _addWidgetNodeARView(
      GlobalKey gKey, vector.Vector3 position) async {
    final image = await _widgetToBytes(gKey);

    final material = ARKitMaterial(
      lightingModelName: ARKitLightingModel.lambert,
      diffuse: ARKitMaterialProperty(
        //image: image,
        rawImage: ARKitMaterialPropertyImage(0, 0, image),
      ),
    );
    final plane = ARKitPlane(
      materials: [material],
    );

    final node = ARKitNode(
      name: UniqueKey().toString(),
      geometry: plane,
      position: position,
      scale: vector.Vector3(10, 10, 10),
    );
    _nodes.add(node);
  }

  //Converti un widget en image bytes utilisable par ARCore
  Future<dynamic> _widgetToBytes(GlobalKey gKey) async {
    if (gKey == null) return null;
    RenderRepaintBoundary boundary = gKey.currentContext.findRenderObject();
    if (foundation.kDebugMode) if (boundary.debugNeedsPaint) {
      await Future.delayed(const Duration(milliseconds: 20));
      return _widgetToBytes(gKey);
    }
    var image = await boundary.toImage(pixelRatio: 1);
    ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    //? Remove comment and return img64 to test base64 image (it works)
    //String img64 = base64Encode(pngBytes);
    List<int> list = new List.from(pngBytes);
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test rawImage ARKit plugin'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            ..._testWidgets,
            ARKitSceneView(
              onARKitViewCreated: _onArKitViewCreated,
            ),
          ],
        ),
      ),
    );
  }
}
