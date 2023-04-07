import 'package:flutter/material.dart';
import 'package:motum_prototype/pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});


  @override
  State<StatefulWidget> createState() => _MyAppState(); 
  }

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Location Prototype',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Location Prototype'),
          centerTitle: true,
        ),
        body: const Home(),
      ),
    );
  }
}
