import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sushi_restaurant/pages/cart_page.dart';
import 'package:sushi_restaurant/pages/intro_page.dart';
import 'package:sushi_restaurant/pages/auth_page.dart';
import 'package:sushi_restaurant/pages/menu_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sushi_restaurant/pages/profile_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        '/auth': (context) => const AuthPage(),
        '/menu' : (context) => const MenuPage(),
        '/cart' : (context) => const CartPage(),
        '/profile' : (context) => const ProfilePage(),
      },
    );
  }
}
