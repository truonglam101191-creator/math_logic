import 'package:flutter/material.dart';
import 'package:flutter_confetti/flutter_confetti.dart';

class ParticleRewardEffect {
  static void showReward(BuildContext context) {
    // Show confetti blast from the center
    Confetti.launch(
      context,
      options: ConfettiOptions(
        particleCount: 100,
        spread: 70,
        y: 0.6,
        colors: [
          Colors.yellow,
          Colors.orange,
          Colors.green,
          Colors.blue,
          Colors.pink,
          Colors.purple,
        ],
      ),
    );

    // After a short delay, show a second blast
    Future.delayed(const Duration(milliseconds: 200), () {
      if (context.mounted) {
        Confetti.launch(
          context,
          options: ConfettiOptions(particleCount: 50, spread: 100, y: 0.6),
        );
      }
    });
  }

  static void showStars(BuildContext context) {
    Confetti.launch(
      context,
      options: ConfettiOptions(
        particleCount: 60,
        angle: 90, // from top
        spread: 120,
        y: 0.1, // Near top
        colors: [Colors.yellow, Colors.orangeAccent],
      ),
    );
  }
}
