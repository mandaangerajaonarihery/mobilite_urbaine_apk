import 'package:flutter/material.dart';

class ModernSkipButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color textColor;
  final Color accentColor;

  const ModernSkipButton({
    super.key,
    required this.onPressed,
    required this.textColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: textColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: textColor.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Aloha',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_rounded,
                color: textColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
