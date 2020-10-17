import 'package:flutter/material.dart';
import 'package:DataMaker/src/gui/mainView.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DataMaker 0.5',
      theme: ThemeData.dark().copyWith(
          textTheme: TextTheme(headline6: TextStyle(color: Colors.black87))),
      home: homePage(),
    );
  }
}
