import 'package:flutter/material.dart';

class AppColors {
  // 🎨 Mode Clair
  static const Color backgroundLight = Color(0xFFF8F8F8);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF131313);
  static const Color textSecondaryLight = Color(0xFF5D5D5D);
  static const Color paragraphLight = Color(0xFF098E00);

  // Couleurs d’action
  static const Color successLight = Color(0xFF00C21C);
  static const Color errorLight = Color(0xFFFF1313);
  static const Color infoLight = Color(0xFF6653E5);
  static const Color warningLight = Color(0xFFE8B018);

  // Accents
  static const Color accentOrange = Color(0xFFE98C21);
  static const Color accentRed = Color(0xFFDF3434);

  // Liens
  static const Color link = Color(0xFF1D70B8);
  static const Color linkHover = Color(0xFF003078);
  static const Color linkVisited = Color(0xFF4C2C92);

  // Boutons
  static const Color buttonNormal = Color(0xFF098E00);
  static const Color buttonHover = Color(0xFF008713);
  static const Color buttonDisabled = Color(0xFF003078);

  // Icônes
  static const Color iconLight = Color(0xFF00C21C);

  // 🌙 Mode Sombre
  static const Color backgroundDark = Color(0xFF1A2530);
  static const Color cardDark = Color(0xFF2C3E50);
  static const Color textPrimaryDark = Color(0xFFF8F9FA);
  static const Color textSecondaryDark = Color(0xFFAAB0B8);

  static const Color successDark = Color(0xFF29FF48);
  static const Color errorDark = Color(0xFFFF1313);
  static const Color infoDark = Color(0xFF6653E5);
  static const Color warningDark = Color(0xFFE8B018);

  static const Color iconDark = Color(0xFF00C21C);
}

// 🎨 Palette et dégradés globaux
class AppThemes {
  static const Color primaryGreen = Color(0xFF098E00);
  static const Color lightGreen = Color(0xFF6FCF97);
  static const Color softGreen = Color(0xFFA8E6A3);
  static const Color greyLight = Color(0xFFE0E0E0);

  // 🇲🇬 Dégradé Madagascar
  static const LinearGradient madagascarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF007A3D), // vert
      // Color(0xFFFFFFFF), // blanc
      Color(0xFF098E00), // rouge
    ],
  );
}
