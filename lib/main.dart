import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';
import 'authentication/login.dart';
import './screens/home.dart';
import './screens//marketplace_screen.dart';
import 'marketplace/graph.dart';
import 'chatbot/chatbot_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './screens/credit.dart';
import './screens/game_screen.dart';
import './screens/profile_screen.dart';
import './screens/message_screen.dart';
import './screens/manage_product_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/manage_product_detail_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/product_form_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
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
        '/marketplace_list': (context) => const MarketplaceListView(),
        '/graph': (context) => const GraphScreen(),
        '/credits': (context) => const CreditsScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
        '/game': (context) => const GameScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/chat': (context) => const ChatScreen(),
        '/manage_product_detail': (context) => const ProductFormScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/add_product': (context) => const AddProductScreen(),
      },
    );
  }
}