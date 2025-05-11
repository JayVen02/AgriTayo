import 'package:flutter/material.dart';
import 'chatbot_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  String _botMessage = 'Hello I am AgriBot!';
  final TextEditingController _controller = TextEditingController();
  bool _showInputField = false;
  bool _isLoading = false;

  final ChatbotService _chatbotService = ChatbotService();

  void _handleAsk() async {
    if (!_showInputField) {
      setState(() {
        _botMessage = 'You can ask me anything.';
        _showInputField = true;
      });
    } else {
      if (_controller.text.trim().isEmpty) return;

      setState(() {
        _isLoading = true;
      });

      try {
        String response = await _chatbotService.sendMessage(_controller.text.trim());

        setState(() {
          _botMessage = 'Answer: $response';
        });
      } catch (e) {
        setState(() {
          _botMessage = 'Error: failed to get a response.';
        });
      } finally {
        _controller.clear();
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/AgriBot.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(color: Colors.green, width: 2),
                          ),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text('Back', style: TextStyle(color: Colors.black)),
                      ),
                      ElevatedButton(
                        onPressed: _handleAsk,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(color: Colors.green, width: 2),
                          ),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text('Ask', style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Image.asset(
                  'assets/images/Union.png',
                  height: 200,
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    _botMessage,
                    key: ValueKey<String>(_botMessage),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Futehodo-MaruGothic_1.00',
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (_showInputField)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Column(
                      children: [
                        TextField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Type your message here...',
                            hintStyle: const TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.green, width: 2),
                            ),
                            fillColor: Colors.black.withOpacity(0.3),
                            filled: true,
                          ),
                        ),
                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                  ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}