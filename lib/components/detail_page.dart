import 'package:flutter/material.dart';
import 'package:sushi_restaurant/theme/colors.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Food Detail'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        
      ),
      body: Center(
        child: Text('Food Detail Page'),
      ),
    );
  }
}