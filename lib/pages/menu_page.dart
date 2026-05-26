import 'package:flutter/material.dart';
import 'package:sushi_restaurant/components/button.dart';
import 'package:sushi_restaurant/theme/colors.dart';

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
            Container(
              padding: EdgeInsets.symmetric(vertical: 30.0),
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(25),
              ), 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Get 20% Off Promotion!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'DMSerifDisplay')),
                      SizedBox(height: 20),
                      MyButton(text: 'Redeem', onTap: () => Navigator.pushNamed(context, '/intro')),
                    ],
                  ),
                  SizedBox(width: 20),
                  Image.asset('lib/images/sushi_2.png', width: 100, height: 100),
                ],
              )
            ),
          
          // search bar
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for sushi...',
                prefixIcon: Icon(Icons.search),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: secondaryColor, width: 2),
                  ),
              ),
            ),
          ),
      
      
          // menu list
      
          // popular items
        ],)
      );
  }
}