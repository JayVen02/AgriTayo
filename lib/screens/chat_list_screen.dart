import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'private_chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to view chats.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Chats', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFa2d56b),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chats')
            .where('participants', arrayContains: currentUser!.uid)
            .orderBy('lastMessageTimestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading chats: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No conversations yet.'));
          }

          final chats = snapshot.data!.docs;

          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final chatDoc = chats[index];
              final chatData = chatDoc.data() as Map<String, dynamic>;

              final List<dynamic> participants = chatData['participants'] ?? [];
              final String otherUserId = participants.firstWhere(
                (uid) => uid != currentUser!.uid,
                orElse: () => ''
              );

              final String lastMessage = chatData['lastMessage'] ?? 'No messages yet.';

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  String displayOtherUserName = otherUserId.isNotEmpty ? 'Loading...' : 'Unknown User';
                  String displayOtherUserPhotoUrl = '';
                  IconData icon = Icons.person;

                  if (userSnapshot.connectionState == ConnectionState.done && 
                      userSnapshot.hasData && 
                      userSnapshot.data!.exists) {
                    final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                    displayOtherUserName = userData?['name'] ?? 'Unnamed User ($otherUserId)';
                    displayOtherUserPhotoUrl = userData?['profileImageUrl'] ?? '';
                  } else if (userSnapshot.hasError) {
                    displayOtherUserName = 'Error User ($otherUserId)';
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: displayOtherUserPhotoUrl.isNotEmpty
                          ? NetworkImage(displayOtherUserPhotoUrl) as ImageProvider<Object>
                          : const AssetImage('assets/user_placeholder.png') as ImageProvider<Object>,
                      child: displayOtherUserPhotoUrl.isEmpty ? Icon(icon, color: Colors.black54) : null,
                    ),
                    title: Text(displayOtherUserName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrivateChatScreen(
                            recipientUserId: otherUserId,
                            recipientUserName: displayOtherUserName,
                            recipientPhotoUrl: displayOtherUserPhotoUrl,
                          ),
                        ),
                      );
                    },
                  );
                }
              );
            },
          );
        },
      ),
    );
  }
}