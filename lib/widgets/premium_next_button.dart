import 'package:flutter/material.dart';

class PremiumNextButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color textColor;
  final Color accentColor;

  const PremiumNextButton({
    super.key,
    required this.onPressed,
    required this.textColor,
    required this.accentColor,
  });

  @override
  State<PremiumNextButton> createState() => _PremiumNextButtonState();
}

class _PremiumNextButtonState extends State<PremiumNextButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(_isPressed ? 0.96 : 1.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.accentColor.withOpacity(0.2),
                widget.accentColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.accentColor.withOpacity(0.4),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Manaraka',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  color: widget.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: widget.textColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
