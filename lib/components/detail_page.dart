import 'package:flutter/material.dart';
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
    );
  }
}