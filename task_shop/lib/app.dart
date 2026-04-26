import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'services/api_service.dart';
import 'config/constants.dart';

class TaskShopApp extends StatelessWidget {
  const TaskShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.nunitoTextTheme(
      GoogleFonts.fredokaTextTheme(),
    ).copyWith(
      displayLarge: GoogleFonts.fredoka(fontSize: 32, fontWeight: FontWeight.w700),
      headlineLarge: GoogleFonts.fredoka(fontSize: 24, fontWeight: FontWeight.w600),
      headlineMedium: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.w500),
      titleMedium: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w400),
      labelLarge: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600),
    );

    return MaterialApp(
      title: '一分钟差事铺',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onPrimary,
          tertiary: AppColors.accent,
          onTertiary: AppColors.onAccent,
          surface: AppColors.card,
          onSurface: AppColors.cardForeground,
          error: AppColors.destructive,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: textTheme,
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.card,
          foregroundColor: AppColors.foreground,
          elevation: 0,
          scrolledUnderElevation: 1,
          titleTextStyle: GoogleFonts.fredoka(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.foreground,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusXL),
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: AppTokens.spaceLG,
            vertical: AppTokens.spaceSM,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusLG),
            ),
            textStyle: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.muted,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMD),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMD),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMD),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _checking = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await ApiService().getToken();
    if (mounted) {
      setState(() {
        _loggedIn = token != null;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _loggedIn ? const HomePage() : const LoginPage();
  }
}
