import 'package:flutter/material.dart';

class Bg extends StatelessWidget {
  final Color color1;
  final Color color2;

  const Bg({
    Key? key,
    this.color1 = const Color.fromARGB(255, 255, 255, 255), 
    this.color2 = const Color.fromARGB(255, 255, 255, 255), 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color1, color2],
          stops: const [0.4, 0.99],
        ),
      ),
    );
  }
}