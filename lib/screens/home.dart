import 'package:flutter/material.dart';
// import 'dart:io'; // Uncomment if you're using exit(0)

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Title Screen.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Center(
                child: Image.asset(
                  'assets/images/AgriTayo - Logo.png',
                  height: 80,
                ),
              ),
              const SizedBox(height: 40),
              Column(
                children: [
MenuButton(
  text: 'AgriMarket', // Rename the button if needed
  onPressed: () {
    Navigator.pushNamed(context, '/marketplace_screen'); // 
  },
),

                  const SizedBox(height: 30), // <-- Space between title and buttons
                  // Buttons stacked tightly
                  MenuButton(
                    text: 'Play Game',
                    onPressed: () {
                      Navigator.pushNamed(context, '/game');
                    },
                  ),
                  MenuButton(
                    text: 'Credits',
                    onPressed: () {
                      Navigator.pushNamed(context, '/credits');
                    },
                  ),
                  MenuButton(
                    text: 'Quit',
                    onPressed: () {
                      // exit(0); // Uncomment if needed
                    },
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/chatbot');
              },
              child: Image.asset(
                'assets/images/Union.png',
                height: 80,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const MenuButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF404040),
          fontFamily: 'Futehodo-MaruGothic_1.00',
        ),
      ),
    );
  }
}