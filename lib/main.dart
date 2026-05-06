import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/snake_game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: EchoRiderApp(),
    ),
  );
}

class EchoRiderApp extends StatelessWidget {
  const EchoRiderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixel Serpent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        textTheme: GoogleFonts.orbitronTextTheme(ThemeData.dark().textTheme),
      ),
      home: const SnakeGameScreen(),
    );
  }
}
