import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agritayo/models/product.dart';
import 'profile_screen.dart';
// import 'package:agritayo/screens/private_chat_screen.dart'; 
import 'package:url_launcher/url_launcher.dart'; 

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
                                  : const AssetImage("assets/images/avatar.png") as ImageProvider<Object>,
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
                          child: const Center(child: Text("Demand Graph Here")),
                        ),
                        const SizedBox(height: 8),
                        const Text("Crops Ranking for This Month  \n              (Tap to expand)"),
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
                            Text("Prices", textAlign: TextAlign.right),
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
            Expanded(
               child: Text(
                 product.name,
                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                 overflow: TextOverflow.ellipsis,
               ),
            ),
            Text(
              "php ${product.price}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? sellerData;
  bool isLoading = true;
  // bool isSendingMessage = false;
  int retryCount = 0;
  final int maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _loadSellerDetails();
  }

   @override
  void dispose() {
    super.dispose();
  }

  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.isEmpty) {
      return 'Name';
    }
    final parts = fullName.split(' ');
    return parts.isNotEmpty ? parts[0] : 'Name';
  }

  Future<void> _loadSellerDetails() async {
    if (!mounted) return;

    if (retryCount >= maxRetries) {
       if(mounted) {
           setState(() {
             isLoading = false;
             sellerData = null;
           });
       }
      return;
    }

    if(mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      if (widget.product.sellerId.isEmpty) {
        if (mounted) {
          setState(() {
            sellerData = null;
            isLoading = false;
          });
        }
        print("Seller ID is empty for product ${widget.product.id}");
        return;
      }

      final productDocFuture = _firestore.collection('products').doc(widget.product.id).get();
      final userDocFuture = _firestore.collection('users').doc(widget.product.sellerId).get();
      final publicProfileQueryFuture = _firestore.collection('public_profiles')
           .where('userId', isEqualTo: widget.product.sellerId)
           .limit(1)
           .get();

      final results = await Future.wait<dynamic>([
          productDocFuture,
          userDocFuture,
          publicProfileQueryFuture,
      ]);

      DocumentSnapshot productDoc = results[0] as DocumentSnapshot;
      DocumentSnapshot userDoc = results[1] as DocumentSnapshot;
      QuerySnapshot publicProfileQuery = results[2] as QuerySnapshot;

      Map<String, dynamic> tempSellerData = {};

      Map<String, dynamic>? productDataMap = productDoc.data() as Map<String, dynamic>?;
      Map<String, dynamic>? productSellerInfo = productDataMap?['sellerInfo'] as Map<String, dynamic>?;


      if (productSellerInfo != null) {
           tempSellerData.addAll(productSellerInfo);
      }

      if (userDoc.exists) {
           Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
           if (userData != null) {
               tempSellerData.addAll(userData);
           }
      }

      if (publicProfileQuery.docs.isNotEmpty) {
           Map<String, dynamic>? publicProfileData = publicProfileQuery.docs.first.data() as Map<String, dynamic>?;
           if (publicProfileData != null) {
               tempSellerData.addAll(publicProfileData);
           }
      }

      Map<String, dynamic> finalSellerData = {};

      finalSellerData['name'] = tempSellerData['name'] ?? tempSellerData['displayName'] ?? tempSellerData['fullName'];

       finalSellerData['profileImageUrl'] = tempSellerData['profileImageUrl'] ?? tempSellerData['photoURL'] ?? tempSellerData['avatarUrl'];

      finalSellerData['location'] = tempSellerData['location'] ?? tempSellerData['address'] ?? tempSellerData['city'];

      finalSellerData['contactNumber'] = tempSellerData['contactNumber'] ?? tempSellerData['phone'] ?? tempSellerData['phoneNumber'] ?? tempSellerData['contact'];

      finalSellerData['email'] = tempSellerData['email'] ?? tempSellerData['emailAddress'];

       bool hasAnyData = finalSellerData['name'] != null || finalSellerData['location'] != null || finalSellerData['contactNumber'] != null || finalSellerData['email'] != null || finalSellerData['profileImageUrl'] != null;
       Map<String, dynamic>? dataToSet = hasAnyData ? finalSellerData : null;


      if (mounted) {
        setState(() {
          sellerData = dataToSet;
          isLoading = false;
          retryCount = 0;
        });
      }

    } catch (e) {
      print("Error fetching seller details (attempt ${retryCount + 1}): $e");
      if (!mounted) return;

      retryCount++;
      int delayMs = 1000 * (1 << (retryCount - 1));

      if (retryCount <= maxRetries) {
          Future.delayed(Duration(milliseconds: delayMs), () {
            if (mounted) {
              _loadSellerDetails();
            }
          });
      } else {
         if (mounted) {
           setState(() {
              isLoading = false;
              sellerData = null;
           });
         }
      }
    }
  }

  String _getSellerName() {
    if (sellerData == null) return 'Unnamed Seller';
    return sellerData!['name'] ?? 'Unnamed Seller';
  }

  String _getSellerLocation() {
    if (sellerData == null) return 'Location not available';
    return sellerData!['location'] ?? 'Location not set';
  }

  String? _getSellerContactNumber() {
    if (sellerData == null) return null;
    return sellerData!['contactNumber'];
  }

   String? _getSellerEmail() {
    if (sellerData == null) return null;
    return sellerData!['email'];
  }

  String? _getSellerPhotoUrl() {
    if (sellerData == null) return null;
    return sellerData!['profileImageUrl'];
  }

  Future<void> _handleMessageSeller() async {
    if (isLoading || sellerData == null /* || isSendingMessage */) {
        if (sellerData == null && !isLoading) {
             ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Cannot message seller: Information not available."),
                  backgroundColor: Colors.red,
                ),
              );
        }
        return;
    }

    if (!mounted) return;

    // setState(() { isSendingMessage = true; }); 

    try {
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please log in to chat with the seller."),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      if (currentUser!.uid == widget.product.sellerId) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("You cannot message yourself."),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // --- TEMPORARY : Use url_launcher for SMS ---
      final sellerPhoneNumber = _getSellerContactNumber();

      if (sellerPhoneNumber == null || sellerPhoneNumber.isEmpty) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Seller's contact number is not available."),
                backgroundColor: Colors.orange,
              ),
            );
         }
         return;
      }

      final smsUri = Uri(
         scheme: 'sms',
         path: sellerPhoneNumber,
         queryParameters: {'body': 'Hi, I am interested in your ${Uri.encodeComponent(widget.product.name)}.'},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Could not launch messaging app."),
                backgroundColor: Colors.red,
              ),
            );
        }
      }

      // --- internal chat logic ---
      /*
      String chatId = currentUser!.uid.compareTo(widget.product.sellerId) < 0
          ? '${currentUser!.uid}_${widget.product.sellerId}'
          : '${widget.product.sellerId}_${currentUser!.uid}';

      final chatDocRef = _firestore.collection('chats').doc(chatId);
      DocumentSnapshot chatDoc = await chatDocRef.get();

      if (!chatDoc.exists) {
        WriteBatch batch = _firestore.batch();

        batch.set(chatDocRef, {
          'participants': [currentUser!.uid, widget.product.sellerId],
          'lastMessage': 'Interested in your ${widget.product.name}',
          'lastMessageTimestamp': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'relatedProduct': {
              'id': widget.product.id,
              'name': widget.product.name,
              'price': widget.product.price,
              'imageUrl': widget.product.imageUrl,
          },
        });

        batch.set(chatDocRef.collection('messages').doc(), {
          'senderId': currentUser!.uid,
          'text': 'Hi, I am interested in your ${widget.product.name}. Is it still available?',
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });

        await batch.commit();
      }

       if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PrivateChatScreen(
            recipientUserId: widget.product.sellerId,
            recipientUserName: _getSellerName(),
            recipientPhotoUrl: _getSellerPhotoUrl() ?? '',
            productDetails: {
              'id': widget.product.id,
              'name': widget.product.name,
              'price': widget.product.price,
              'imageUrl': widget.product.imageUrl,
            },
          ),
        ),
      );
      */

    } catch (e) {
      print("Error attempting to message seller via SMS: $e");
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text("Failed to open messaging app: $e"),
             backgroundColor: Colors.red,
           ),
         );
      }
    } finally {
      // if (mounted) { setState(() { isSendingMessage = false; }); }
    }
  }


  @override
  Widget build(BuildContext context) {
    final String? userPhotoUrl = currentUser?.photoURL;

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
                            side: const BorderSide(color: Colors.green, width: 1.5),
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
                                Text(currentUser?.displayName ?? 'Guest', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                                const Text("Farmer", style: TextStyle(fontSize: 12, color: Colors.black)),
                              ],
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: userPhotoUrl != null && userPhotoUrl.isNotEmpty
                                  ? NetworkImage(userPhotoUrl) as ImageProvider<Object>
                                  : const AssetImage('assets/images/avatar.png') as ImageProvider<Object>,
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column( 
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Padding(
                             padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
                             child: Container(
                                height: 200,
                                width: double.infinity,
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
                                     ? const Center(child: Text("No Image Available", style: TextStyle(color: Colors.grey)))
                                     : null,
                             ),
                           ),

                           Expanded( 
                             child: SingleChildScrollView( 
                               padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Row(
                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Expanded(
                                         child: Text(
                                           widget.product.name,
                                           style: const TextStyle(
                                             fontSize: 24,
                                             fontWeight: FontWeight.bold,
                                             color: Colors.black
                                           ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                         ),
                                       ),
                                       const SizedBox(width: 8),
                                       Container(
                                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                         decoration: BoxDecoration(
                                           color: const Color(0xFFFcb21d).withOpacity(0.2),
                                           borderRadius: BorderRadius.circular(12),
                                           border: Border.all(color: const Color(0xFFFcb21d), width: 1.5),
                                         ),
                                         child: Text(
                                           "php ${widget.product.price}",
                                           style: const TextStyle(
                                             fontSize: 18,
                                             fontWeight: FontWeight.w600,
                                             color: Color(0xFF00A814)
                                           ),
                                         ),
                                       ),
                                     ],
                                   ),
                                   const SizedBox(height: 16),
                                   const Text(
                                      "Description",
                                      style: TextStyle(
                                         fontSize: 18,
                                         fontWeight: FontWeight.w600,
                                         color: Colors.black87
                                       ),
                                   ),
                                    const Divider(thickness: 1, color: Color(0xFFECECEC)),
                                   Container(
                                     padding: const EdgeInsets.all(12),
                                     decoration: BoxDecoration(
                                       color: Colors.grey[100],
                                       borderRadius: BorderRadius.circular(8),
                                     ),
                                     child: Text(
                                       widget.product.description.isNotEmpty ? widget.product.description : 'No description available.',
                                       style: const TextStyle(fontSize: 15, color: Colors.black87),
                                     ),
                                   ),
                                   const SizedBox(height: 20),
                                   const Row(
                                     children: [
                                       Icon(Icons.person, size: 18, color: Color(0xFF00A814)),
                                       SizedBox(width: 6),
                                       Text(
                                         "Seller Information",
                                         style: TextStyle(
                                           fontSize: 18,
                                           fontWeight: FontWeight.w600,
                                           color: Colors.black87
                                         ),
                                       ),
                                     ],
                                   ),
                                   const Divider(thickness: 1, color: Color(0xFFECECEC)),
                                   if (isLoading)
                                     const Padding(
                                       padding: EdgeInsets.symmetric(vertical: 16.0),
                                       child: Center(
                                         child: Column(
                                           children: [
                                             CircularProgressIndicator(
                                               strokeWidth: 2.0,
                                               valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00A814)),
                                             ),
                                             SizedBox(height: 8),
                                             Text("Loading seller information...",
                                               style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)
                                             ),
                                           ],
                                         ),
                                       ),
                                     )
                                   else if (sellerData != null)
                                     Container(
                                       padding: const EdgeInsets.all(12),
                                       decoration: BoxDecoration(
                                         color: Colors.white,
                                         borderRadius: BorderRadius.circular(8),
                                         border: Border.all(color: const Color(0xFFECECEC)),
                                       ),
                                       child: Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                           Row(
                                             children: [
                                               CircleAvatar(
                                                 radius: 20,
                                                  backgroundColor: Colors.grey[300],
                                                 backgroundImage: _getSellerPhotoUrl() != null && _getSellerPhotoUrl()!.isNotEmpty
                                                     ? NetworkImage(_getSellerPhotoUrl()!) as ImageProvider<Object>
                                                     : const AssetImage('assets/images/avatar.png') as ImageProvider<Object>,
                                               ),
                                               const SizedBox(width: 12),
                                               Expanded(
                                                 child: Column(
                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                   children: [
                                                     Text(
                                                       _getSellerName(),
                                                       style: const TextStyle(
                                                         fontSize: 16,
                                                         fontWeight: FontWeight.w600,
                                                         color: Colors.black87
                                                       ),
                                                        overflow: TextOverflow.ellipsis,
                                                    ),
                                                     const Text(
                                                       "Verified Seller",
                                                       style: TextStyle(
                                                         fontSize: 12,
                                                         color: Color(0xFF00A814),
                                                         fontWeight: FontWeight.w500
                                                       ),
                                                     ),
                                                   ],
                                                 ),
                                               ),
                                             ],
                                           ),
                                           const SizedBox(height: 12),
                                           Row(
                                             children: [
                                               const Icon(Icons.location_on, size: 16, color: Colors.blueGrey),
                                               const SizedBox(width: 6),
                                               Expanded(
                                                 child: Text(
                                                   _getSellerLocation(),
                                                   style: TextStyle(fontSize: 14, color: Colors.blueGrey[700]),
                                                   overflow: TextOverflow.ellipsis,
                                                 ),
                                               ),
                                             ],
                                           ),
                                           if (_getSellerContactNumber() != null && _getSellerContactNumber()!.isNotEmpty)
                                             Padding(
                                               padding: const EdgeInsets.only(top: 8.0),
                                               child: Row(
                                                 children: [
                                                   const Icon(Icons.phone, size: 16, color: Colors.blueGrey),
                                                   const SizedBox(width: 6),
                                                   Text(
                                                     _getSellerContactNumber()!,
                                                     style: TextStyle(fontSize: 14, color: Colors.blueGrey[700]),
                                                      overflow: TextOverflow.ellipsis,
                                                   ),
                                                 ],
                                               ),
                                             ),
                                            if (_getSellerEmail() != null && _getSellerEmail()!.isNotEmpty)
                                             Padding(
                                               padding: const EdgeInsets.only(top: 8.0),
                                               child: Row(
                                                 children: [
                                                   const Icon(Icons.email, size: 16, color: Colors.blueGrey),
                                                   const SizedBox(width: 6),
                                                   Text(
                                                     _getSellerEmail()!,
                                                     style: TextStyle(fontSize: 14, color: Colors.blueGrey[700]),
                                                      overflow: TextOverflow.ellipsis,
                                                   ),
                                                 ],
                                               ),
                                             ),
                                         ],
                                       ),
                                     )
                                   else
                                     Container(
                                       padding: const EdgeInsets.all(12),
                                       decoration: BoxDecoration(
                                         color: Colors.red[50],
                                         borderRadius: BorderRadius.circular(8),
                                         border: Border.all(color: Colors.red[100]!),
                                       ),
                                       child: const Row(
                                         children: [
                                           Icon(Icons.info_outline, color: Colors.red),
                                           SizedBox(width: 8),
                                           Expanded(
                                             child: Text(
                                               "Seller information not available",
                                               style: TextStyle(
                                                 fontSize: 14,
                                                 fontStyle: FontStyle.italic,
                                                 color: Colors.red
                                               ),
                                                overflow: TextOverflow.ellipsis,
                                             ),
                                           ),
                                         ],
                                       ),
                                     ),
                                    const SizedBox(height: 20),

                                    if (!isLoading && sellerData == null && retryCount < maxRetries)
                                       Center(
                                         child: TextButton(
                                           onPressed: () {
                                             retryCount = 0;
                                             _loadSellerDetails();
                                             ScaffoldMessenger.of(context).showSnackBar(
                                               const SnackBar(
                                                 content: Text("Retrying to load seller information..."),
                                                 backgroundColor: Colors.blue,
                                                 duration: Duration(seconds: 2),
                                               ),
                                             );
                                           },
                                           style: TextButton.styleFrom(
                                             foregroundColor: const Color(0xFF00A814),
                                              padding: EdgeInsets.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                           ),
                                           child: const Row(
                                             mainAxisSize: MainAxisSize.min,
                                             children: [
                                               Icon(Icons.refresh, size: 16),
                                               SizedBox(width: 4),
                                               Text("Retry loading seller info"),
                                             ],
                                           ),
                                         ),
                                       ),
                                    if (!isLoading && sellerData == null && retryCount >= maxRetries)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Center(
                                          child: Text(
                                            "Could not load seller info.",
                                            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.red[700]),
                                          ),
                                        ),
                                      ),

                                 ],
                               ),
                             ),
                           ),

                           Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                             child: ElevatedButton(
                                onPressed: isLoading || sellerData == null || _getSellerContactNumber() == null || _getSellerContactNumber()!.isEmpty || currentUser == null || currentUser?.uid == widget.product.sellerId
                                  ? null
                                  : _handleMessageSeller,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00A814),
                                  disabledBackgroundColor: Colors.grey.shade400,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  minimumSize: const Size(double.infinity, 0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.message, color: Colors.white),
                                    const SizedBox(width: 10),
                                    const Text(
                                      "Message Seller",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white
                                      ),
                                    ),
                                  ],
                                ),
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