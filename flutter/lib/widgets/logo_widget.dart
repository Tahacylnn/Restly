import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // circular pause icon and Restly text
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width:72, height:72,
          decoration: BoxDecoration(color: Color(0xFFc53030), shape: BoxShape.circle),
          child: Center(child: Container(width:14, height:28, color: Colors.white)),
        ),
        SizedBox(width:12),
        Text('Restly', style: TextStyle(fontSize:28, fontWeight: FontWeight.w700, color: Color(0xFFc53030))),
      ],
    );
  }
}
