import 'package:flutter/material.dart';
import 'package:kototinder/screens/home_screen.dart';
import 'package:kototinder/screens/detail_screen.dart';

void main() {
  runApp(const KototinderApp());
}

class KototinderApp extends StatelessWidget {
  const KototinderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Кототиндер',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      routes: {
        '/': (context) => const HomeScreen(),
        '/detail': (context) => const DetailScreen(),
      },
    );
  }
}
