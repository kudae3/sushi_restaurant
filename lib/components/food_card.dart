import 'package:flutter/material.dart';
import 'package:sushi_restaurant/models/food.dart';

class FoodCard extends StatelessWidget {
  final Food food;

  const FoodCard({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Image.asset(food.imagePath, width: 100, height: 100),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(food.price, style: TextStyle(fontSize: 16, color: Colors.green)),
                Text('Rating: ${food.rating}', style: TextStyle(fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}