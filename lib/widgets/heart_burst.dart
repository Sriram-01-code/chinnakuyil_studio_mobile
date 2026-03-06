import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class HeartBurst extends StatelessWidget {
  final ConfettiController controller;
  const HeartBurst({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ConfettiWidget(
        confettiController: controller,
        blastDirection: -pi / 2, // Upwards
        emissionFrequency: 0.05,
        numberOfParticles: 20,
        maxBlastForce: 20,
        minBlastForce: 10,
        gravity: 0.1,
        colors: const [
          Color(0xFFB76E79), // Rose Gold
          Color(0xFF8B0000), // Deep Red
          Colors.pinkAccent,
        ],
        createParticlePath: _drawHeart,
      ),
    );
  }

  Path _drawHeart(Size size) {
    double width = 20;
    double height = 20;
    Path path = Path();

    path.moveTo(0.5 * width, height * 0.35);
    path.cubicTo(0.2 * width, height * 0.1, -0.2 * width, height * 0.6,
        0.5 * width, height);
    path.moveTo(0.5 * width, height * 0.35);
    path.cubicTo(0.8 * width, height * 0.1, 1.2 * width, height * 0.6,
        0.5 * width, height);
    return path;
  }
}