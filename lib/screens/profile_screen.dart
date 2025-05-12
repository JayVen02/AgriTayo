import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'message_screen.dart';
import 'manage_product_screen.dart'; 
import 'package:agritayo/models/product.dart';
import 'edit_profile_screen.dart'; 
import 'product_form_screen.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text("Please log in to view your profile."),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Profile_ManageProducts.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                         style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                             foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: const BorderSide(color: Colors.green, width: 3),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                             minimumSize: Size.zero,
                          ),
                          child: const Text(
                            "Back",
                             style: TextStyle(
                               fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ),

                      GestureDetector(
                         onTap: () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(builder: (context) => const ChatScreen()),
                           );
                         },
                         child: Image.asset(
                           'assets/images/message.png',
                           width: 35,
                           height: 35,
                         ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).snapshots(),
                  builder: (context, snapshot) {
                    String displayUserName = currentUser!.displayName ?? 'No Name';
                    String displayUserProfileImageUrl = currentUser!.photoURL ?? '';

                    if (snapshot.connectionState == ConnectionState.waiting) {
                       return Column(
                         children: [
                           CircleAvatar(
                             radius: 60,
                             backgroundColor: Colors.purple[200],
                              backgroundImage: displayUserProfileImageUrl.isNotEmpty
                                 ? NetworkImage(displayUserProfileImageUrl) as ImageProvider<Object>
                                 : const AssetImage('assets/user_placeholder.png') as ImageProvider<Object>,
                             child: displayUserProfileImageUrl.isEmpty
                                 ? const Icon(Icons.person, size: 70, color: Colors.white)
                                 : null,
                           ),
                           const SizedBox(height: 20),
                           Text(displayUserName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(blurRadius: 2, color: Colors.black)], fontFamily: 'Futehodo-MaruGothic_1.00',)),
                           const SizedBox(height: 14),
                           const CircularProgressIndicator(strokeWidth: 2.0),
                         ],
                       );
                    }
                    if (snapshot.hasError) {
                       return Column(
                         children: [
                           CircleAvatar(
                             radius: 60,
                             backgroundColor: Colors.purple[200],
                              backgroundImage: displayUserProfileImageUrl.isNotEmpty
                                 ? NetworkImage(displayUserProfileImageUrl) as ImageProvider<Object>
                                 : const AssetImage('assets/user_placeholder.png') as ImageProvider<Object>,
                             child: displayUserProfileImageUrl.isEmpty
                                 ? const Icon(Icons.person, size: 70, color: Colors.white)
                                 : null,
                           ),
                           const SizedBox(height: 20),
                           Text(displayUserName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(blurRadius: 2, color: Colors.black)], fontFamily: 'Futehodo-MaruGothic_1.00',)),
                           const SizedBox(height: 10),
                           Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                         ],
                       );
                    }

                    final userData = snapshot.data!.data() as Map<String, dynamic>?;
                    String finalUserName = userData?['name'] ?? currentUser!.displayName ?? 'Name Not Set';
                    String finalUserLocation = userData?['location'] ?? 'Location Not Set';
                    String finalUserBio = userData?['bio'] ?? 'Bio Not Set';
                    String finalUserProfileImageUrl = userData?['profileImageUrl'] ?? currentUser!.photoURL ?? '';


                    return Column(
                      children: [
                         CircleAvatar(
                           radius: 60,
                           backgroundColor: Colors.purple[200],
                           backgroundImage: finalUserProfileImageUrl.isNotEmpty
                               ? NetworkImage(finalUserProfileImageUrl) as ImageProvider<Object>
                               : const AssetImage('assets/user_placeholder.png') as ImageProvider<Object>,
                           child: finalUserProfileImageUrl.isEmpty
                               ? const Icon(Icons.person, size: 70, color: Colors.white)
                               : null,
                         ),

                        const SizedBox(height: 20),

                        Text(
                          finalUserName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                            fontFamily: 'Futehodo-MaruGothic_1.00',
                          ),
                        ),
                        Text(
                          finalUserLocation,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            shadows: [Shadow(blurRadius: 1, color: Colors.black)],
                            fontFamily: 'Futehodo-MaruGothic_1.00',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          finalUserBio,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            shadows: [Shadow(blurRadius: 1, color: Colors.black)],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 40),

                Container(
                  width: 300,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3B340),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Manage Products",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [Shadow(blurRadius: 1, color: Colors.black)],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.deepOrange, style: BorderStyle.solid, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.transparent,
                        ),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                                .collection('products')
                                .where('sellerId', isEqualTo: currentUser!.uid)
                                .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator(strokeWidth: 2.0));
                            }
                            if (snapshot.hasError) {
                              return Center(child: Text('Error loading products: ${snapshot.error}'));
                            }
                               if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                               return Row(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                    _buildAddButton(context),
                                 ],
                               );
                               }

                            final userProducts = snapshot.data!.docs.map((doc) => Product.fromDocument(doc)).toList();

                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ...userProducts.map((product) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                      child: InkWell(
                                         onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => ProductFormScreen(product: product)),
                                            );
                                         },
                                        child: CircleAvatar(
                                          radius: 25,
                                          backgroundColor: Colors.grey[300],
                                          backgroundImage: product.imageUrl.isNotEmpty
                                              ? NetworkImage(product.imageUrl) as ImageProvider<Object>
                                              : const AssetImage('assets/product_placeholder.png') as ImageProvider<Object>,
                                          child: product.imageUrl.isEmpty
                                              ? const Icon(Icons.shopping_bag_outlined, size: 30, color: Colors.black54)
                                              : null,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  _buildAddButton(context),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                 Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                 );
              },
              style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(30),
                   side: const BorderSide(color: Color(0xFFF3B340), width: 3),
                 ),
                 padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                 minimumSize: Size.zero,
               ),
              child: const Text(
                "Edit",
                 style: TextStyle(
                   fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
     return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
       child: InkWell(
          onTap: () {
             Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductFormScreen(product: null)),
             );
          },
         child: CircleAvatar(
           radius: 25,
           backgroundColor: Colors.grey[300],
           child: const Icon(Icons.add, size: 30, color: Colors.black54),
         ),
       ),
     );
  }
}