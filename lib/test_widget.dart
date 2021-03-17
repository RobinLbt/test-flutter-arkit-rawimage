import 'package:flutter/material.dart';

class TestWidget extends StatefulWidget {
  TestWidget();

  final GlobalKey key = GlobalKey();

  GlobalKey getGlobalKey() {
    return key;
  }

  @override
  _TestWidgetState createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      color: Colors.red,
      child: Center(
        child: Text(
          'I\'m in the ARView !',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
