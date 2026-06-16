import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const BulkSmsBdDemoApp());
}

class BulkSmsBdDemoApp extends StatelessWidget {
  const BulkSmsBdDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BulkSMS BD Demo',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const HomePage(),
    );
  }

  ThemeData _buildTheme() {
    const primary = Color(0xFF6366F1);
    const onSurface = Color(0xFF0F172A);
    const onSurfaceVariant = Color(0xFF64748B);
    const surface = Color(0xFFF8FAFC);
    const outline = Color(0xFFE2E8F0);

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF1F5F9),
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: const Color(0xFF8B5CF6),
        tertiary: const Color(0xFF06B6D4),
        surface: Colors.white,
        surfaceContainerLowest: const Color(0xFFF8FAFC),
        surfaceContainerLow: Colors.white,
        surfaceContainer: surface,
        onPrimary: Colors.white,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
      ),
      useMaterial3: true,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: onSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w500),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        prefixIconColor: const Color(0xFF94A3B8),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: onSurface,
        titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: onSurface),
      ),
    );
  }
}
