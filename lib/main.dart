import 'package:flutter/material.dart';
import 'package:motum_prototype/pages/home.dart';
import 'package:motum_prototype/pages/profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});


  @override
  State<StatefulWidget> createState() => _MyAppState(); 
  }

class _MyAppState extends State<MyApp> {
    int _actualPage = 0;

  final List<Widget> _pages = [
    const Home(),
    const Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Location Prototype',
      theme: ThemeData(
        primaryColor: Colors.blueAccent
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Location Prototype'),
          backgroundColor: Colors.blueAccent,
        ),
        body: _pages[_actualPage],
        bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            setState(() {
              _actualPage = index;
            });
          },
          currentIndex: _actualPage,
          items: const <BottomNavigationBarItem> [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.supervisor_account), label: 'Perfil')
        ]
        ),
      ),
    );
  }
}
