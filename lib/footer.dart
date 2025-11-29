import 'package:flutter/material.dart';

// Reusable footer widget
class FooterText extends StatelessWidget {
  const FooterText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(12.0),
      child: Text(
        "Developed by Jaineel Chhatraliya",
        style: TextStyle(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
