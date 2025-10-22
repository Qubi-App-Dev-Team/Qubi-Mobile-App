import 'package:flutter/material.dart';

class ContentStyles {
  // Matches your body text everywhere
  static const TextStyle body = TextStyle(
    color: Colors.black87,
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );

  // Matches your bold header 'Shake it!' style
  static const TextStyle header = TextStyle(
    color: Colors.black87,
    fontSize: 20,
    height: 1.5,
    fontWeight: FontWeight.bold,
  );

    static const TextStyle buttonText = TextStyle(
    color: Colors.black87,
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.bold,
  );

  // Card visuals (experiment card / prompt)
  static const Color cardBorder = Color(0xFFD6DEE9);
  static const Color backgroundGray = Color(0xFFE6EEF8);

  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 8,
    offset: Offset(0, 3),
  );

  // Default outer padding used by your example page
  static const EdgeInsets pagePadding = EdgeInsets.all(20);
}
