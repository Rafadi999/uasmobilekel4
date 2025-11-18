import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'firebase_options.dart'; // hasil dari flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Inisialisasi Firebase sebelum aplikasi dijalankan
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SISTEM AKADEMIK SEKOLAH',
      themeMode: themeProvider.currentTheme,

      // 🌞 Tema terang
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blueAccent,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
      ),

      // 🌙 Tema gelap
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.tealAccent,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
      ),

      home: const LoginScreen(),
    );
  }
}