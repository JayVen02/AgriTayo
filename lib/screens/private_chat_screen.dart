import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agritayo/models/message_model.dart';

class PrivateChatScreen extends StatefulWidget {
  final String? chatId;
  final String recipientUserId;
  final String recipientUserName;
  final String recipientPhotoUrl;
  final Map<String, dynamic>? productDetails;

  const PrivateChatScreen({
    super.key,
    this.chatId,
    required this.recipientUserId,
    required this.recipientUserName,
    required this.recipientPhotoUrl,
    this.productDetails,
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
  Stream<DocumentSnapshot>? _chatDocStream;
  bool _isInitializingChat = true;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    if (currentUser == null) {
      print("Error: currentUser is null in PrivateChatScreen initState.");
      return;
    }

    final List<String> userIds = [currentUser!.uid, widget.recipientUserId]..sort();
    _chatRoomId = userIds.join('_');

    try {
      final chatDoc = await _firestore.collection('chats').doc(_chatRoomId).get();

      if (!chatDoc.exists) {
        final now = Timestamp.now();
        
        await _firestore.collection('chats').doc(_chatRoomId).set({
          'participantIds': {
            currentUser!.uid: true,
            widget.recipientUserId: true,
          },
          'createdAt': now,
          'lastMessage': '',
          'lastMessageTimestamp': now,
          'unreadCount_${currentUser!.uid}': 0,
          'unreadCount_${widget.recipientUserId}': 0,
          if (widget.productDetails != null) 'relatedProduct': widget.productDetails,
        });

        await _firestore.collection('users').doc(currentUser!.uid).collection('userChats').doc(_chatRoomId).set({
          'chatId': _chatRoomId,
          'lastMessageTimestamp': now,
          'recipientId': widget.recipientUserId,
          'recipientName': widget.recipientUserName,
          'recipientPhotoUrl': widget.recipientPhotoUrl,
          if (widget.productDetails != null) 'productRef': _firestore.collection('products').doc(widget.productDetails!['id']),
        });
        
        await _firestore.collection('users').doc(widget.recipientUserId).collection('userChats').doc(_chatRoomId).set({
          'chatId': _chatRoomId,
          'lastMessageTimestamp': now,
          'recipientId': currentUser!.uid,
          'recipientName': currentUser?.displayName,
          'recipientPhotoUrl': currentUser?.photoURL,
          if (widget.productDetails != null) 'productRef': _firestore.collection('products').doc(widget.productDetails!['id']),
        });
      }

      if (mounted) {
        setState(() {
          _chatDocStream = _firestore.collection('chats').doc(_chatRoomId).snapshots();
          _isInitializingChat = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e) {
      print("Error initializing chat: $e");
      if (mounted) {
        setState(() {
          _isInitializingChat = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to initialize chat: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients && _scrollController.position.maxScrollExtent.isFinite) {
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

    final chatRef = _firestore.collection('chats').doc(_chatRoomId);
    final currentUserUid = currentUser!.uid;
    final recipientUid = widget.recipientUserId;
    final now = Timestamp.now();

    final newMessage = Message(
      senderId: currentUserUid,
      receiverId: recipientUid,
      text: messageText,
      timestamp: now,
    );

    WriteBatch batch = _firestore.batch();

    DocumentSnapshot chatDocCheck;
    try {
      chatDocCheck = await chatRef.get();
    } catch (e) {
      print("Error checking chat existence before sending message: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error preparing message: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final bool chatExists = chatDocCheck.exists;

    if (!chatExists) {
      print("Chat document $_chatRoomId still does not exist. Creating batch to initialize.");
      batch.set(chatRef, {
        'participantIds': {
          currentUserUid: true,
          widget.recipientUserId: true,
        },
        'createdAt': now,
        'lastMessage': messageText,
        'lastMessageTimestamp': now,
        'unreadCount_${currentUserUid}': 0,
        'unreadCount_${recipientUid}': 1,
        if (widget.productDetails != null) 'relatedProduct': widget.productDetails,
      });

      batch.set(
        _firestore.collection('users').doc(currentUserUid).collection('userChats').doc(_chatRoomId),
        {
          'chatId': _chatRoomId,
          'lastMessageTimestamp': now,
          'recipientId': recipientUid,
          'recipientName': widget.recipientUserName,
          'recipientPhotoUrl': widget.recipientPhotoUrl,
          if (widget.productDetails != null) 'productRef': _firestore.collection('products').doc(widget.productDetails!['id']),
        },
        SetOptions(merge: true),
      );

      batch.set(
        _firestore.collection('users').doc(recipientUid).collection('userChats').doc(_chatRoomId),
        {
          'chatId': _chatRoomId,
          'lastMessageTimestamp': now,
          'recipientId': currentUserUid,
          'recipientName': currentUser?.displayName,
          'recipientPhotoUrl': currentUser?.photoURL,
          if (widget.productDetails != null) 'productRef': _firestore.collection('products').doc(widget.productDetails!['id']),
        },
        SetOptions(merge: true),
      );
    } else {
      print("Chat document $_chatRoomId exists. Updating batch.");
      final String recipientUnreadCountField = 'unreadCount_${recipientUid}';

      batch.update(chatRef, {
        'lastMessage': messageText,
        'lastMessageTimestamp': now,
        recipientUnreadCountField: FieldValue.increment(1),
      });

      batch.update(
        _firestore.collection('users').doc(currentUserUid).collection('userChats').doc(_chatRoomId),
        {
          'lastMessageTimestamp': now,
        },
      );

      batch.update(
        _firestore.collection('users').doc(recipientUid).collection('userChats').doc(_chatRoomId),
        {
          'lastMessageTimestamp': now,
        },
      );
    }

    batch.set(chatRef.collection('messages').doc(), newMessage.toMap());

    try {
      print("Committing batch for chat $_chatRoomId...");
      await batch.commit();
      print("Batch committed successfully.");

      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _scrollToBottom();
      });
    } catch (e) {
      print("Error sending message (batch commit failed): $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to send message: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markMessagesAsRead() async {
    if (currentUser == null || !mounted || _chatRoomId.isEmpty) return;

    final chatRef = _firestore.collection('chats').doc(_chatRoomId);
    final currentUserUid = currentUser!.uid;
    final currentUserUnreadCountField = 'unreadCount_${currentUserUid}';

    try {
      final chatDoc = await chatRef.get();
      if (!chatDoc.exists) {
        print("Attempted to mark messages as read, but chat document $_chatRoomId does not exist.");
        return;
      }

      final int currentUnreadCount = (chatDoc.data() as Map<String, dynamic>)?[currentUserUnreadCountField]?.toInt() ?? 0;

      if (currentUnreadCount > 0) {
        WriteBatch batch = _firestore.batch();
        batch.update(chatRef, {
          currentUserUnreadCountField: 0,
        });

        await batch.commit();
        print("Unread count reset to 0 for ${currentUserUid} in chat $_chatRoomId");
      }
    } catch (e) {
      print("Error marking messages as read: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Chat")),
        body: const Center(child: Text("Authentication error. Please log in again.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
          onPressed: () {
            _markMessagesAsRead();
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
                : const AssetImage('assets/images/avatar.png') as ImageProvider<Object>,
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
          if (widget.productDetails != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              color: const Color(0xFFe9f5d0),
              child: Row(
                children: [
                  if (widget.productDetails!['imageUrl'] != null && widget.productDetails!['imageUrl'].isNotEmpty)
                    Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(widget.productDetails!['imageUrl']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.productDetails!['name'] ?? 'Product',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'php ${widget.productDetails!['price'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF00A814),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isInitializingChat
                ? const Center(child: CircularProgressIndicator())
                : (_chatDocStream == null)
                    ? const Center(child: Text("Failed to initialize chat. Please try again."))
                    : StreamBuilder<DocumentSnapshot>(
                        stream: _chatDocStream,
                        builder: (context, chatDocSnapshot) {
                          if (chatDocSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (chatDocSnapshot.hasError) {
                            print("Chat Doc Stream Error: ${chatDocSnapshot.error}");
                            return Center(child: Text('Permission denied to read chat: ${chatDocSnapshot.error}\nPlease try again or contact support.',
                                textAlign: TextAlign.center, style: TextStyle(color: Colors.red[700], fontStyle: FontStyle.italic)));
                          }

                          final bool chatDocExists = chatDocSnapshot.hasData && chatDocSnapshot.data!.exists;

                          if (chatDocExists) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _markMessagesAsRead();
                            });

                            return StreamBuilder<QuerySnapshot>(
                              stream: _firestore
                                  .collection('chats')
                                  .doc(_chatRoomId)
                                  .collection('messages')
                                  .orderBy('timestamp')
                                  .snapshots(),
                              builder: (context, messagesSnapshot) {
                                if (messagesSnapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (messagesSnapshot.hasError) {
                                  print("Messages Stream Error: ${messagesSnapshot.error}");
                                  return Center(child: Text('Error loading messages: ${messagesSnapshot.error}\nPlease try again.',
                                      textAlign: TextAlign.center, style: TextStyle(color: Colors.red[700], fontStyle: FontStyle.italic)));
                                }
                                if (!messagesSnapshot.hasData || messagesSnapshot.data!.docs.isEmpty) {
                                  return Center(
                                      child: Text(
                                        "Send the first message!",
                                        style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                                      ));
                                }

                                final messages = messagesSnapshot.data!.docs.map((doc) => Message.fromMap(doc.data() as Map<String, dynamic>)).toList();
                                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                                return ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(16),
                                  itemCount: messages.length,
                                  itemBuilder: (context, index) {
                                    final message = messages[index];
                                    final bool isCurrentUser = currentUser != null && message.senderId == currentUser!.uid;

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
                            );
                          } else {
                            String initialMessageHint = widget.productDetails != null
                                ? 'Send a message about the ${widget.productDetails!['name']} to start the chat!'
                                : 'Start the conversation by sending the first message!';
                            return Center(child: Text(initialMessageHint, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),));
                          }
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
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.all(12),
        margin: alignment == Alignment.centerLeft
            ? const EdgeInsets.only(right: 80, top: 2, bottom: 2)
            : const EdgeInsets.only(left: 80, top: 2, bottom: 2),
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
    if (currentUser == null) {
      return Container();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF8cc543),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Attachment feature not yet implemented."),
                  backgroundColor: Colors.blueAccent,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
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
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            splashColor: Colors.white.withOpacity(0.3),
            highlightColor: Colors.white.withOpacity(0.1),
            icon: const Icon(Icons.send, color: Colors.black),
            onPressed: _messageController.text.trim().isEmpty ? null : _sendMessage,
          ),
        ],
      ),
    );
  }
}