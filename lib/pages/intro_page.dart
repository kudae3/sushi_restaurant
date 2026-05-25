import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 78, 18, 18),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column( 
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            Text('SUSHI MAN', style: GoogleFonts.dmSerifDisplay(
              fontSize: 28,
              color: Colors.white
            )),
            
            // icon
            SizedBox(height: 50),
            Center(child: Image.asset('lib/images/sushi.png', width: 200, height: 200)),
          
            // title
          
            // subtitle
          
            // get started button
          ],),
      )
    );
  }
}