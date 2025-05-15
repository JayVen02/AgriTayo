import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agritayo/models/message_model.dart';

class PrivateChatScreen extends StatefulWidget {
  final String recipientUserId;
  final String recipientUserName;
  final String recipientPhotoUrl;

  const PrivateChatScreen({
    super.key,
    required this.recipientUserId,
    required this.recipientUserName,
    required this.recipientPhotoUrl,
  });

  @override
  _PrivateChatScreenState createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late String _chatRoomId;

  @override
  void initState() {
    super.initState();
    final List<String> userIds = [currentUser!.uid, widget.recipientUserId]..sort();
    _chatRoomId = userIds.join('_');

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

   @override
   void dispose() {
     _messageController.dispose();
     _scrollController.dispose();
     super.dispose();
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


  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || currentUser == null) {
      return;
    }

    final messageText = _messageController.text.trim();
    _messageController.clear();

    try {
      final chatRef = _firestore.collection('chats').doc(_chatRoomId);
      final newMessage = Message(
        senderId: currentUser!.uid,
        receiverId: widget.recipientUserId,
        text: messageText,
        timestamp: Timestamp.now(),
      );

      WriteBatch batch = _firestore.batch();

      batch.set(chatRef.collection('messages').doc(), newMessage.toMap());

      batch.set(chatRef, {
        'participants': [_chatRoomId.split('_')[0], _chatRoomId.split('_')[1]],
        'lastMessage': messageText,
        'lastMessageTimestamp': Timestamp.now(),
      }, SetOptions(merge: true));

      await batch.commit();

       Future.delayed(const Duration(milliseconds: 100), () {
          _scrollToBottom();
        });

    } catch (e) {
      print("Error sending message: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
     if (currentUser == null) {
       return const Scaffold(
         body: Center(child: Text("Authentication error. Please log in again.")),
       );
     }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
               backgroundColor: Colors.grey[300],
               backgroundImage: widget.recipientPhotoUrl.isNotEmpty
                  ? NetworkImage(widget.recipientPhotoUrl) as ImageProvider<Object>
                  : const AssetImage('assets/user_placeholder.png') as ImageProvider<Object>,
               child: widget.recipientPhotoUrl.isEmpty ? const Icon(Icons.person, color: Colors.black54) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.recipientUserName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                 overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFa2d56b),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(_chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading messages: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Start the conversation!'));
                }

                final messages = snapshot.data!.docs.map((doc) => Message.fromMap(doc.data() as Map<String, dynamic>)).toList();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final bool isCurrentUser = message.senderId == currentUser!.uid;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: _messageBubble(
                        text: message.text,
                        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                        color: isCurrentUser ? const Color(0xFF00A814) : const Color(0xFF69B578),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInputArea(),
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
        margin: alignment == Alignment.centerLeft
            ? const EdgeInsets.only(right: 60)
            : const EdgeInsets.only(left: 60),
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

  Widget _buildMessageInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF8cc543),
      child: Row(
        children: [
          IconButton(
             icon: const Icon(Icons.attach_file, color: Colors.white),
             onPressed: () {
               print("Attachment icon tapped");
             },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: "Write Message...",
                  hintStyle: TextStyle(color: Colors.black54),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                ),
                style: const TextStyle(color: Colors.black87),
                keyboardType: TextInputType.multiline,
                 maxLines: null,
                 textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.black),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}