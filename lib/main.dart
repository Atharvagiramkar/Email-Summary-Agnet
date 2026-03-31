import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:emailsummaryagent/screens/auth_gate.dart';
import 'package:emailsummaryagent/screens/splash_screen.dart';
import 'package:emailsummaryagent/services/app_backend.dart';
import 'package:emailsummaryagent/services/app_runtime.dart';
import 'package:emailsummaryagent/services/firebase_app_backend.dart';
import 'package:emailsummaryagent/services/local_app_backend.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppRuntime.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E6BFF),
      brightness: Brightness.light,
      background: const Color(0xFFF0F5FF),
      surface: Colors.white,
      tertiary: const Color(0xFF00D4AA),
      error: const Color(0xFFFF6B6B),
    );

    return MaterialApp(
      title: 'Email Summary Agent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF0F5FF),
        useMaterial3: true,
        textTheme: GoogleFonts.manropeTextTheme().apply(
          bodyColor: const Color(0xFF0B1F3A),
          displayColor: const Color(0xFF0B1F3A),
        ).copyWith(
          headlineLarge: GoogleFonts.manrope(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0B1F3A),
          ),
          headlineMedium: GoogleFonts.manrope(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0B1F3A),
          ),
          titleLarge: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E6BFF),
          ),
        ),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0B1F3A),
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 8,
          shadowColor: const Color(0x1A1E6BFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFCADCFF)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFCADCFF), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF1E6BFF), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
          ),
          hintStyle: const TextStyle(color: Color(0xFF6B7A99)),
          labelStyle: const TextStyle(color: Color(0xFF0B1F3A), fontWeight: FontWeight.w600),
          prefixIconColor: const Color(0xFF1E6BFF),
          suffixIconColor: const Color(0xFF1E6BFF),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: const Color(0xFF1E6BFF),
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            elevation: 4,
            shadowColor: const Color(0x4D1E6BFF),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            side: const BorderSide(color: Color(0xFF1E6BFF), width: 2),
            foregroundColor: const Color(0xFF1E6BFF),
            textStyle: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF1E6BFF),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: GoogleFonts.manrope(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE3EBFF),
          thickness: 1.5,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xFF1E6BFF),
          circularTrackColor: Color(0xFFE3EBFF),
        ),
        splashFactory: InkRipple.splashFactory,
        splashColor: const Color(0x331E6BFF),
        highlightColor: const Color(0x1A1E6BFF),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          elevation: 12,
          shadowColor: const Color(0x1A1E6BFF),
          surfaceTintColor: Colors.white,
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: const Color(0xFF1E6BFF),
              );
            }
            return GoogleFonts.manrope(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: const Color(0xFF6B7A99),
            );
          }),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const IconThemeData(
                color: Color(0xFF1E6BFF),
                size: 28,
              );
            }
            return const IconThemeData(
              color: Color(0xFF6B7A99),
              size: 26,
            );
          }),
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: SplashScreen(child: AuthGate(backend: _resolveBackend())),
    );
  }

  AppBackend _resolveBackend() {
    if (AppRuntime.firebaseEnabled) {
      return FirebaseAppBackend();
    }
    return const LocalAppBackend();
  }
}
