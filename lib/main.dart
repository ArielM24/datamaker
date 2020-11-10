import 'package:flutter/material.dart';
import 'package:DataMaker/src/gui/mainView.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DataMaker',
      theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}
