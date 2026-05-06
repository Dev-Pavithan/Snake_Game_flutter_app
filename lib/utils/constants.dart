import 'package:flutter/material.dart';

class GameConstants {
  // Modern Cyberpunk Colors
  static const Color backgroundColor = Color(0xFF0A0A0F);
  static const Color primaryColor = Color(0xFF00F2FF); // Cyan Neon
  static const Color secondaryColor = Color(0xFF7000FF); // Purple Neon
  static const Color accentColor = Color(0xFFFF00D4); // Pink Neon
  
  static const Color snakeHeadColor = Color(0xFF00F2FF);
  static const Color snakeBodyColor = Color(0xFF00A3FF);
  static const Color foodColor = Color(0xFFFF00D4);
  
  static const int gridRows = 30;
  static const int gridCols = 20;
  
  static const Duration initialSpeed = Duration(milliseconds: 200);
  static const double pixelPadding = 1.0;
}
