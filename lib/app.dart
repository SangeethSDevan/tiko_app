import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/event_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<EventProvider>(create: (_) => EventProvider()),
      ],
      child: MaterialApp(
        title: 'Tiko Reminder App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.light(
            primary: const Color(0xFF4F46E5),
            secondary: const Color(0xFF6366F1),
            background: const Color(0xFFF9FAFB),
            surface: Colors.white,
            onPrimary: Colors.white,
            onBackground: const Color(0xFF111827),
            onSurface: const Color(0xFF111827),
          ),
          fontFamily: 'Outfit',
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
            titleMedium: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
            bodyMedium: TextStyle(
              fontSize: 16,
              color: Color(0xFF374151),
              height: 1.5,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.2),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              elevation: 1,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),

          // <-- FIX: use CardThemeData instead of CardTheme
          cardTheme: CardThemeData(
            elevation: 0,
            color: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.all(12),
          ),

          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Color(0xFF111827),
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'Outfit',
            ),
            iconTheme: IconThemeData(color: Color(0xFF111827)),
          ),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return auth.isLoggedIn ? const HomeScreen() : const LoginScreen();
          },
        ),
      ),
    );
  }
}
