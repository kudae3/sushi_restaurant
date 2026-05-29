import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sushi_restaurant/pages/cart_page.dart';
import 'package:sushi_restaurant/pages/intro_page.dart';
import 'package:sushi_restaurant/pages/menu_page.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
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
        '/cart' : (context) => const CartPage(),
      },
    );
  }
}
