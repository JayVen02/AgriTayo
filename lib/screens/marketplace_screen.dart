import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agritayo/models/product.dart';
import 'message_screen.dart';
import 'profile_screen.dart';

class MarketplaceListView extends StatefulWidget {
  const MarketplaceListView({super.key});

  @override
  _MarketplaceListViewState createState() => _MarketplaceListViewState();
}

class _MarketplaceListViewState extends State<MarketplaceListView> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.isEmpty) {
      return 'Name';
    }
    final parts = fullName.split(' ');
    return parts.isNotEmpty ? parts[0] : 'Name'; 
  }

  @override
  Widget build(BuildContext context) {
    final String? userPhotoUrl = currentUser?.photoURL;
    final String firstName = _getFirstName(currentUser?.displayName);


    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/AgriMarket.png',
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
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: const StadiumBorder(),
                        ),
                        child: const Text("Back"),
                      ),
                      GestureDetector(
                        onTap: () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(builder: (context) => const ProfileScreen()), 
                           );
                        },
                        child: Row( 
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: userPhotoUrl != null && userPhotoUrl.isNotEmpty
                                  ? NetworkImage(userPhotoUrl) as ImageProvider<Object>
                                  : const AssetImage("assets/user.jpg") as ImageProvider<Object>,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(firstName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const Text("Farmer", style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: () {
                     Navigator.pushNamed(context, '/graph');
                  },
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.yellow[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 100,
                          color: Colors.orange[300],
                          child: const Center(child: Text("Graph Here")),
                        ),
                        const SizedBox(height: 8),
                        const Text("Demand for Potatoes"),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.yellow[700]!),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: "Search",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Item", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("Prices\n(As of Date here)", textAlign: TextAlign.right),
                          ],
                        ),
                        const Divider(),

                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('products').snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Center(child: Text('Error loading items: ${snapshot.error}'));
                              }
                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return const Center(child: Text('No marketplace items found.'));
                              }

                              final products = snapshot.data!.docs.map((doc) => Product.fromDocument(doc)).toList();

                              return ListView.separated(
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  final product = products[index];
                                  return _buildItemRow(product, context);
                                },
                                separatorBuilder: (context, index) => const Divider(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(Product product, BuildContext context) {
    return InkWell(
      onTap: () {
        print("${product.name} tapped");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MarketplaceDetailView(product: product)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(product.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Text(product.price, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class MarketplaceDetailView extends StatefulWidget { 
  final Product product;

  const MarketplaceDetailView({super.key, required this.product});

  @override
  _MarketplaceDetailViewState createState() => _MarketplaceDetailViewState(); 
}

class _MarketplaceDetailViewState extends State<MarketplaceDetailView> {
   final User? currentUser = FirebaseAuth.instance.currentUser;

  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.isEmpty) {
      return 'Name';
    }
    final parts = fullName.split(' ');
    return parts.isNotEmpty ? parts[0] : 'Name';
  }

  @override
  Widget build(BuildContext context) {
    final String? userPhotoUrl = currentUser?.photoURL;
    final String firstName = _getFirstName(currentUser?.displayName);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/AgriMarket.png',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Colors.green),
                          ),
                        ),
                        child: const Text(
                          "Back",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileScreen()), 
                          );
                        },
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(firstName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                                const Text("Farmer", style: TextStyle(fontSize: 12, color: Colors.black)),
                              ],
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: userPhotoUrl != null && userPhotoUrl.isNotEmpty
                                  ? NetworkImage(userPhotoUrl) as ImageProvider<Object>
                                  : const AssetImage('assets/user.jpg') as ImageProvider<Object>,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Center(
                    child: Container(
                      width: 370,
                      height: 600,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFFcb21d), width: 10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 20,
                            left: 20,
                            right: 20,
                            height: 200,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8E8E8),
                                border: Border.all(color: const Color(0xFFECECEC), width: 5),
                                borderRadius: BorderRadius.circular(16),
                                image: widget.product.imageUrl.isNotEmpty 
                                    ? DecorationImage(
                                        image: NetworkImage(widget.product.imageUrl),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: widget.product.imageUrl.isEmpty
                                  ? const Center(child: Text("No Image Available"))
                                  : null,
                            ),
                          ),
                          Positioned(
                            top: 240,
                            left: 20,
                            right: 20,
                            bottom: 180,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.product.name, 
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.product.price,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    widget.product.description,
                                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Positioned(
                            bottom: 15,
                            left: 0,
                            right: 0,
                            child: Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => Center(
                                        child: AlertDialog(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          content: Text(
                                            "You have purchased ${widget.product.name}", 
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                            textAlign: TextAlign.center,
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(),
                                              child: const Text("OK", style: TextStyle(color: Colors.white)),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00A814),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                                  ),
                                  child: const Text("Buy Now", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const ChatScreen()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFC6C6C6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 12),
                                  ),
                                  child: const Text("Message", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00B700))),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}