import 'package:flutter/material.dart';
// import 'marketplace_screen.dart'; // No longer needed for back navigation if using Navigator.pop

// SigmaBoyApp class removed as ChatScreen is navigated to directly
// and it shouldn't be a nested MaterialApp.

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
                    // Standard back navigation
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
                ),
                const SizedBox(width: 12),
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 16,
                  // Consider using a more relevant icon or image
                  child: Icon(Icons.person, color: Colors.purple), // Example: person icon
                ),
                const SizedBox(width: 12),
                const Text(
                  'Sigma Boy', // This seems to be the chat recipient's name
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
                // Example message bubbles - replace with actual message data
                _messageBubble(width: 160, height: 40, text: "Hello!"),
                const SizedBox(height: 12),
                _messageBubble(width: 200, height: 40, text: "How are you?", alignment: Alignment.centerRight, color: Colors.blue.shade300),
                const SizedBox(height: 12),
                _messageBubble(width: 240, height: 200, text: "This is a longer message to demonstrate wrapping and height. What's the price of potatoes today?"),
                const SizedBox(height: 12),
                _messageBubble(width: 180, height: 80, text: "Around 50 per kg.", alignment: Alignment.centerRight, color: Colors.blue.shade300),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF8cc543), // Matches app bar gradient
            child: Row(
              children: [
                const Icon(Icons.add_photo_alternate_outlined, color: Colors.white), // Changed from "upload"
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text( // This should be a TextField for input
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
    required double width,
    required double height,
    String text = "", // Add text parameter
    Alignment alignment = Alignment.centerLeft, // Add alignment
    Color color = const Color(0xFF69B578), // Default bubble color (lighter green)
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        width: width,
        // height: height, // Height can be dynamic based on text
        padding: const EdgeInsets.all(12),
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