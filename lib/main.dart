import 'package:flutter/material.dart';
import 'package:motum_prototype/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Location Prototype',
      theme: ThemeData(
        primaryColor: Colors.blueAccent
      ),
      home: const Home(),
    );
  }

}
