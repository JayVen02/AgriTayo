import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agritayo/screens/private_chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        final User? currentUser = authSnapshot.data;

        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (currentUser == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Chats', style: TextStyle(color: Colors.black)),
              backgroundColor: const Color(0xFFa2d56b),
              elevation: 0,
            ),
            body: const Center(child: Text("Please log in to view chats.")),
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
                .collection('users')
                .doc(currentUser.uid)
                .collection('userChats')
                .orderBy('lastMessageTimestamp', descending: true)
                .snapshots(),
            builder: (context, userChatsSnapshot) {
              if (userChatsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (userChatsSnapshot.hasError) {
                 print("User Chats Query Error: ${userChatsSnapshot.error}");
                return Center(child: Text('Error loading conversations: ${userChatsSnapshot.error}', textAlign: TextAlign.center));
              }
              if (!userChatsSnapshot.hasData || userChatsSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No conversations yet.'));
              }

              final userChatDocs = userChatsSnapshot.data!.docs;

              return ListView.separated(
                itemCount: userChatDocs.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final userChatDoc = userChatDocs[index];
                  final String chatId = userChatDoc.id;
                  return FutureBuilder<DocumentSnapshot>(
                    future: _firestore.collection('chats').doc(chatId).get(),
                    builder: (context, chatDocSnapshot) {
                      if (chatDocSnapshot.connectionState == ConnectionState.waiting) {
                        return ListTile(
                           leading: CircleAvatar(radius: 24, backgroundColor: Colors.grey[300]),
                           title: Text('Loading Chat...'),
                           subtitle: Text(''),
                        );
                      }

                      if (chatDocSnapshot.hasError || !chatDocSnapshot.hasData || !chatDocSnapshot.data!.exists) {
                         print("Error fetching chat $chatId: ${chatDocSnapshot.error}");
                        return ListTile(
                           leading: CircleAvatar(radius: 24, backgroundColor: Colors.grey[300]),
                           title: Text('Error Loading Chat'),
                           subtitle: Text(''),
                        );
                      }

                      final chatData = chatDocSnapshot.data!.data() as Map<String, dynamic>;

                      final List<dynamic> participants = chatData['participants'] ?? [];
                      final String otherUserId = participants.firstWhere(
                        (uid) => uid != currentUser.uid,
                        orElse: () => ''
                      );

                      final String lastMessage = chatData['lastMessage'] ?? 'No messages yet.';
                      final int unreadCount = (chatData['unreadCount_${currentUser.uid}'] as num?)?.toInt() ?? 0;
                      final bool hasUnread = unreadCount > 0;
                      return FutureBuilder<DocumentSnapshot>(
                        future: _firestore.collection('users').doc(otherUserId).get(),
                        builder: (context, userSnapshot) {
                          String displayOtherUserName = 'Loading...';
                          String displayOtherUserPhotoUrl = '';

                          if (userSnapshot.connectionState == ConnectionState.done) {
                             if (userSnapshot.hasData && userSnapshot.data!.exists) {
                                final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                                displayOtherUserName = userData?['name'] ?? 'Unnamed User';
                                displayOtherUserPhotoUrl = userData?['profileImageUrl'] ?? '';
                             } else {
                                displayOtherUserName = 'Unknown User';
                             }
                          } else if (userSnapshot.connectionState == ConnectionState.waiting) {
                             displayOtherUserName = 'Loading...';
                          } else if (userSnapshot.hasError) {
                             print("User Snapshot Error for $otherUserId: ${userSnapshot.error}");
                            displayOtherUserName = 'Error Loading User';
                          }


                          return ListTile(
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: displayOtherUserPhotoUrl.isNotEmpty
                                  ? NetworkImage(displayOtherUserPhotoUrl) as ImageProvider<Object>
                                  : const AssetImage('assets/images/avatar.png') as ImageProvider<Object>,
                            ),
                            title: Text(
                               displayOtherUserName,
                               style: TextStyle(
                                   fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                                   color: hasUnread ? Colors.black : Colors.black54,
                               ),
                            ),
                            subtitle: Text(
                               lastMessage,
                               maxLines: 1,
                               overflow: TextOverflow.ellipsis,
                               style: TextStyle(
                                 fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                                 color: hasUnread ? Colors.black87 : Colors.grey,
                               ),
                            ),
                            trailing: hasUnread
                                ? Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                : null,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PrivateChatScreen(
                                    chatId: chatId,
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
              );
            },
          ),
        );
      },
    );
  }
}