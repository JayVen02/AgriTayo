import 'package:flutter/material.dart';

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
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
                ),
                const SizedBox(width: 12),
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 16,
                  child: Icon(Icons.person, color: Colors.purple), 
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
                _messageBubble(text: "Hello!"),
                const SizedBox(height: 12),
                _messageBubble(text: "How are you?", alignment: Alignment.centerRight, color: Colors.blue.shade300),
                const SizedBox(height: 12),
                _messageBubble(text: "This is a longer message to demonstrate wrapping and height. What's the price of potatoes today?"),
                const SizedBox(height: 12),
                _messageBubble(text: "Around 50 per kg.", alignment: Alignment.centerRight, color: Colors.blue.shade300),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF8cc543),
            child: Row(
              children: [
                const Icon(Icons.add_photo_alternate_outlined, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Write Message...",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.send, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageBubble({
    required String text,
    Alignment alignment = Alignment.centerLeft,
    Color color = const Color(0xFF69B578),
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 250),
        padding: const EdgeInsets.all(12),
        margin: alignment == Alignment.centerLeft ? const EdgeInsets.only(right: 40) : const EdgeInsets.only(left: 40),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}