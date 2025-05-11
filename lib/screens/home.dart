import 'package:flutter/material.dart';
<<<<<<< HEAD
// import 'dart:io'; // Uncomment if you're using exit(0)
=======
import 'dart:io';
>>>>>>> 80da4e54c180bf4b94ab96d1c51b0ec635c477fb

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
<<<<<<< HEAD
                  const Text(
                    'AgriMarket',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Futehodo-MaruGothic_1.00',
                      color: Color(0xFF404040),
                    ),
                  ),
                  const SizedBox(height: 30), // <-- Space between title and buttons
                  // Buttons stacked tightly
                  MenuButton(
=======
                  const PressableText(text: 'AgriMarket'),
                  const SizedBox(height: 30),
                  PressableMenuButton(
>>>>>>> 80da4e54c180bf4b94ab96d1c51b0ec635c477fb
                    text: 'Play Game',
                    onPressed: () {
                      Navigator.pushNamed(context, '/game');
                    },
                  ),
<<<<<<< HEAD
                  MenuButton(
=======
                  const SizedBox(height: 2),
                  PressableMenuButton(
>>>>>>> 80da4e54c180bf4b94ab96d1c51b0ec635c477fb
                    text: 'Credits',
                    onPressed: () {
                      Navigator.pushNamed(context, '/credits');
                    },
                  ),
<<<<<<< HEAD
                  MenuButton(
                    text: 'Quit',
                    onPressed: () {
                      // exit(0); // Uncomment if needed
=======
                  const SizedBox(height: 2),
                  PressableMenuButton(
                    text: 'Quit',
                    onPressed: () {
                      exit(0);
>>>>>>> 80da4e54c180bf4b94ab96d1c51b0ec635c477fb
                    },
                  ),
                ],
              ),
            ],
          ),
<<<<<<< HEAD
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
=======
          const Positioned(
            bottom: 20,
            right: 20,
            child: ChatbotTap(),
>>>>>>> 80da4e54c180bf4b94ab96d1c51b0ec635c477fb
          ),
        ],
      ),
    );
  }
}

<<<<<<< HEAD
class MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const MenuButton({
=======
class PressableMenuButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const PressableMenuButton({
>>>>>>> 80da4e54c180bf4b94ab96d1c51b0ec635c477fb
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
<<<<<<< HEAD
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
=======
  _PressableMenuButtonState createState() => _PressableMenuButtonState();
}

class _PressableMenuButtonState extends State<PressableMenuButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.rotationZ(_isPressed ? 0.05 : 0),
        transformAlignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _isPressed ? Colors.white : const Color(0xFF404040),
              fontFamily: 'Futehodo-MaruGothic_1.00',
            ),
          ),
>>>>>>> 80da4e54c180bf4b94ab96d1c51b0ec635c477fb
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======
}

class PressableText extends StatefulWidget {
  final String text;

  const PressableText({super.key, required this.text});

  @override
  _PressableTextState createState() => _PressableTextState();
}

class _PressableTextState extends State<PressableText> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.rotationZ(_isPressed ? -0.10 : 0),
        transformAlignment: Alignment.center,
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontFamily: 'Futehodo-MaruGothic_1.00',
            color: _isPressed ? Colors.white : const Color(0xFF404040),
          ),
        ),
      ),
    );
  }
}

class ChatbotTap extends StatefulWidget {
  const ChatbotTap({super.key});

  @override
  _ChatbotTapState createState() => _ChatbotTapState();
}

class _ChatbotTapState extends State<ChatbotTap> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    Navigator.pushNamed(context, '/chatbot');
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 150),
        firstChild: Image.asset(
          'assets/images/chatbot.png',
          height: 80,
        ),
        secondChild: Image.asset(
          'assets/images/chatbotHovered.png',
          height: 80,
        ),
        crossFadeState:
            _isPressed ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      ),
    );
  }
}
>>>>>>> 80da4e54c180bf4b94ab96d1c51b0ec635c477fb
