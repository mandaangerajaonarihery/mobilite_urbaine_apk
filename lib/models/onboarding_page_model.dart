import 'package:flutter/material.dart';

class OnboardingPageModel {
  final String title;
  final String description;
  final String imagePath;
  final Color bgColor;
  final Color accentColor;
  final Color textColor;

  OnboardingPageModel({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.bgColor,
    required this.accentColor,
    this.textColor = Colors.white,
  });
}
