import 'package:flutter/material.dart';
import 'carrot.dart';
class messages extends StatelessWidget {
  const messages({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFa2d56b), Color(0xFF8cc543)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
child: Row(
  children: [
    GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Carrot()),
        );
      },
      child: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
    ),
    const SizedBox(width: 12),
    const CircleAvatar(
      backgroundColor: Colors.white,
      radius: 16,
      child: Icon(Icons.mood_bad, color: Colors.purple),
    ),
    const SizedBox(width: 12),
    const Text(
      'Sigma Boy',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  ],
),
            
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _messageBubble(width: 160, height: 40),
                const SizedBox(height: 12),
                _messageBubble(width: 200, height: 40),
                const SizedBox(height: 12),
                _messageBubble(width: 240, height: 200),
                const SizedBox(height: 12),
                _messageBubble(width: 180, height: 80),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF8cc543),
            child: Row(
              children: [
                const Icon(Icons.upload, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Write Message",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const Icon(Icons.send, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageBubble({required double width, required double height}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.green.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
