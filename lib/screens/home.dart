import 'package:flutter/material.dart';
import 'dart:io';

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
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 150),

                Image.asset(
                  'assets/images/AgriTayo - Logo.png',
                  height: 120,
                ),
                const SizedBox(height: 80),

                PressableText(
                  text: 'AgriMarket',
                  onPressed: () {
                    Navigator.pushNamed(context, '/marketplace_list');
                  },
                ),
                const SizedBox(height: 30),

                Column(
                  children: [
                    PressableMenuButton(
                      text: 'Play game',
                      onPressed: () {
                        Navigator.pushNamed(context, '/game');
                      },
                    ),
                    const SizedBox(height: 2),
                     PressableMenuButton(
                       text: 'Quit',
                       onPressed: () {
                         exit(0);
                       },
                     ),
                    const SizedBox(height: 2),
                    PressableMenuButton(
                      text: 'Credits',
                      onPressed: () {
                        Navigator.pushNamed(context, '/credits');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: 20,
            right: 20,
            child: ChatbotTap(),
          ),
        ],
      ),
    );
  }
}

class PressableMenuButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const PressableMenuButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  _PressableMenuButtonState createState() => _PressableMenuButtonState();
}

class _PressableMenuButtonState extends State<PressableMenuButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.rotationZ(_isPressed ? 0.05 : 0),
        transformAlignment: Alignment.center,
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
      ),
    );
  }
}

class PressableText extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const PressableText({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  _PressableTextState createState() => _PressableTextState();
}

class _PressableTextState extends State<PressableText> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
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
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    Navigator.pushNamed(context, '/chatbot');
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
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