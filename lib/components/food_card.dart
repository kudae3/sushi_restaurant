import 'package:flutter/material.dart';
import 'package:sushi_restaurant/models/food.dart';

class FoodCard extends StatelessWidget {
  final Food food;
  final void Function() onTap;

  const FoodCard({super.key, required this.food, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              Image.asset(food.imagePath, width: 100, height: 100),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 10),
                  Text(food.price, style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Text(food.rating, style: TextStyle(fontSize: 16)),
                      Icon(Icons.star, color: Colors.orange, size: 16),
                    ],
                  ),
                  
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}