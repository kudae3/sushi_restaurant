import 'package:flutter/material.dart';
import 'package:sushi_restaurant/components/button.dart';
import 'package:sushi_restaurant/theme/colors.dart';
import 'package:sushi_restaurant/models/food.dart';

class DetailPage extends StatefulWidget {
  final Food food;
  const DetailPage({super.key, required this.food});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

      ),
      body: Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: ListView(
            children: [
              // Image
              Center(child: Image.asset(widget.food.imagePath, width: 200, height: 200)),
          
              // Rating
              SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber),
                  SizedBox(width: 5),
                  Text(widget.food.rating, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'DMSerifDisplay')),
                ],
              ),
          
              // Name
              SizedBox(height: 20),
              Text(
                widget.food.name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'DMSerifDisplay'),
              ),
          
              // Description
              SizedBox(height: 25),
              Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                style: TextStyle(fontSize: 16, fontFamily: 'DMSerifDisplay', color: Colors.grey[600], height: 2),
              ),
            ]
          ),
        ),
      ),

      // Price + Quantity + Add to Cart Button
      bottomNavigationBar: Container(
        color: primaryColor,
        padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Price
                Text(widget.food.price, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'DMSerifDisplay', color: Colors.white)),
                
                // Quantity
                Row(
                  children: [
                    // Derease Button
                    Icon(Icons.remove, color: Colors.white, fontWeight: FontWeight.bold),
                    SizedBox(width: 20),
            
                    // Number
                    Text('1', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'DMSerifDisplay', color: Colors.white)),
                    SizedBox(width: 20),
            
                    // Increase Button
                    Icon(Icons.add, color: Colors.white, fontWeight: FontWeight.bold),
                  ]
                )
              ],
            ),
            SizedBox(height: 20),
            MyButton(text: 'Add to Cart', onTap: () => Navigator.pushNamed(context, '/cart')),
          ],
        ),
      ),


    );
  }
}