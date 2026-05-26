import 'package:flutter/material.dart';
import 'package:sushi_restaurant/components/detail_page.dart';
import 'package:sushi_restaurant/pages/intro_page.dart';
import 'package:sushi_restaurant/pages/menu_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:  const IntroPage(),
      routes: {
        '/intro': (context) => const IntroPage(),
        '/menu' : (context) => const MenuPage(),
        '/detail': (context) => const DetailPage()
        ,
      },
    );
  }
}
