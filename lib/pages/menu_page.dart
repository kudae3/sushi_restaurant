import 'package:flutter/material.dart';
import 'package:sushi_restaurant/components/button.dart';
import 'package:sushi_restaurant/components/detail_page.dart';
import 'package:sushi_restaurant/components/food_card.dart';
import 'package:sushi_restaurant/models/food.dart';
import 'package:sushi_restaurant/services/auth_service.dart';
import 'package:sushi_restaurant/theme/colors.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String searchQuery = '';

  void onDetailClicked(Food food){
    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(food: food)));
  }

  final authService = AuthService();
  
  final List<Food> menuList = [
    Food(name: 'California Roll', price: '\$12.99', imagePath: 'lib/images/sushi_1.png', rating: '4.5'),
    Food(name: 'Spicy Tuna Roll', price: '\$14.99', imagePath: 'lib/images/sushi_2.png', rating: '4.7'),
    Food(name: 'Salmon Roll', price: '\$13.99', imagePath: 'lib/images/sushi_3.png', rating: '4.6'),
    Food(name: 'Dragon Roll', price: '\$16.99', imagePath: 'lib/images/sushi_4.png', rating: '4.8'),
    Food(name: 'Maki', price: '\$12.99', imagePath: 'lib/images/maki.png', rating: '4.3'),
  ];

  List<Food> get filteredMenuList {
    if (searchQuery.isEmpty) {
      return menuList;
    }

    final query = searchQuery.toLowerCase();
    return menuList
        .where((food) => food.name.toLowerCase().contains(query))
        .toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () async {
              await authService.signOut();
              if (!context.mounted) return;
              // redirect to intro page
              Navigator.pushReplacementNamed(context, '/intro');
            }, 
            icon: Icon(Icons.logout_outlined, color: Colors.red)
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          // title: const Text('Menu'),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'Cart',
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () => Navigator.pushNamed(context, '/cart'),
            ),
            IconButton(
              tooltip: 'Profile',
              icon: const Icon(Icons.account_circle_outlined),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(children: [
            // promo banner
            Container(
              padding: EdgeInsets.symmetric(vertical: 30.0),
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
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search for sushi...',
                  prefixIcon: const Icon(Icons.search),
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
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    searchQuery.isEmpty ? 'Today Popular Items' : 'Search Results',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'DMSerifDisplay',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: filteredMenuList.isEmpty
                  ? Center(
                      child: Text(
                        'No matching items found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontFamily: 'DMSerifDisplay',
                        ),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => FoodCard(
                        food: filteredMenuList[index],
                        onTap: () => onDetailClicked(filteredMenuList[index]),
                      ),
                      itemCount: filteredMenuList.length,
                      // shrinkWrap: true,
                    ),
            )),
                
            // popular items
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(vertical: 30.0),
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
                      Text('Try Our Popular Items!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'DMSerifDisplay')),
                      SizedBox(height: 20),
                      MyButton(text: 'Order Now', onTap: () => Navigator.pushNamed(context, '/intro')),
                    ],
                  ),
                  SizedBox(width: 20),
                  Image.asset('lib/images/sushi_4.png', width: 100, height: 100),
                ],
              )
            ),
          
          ],),
        )
      );
  }
}
