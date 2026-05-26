import 'package:flutter/material.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 212, 202, 202),
      appBar: AppBar(leading: Icon(Icons.menu), backgroundColor: Colors.transparent, elevation: 0, title: Text('Menu'), centerTitle: true,),
      body: Column(children: [
        // promo banner

        // search bar

        // menu list

        // popular items
      ],)
    );
  }
}