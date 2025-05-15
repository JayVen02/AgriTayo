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

  final ScrollController _scrollController = ScrollController();

  void _handleAsk() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!_showInputField) {
      setState(() {
        _botMessage = 'You can ask me anything.';
        _showInputField = true;
      });
    } else {
      if (_controller.text.trim().isEmpty) {
        return;
      }

      setState(() {
        _isLoading = true;
      });

      String userMessage = _controller.text.trim();
      _controller.clear();

      try {
        String response = await _chatbotService.sendMessage(userMessage);

        setState(() {
          _botMessage = 'Answer: $response';
        });

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

      } catch (e) {
        print("Error sending message to chatbot: $e");
        setState(() {
          _botMessage = 'Error: failed to get a response. Please try again.';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double spaceAboveBubble = 240.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              crossAxisAlignment: CrossAxisAlignment.center,
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
                        onPressed: _isLoading ? null : _handleAsk,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(color: Colors.green, width: 2),
                          ),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          disabledBackgroundColor: Colors.grey[300],
                          disabledForegroundColor: Colors.grey[600],
                        ),
                        child: Text(
                            _showInputField ? (_isLoading ? 'Loading...' : 'Send') : 'Ask',
                            style: const TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: spaceAboveBubble),
                Image.asset(
                  'assets/images/Union.png',
                  height: 200,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 40),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: _showInputField ? 80.0 : 16.0,
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Text(
                      _botMessage,
                      key: ValueKey<String>(_botMessage),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Futehodo-MaruGothic_1.00',
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      softWrap: true,
                    ),
                  ),
                ),
              ),
              ],
            ),
          ),

          if (_showInputField)
            Positioned(
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black.withOpacity(0.3),
                  border: Border.all(color: Colors.white),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type your message here...',
                        hintStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.transparent,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                      ),
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                    ),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}