import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'authentication/login.dart';
import 'screens/home.dart'; // Import your HomeScreen
import 'screens/marketplace_screen.dart';
import 'screens/marketplace_screen2.dart';
import 'screens/graph.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriTayo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 6, 236, 21)),
        useMaterial3: true,
      ),
      initialRoute: '/login',
       home: const FarmerDashboard(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/marketplace_screen': (context) => const MarketplaceScreen(),
        '/marketplace_screen2': (context) => const FarmerDashboard(),
  '/graph.dart': (context) => Graph(), 
        // '/game': (context) => GameDashboard(),
        // '/credits': (context) => CreditsScreen(),
        // '/chatbot': (context) => ChatbotUI(),
      },
    );
  }
}