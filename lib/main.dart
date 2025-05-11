import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'authentication/login.dart';
import 'screens/home.dart';
import 'chatbot/chatbot_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/credit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
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
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 6, 236, 21)),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        // '/game': (context) => GameDashboard(),
        '/credits': (context) => const CreditsScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
      },
    );
  }
}