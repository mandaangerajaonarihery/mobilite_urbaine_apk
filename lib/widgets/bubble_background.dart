import 'dart:math';
import 'package:flutter/material.dart';

class BubbleBackground extends StatelessWidget {
  final Widget child;
  final Color baseColor; // couleur dominante de la page
  final int bubbleCount;

  const BubbleBackground({
    super.key,
    required this.child,
    required this.baseColor,
    this.bubbleCount = 8,
  });

  @override
  Widget build(BuildContext context) {
    final random = Random();

    return Stack(
      children: [
        // 🔹 Génération de bulles aléatoires
        ...List.generate(bubbleCount, (index) {
          final size = random.nextInt(80) + 40.0; // Taille aléatoire (40-120)
          final top = random.nextDouble() * MediaQuery.of(context).size.height;
          final left = random.nextDouble() * MediaQuery.of(context).size.width;

          // Dégradé de couleur basé sur la couleur de la page
          final bubbleColor = baseColor.withOpacity(0.1 + random.nextDouble() * 0.2);

          return Positioned(
            top: top,
            left: left,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bubbleColor,
                boxShadow: [
                  BoxShadow(
                    color: bubbleColor.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 4,
                  )
                ],
              ),
            ),
          );
        }),

        // 🔹 Le contenu de ta page
        child,
      ],
    );
  }
}
