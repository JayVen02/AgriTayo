import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'chat_list_screen.dart';
import 'manage_product_detail_screen.dart';
import 'product_form_screen.dart';
import 'package:agritayo/models/product.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  bool _isEditing = false;
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _locationFocus = FocusNode();
  final FocusNode _bioFocus = FocusNode();
  final FocusNode _contactNumberFocus = FocusNode(); 
  final FocusNode _emailFocus = FocusNode();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController(); 
  final TextEditingController _emailController = TextEditingController();

  String _currentName = 'Loading...';
  String _currentLocation = 'Location Not Set';
  String _currentBio = 'Bio Not Set';
  String _currentPhotoUrl = '';
  String _currentContactNumber = 'Contact Not Set'; 
  String _currentEmail = 'Email Not Set';

  bool _initialDataLoaded = false;
  StreamSubscription<DocumentSnapshot>? _profileSubscription;

  @override
  void initState() {
    super.initState();
    _listenToProfileStream();
  }

  void _listenToProfileStream() {
    if (currentUser == null) return;

    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);

    _profileSubscription = userDocRef.snapshots().listen((snapshot) {
      if (mounted) {
        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data()!;
          setState(() {
            _currentName =
                data['name']?.toString() ?? currentUser!.displayName ?? 'No Name';
            _currentLocation = data['location']?.toString() ?? 'Location Not Set';
            _currentBio = data['bio']?.toString() ?? 'Bio Not Set';
            _currentPhotoUrl =
                data['profileImageUrl']?.toString() ?? currentUser!.photoURL ?? '';
            _currentContactNumber = data['contactNumber']?.toString() ?? 'Contact Not Set';
            _currentEmail = data['email']?.toString() ?? currentUser!.email ?? 'Email Not Set';
            _initialDataLoaded = true;
          });
        } else {
          setState(() {
            _currentName = currentUser!.displayName ?? 'No Name';
            _currentLocation = 'Location Not Set';
            _currentBio = 'Bio Not Set';
            _currentPhotoUrl = currentUser!.photoURL ?? '';
            _currentContactNumber = 'Contact Not Set';
            _currentEmail = currentUser!.email ?? 'Email Not Set';
            _initialDataLoaded = true;
          });
        }
      }
    }, onError: (error) {
      if (mounted) {
        setState(() {
          _currentName = currentUser!.displayName ?? 'Error loading name';
          _currentLocation = 'Error loading location';
          _currentBio = 'Error loading bio';
          _currentPhotoUrl = currentUser!.photoURL ?? '';
          _currentContactNumber = 'Error loading contact';
          _currentEmail = currentUser!.email ?? 'Error loading email';
          _initialDataLoaded = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load profile data: $error')),
          );
      }
    });
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    _nameController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _nameFocus.dispose();
    _locationFocus.dispose();
    _bioFocus.dispose();
    _contactNumberFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final newName = _nameController.text.trim();
    final newLocation = _locationController.text.trim();
    final newBio = _bioController.text.trim();
    final newContactNumber = _contactNumberController.text.trim();
    final newEmail = _emailController.text.trim();

    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name is required')),
      );
      return;
    }

    if (newName != _currentName ||
        newLocation != _currentLocation ||
        newBio != _currentBio ||
        newContactNumber != _currentContactNumber ||
        newEmail != _currentEmail) {
      try {
         final profileData = {
            'name': newName,
            'location': newLocation,
            'bio': newBio,
            'contactNumber': newContactNumber,
            'email': newEmail.isNotEmpty ? newEmail : currentUser!.email ?? '',
          };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .set(profileData, SetOptions(merge: true)); 

        if (currentUser!.displayName != newName) {
          await currentUser!.updateDisplayName(newName);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } on FirebaseException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile: ${e.message}')),
          );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
    }

    setState(() => _isEditing = false);
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });

    _nameController.text = _currentName == 'No Name' ? '' : _currentName;
    _locationController.text = _currentLocation == 'Location Not Set' ? '' : _currentLocation;
    _bioController.text = _currentBio == 'Bio Not Set' ? '' : _currentBio;
    _contactNumberController.text = _currentContactNumber == 'Contact Not Set' ? '' : _currentContactNumber; 
    _emailController.text = _currentEmail == 'Email Not Set' ? '' : _currentEmail;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isEditing) {
        FocusScope.of(context).requestFocus(_nameFocus);
      }
    });
  }

  void _cancelEditing() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your profile.')),
      );
    }

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/Profile_ManageProducts.png',
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
              bottom: true,
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: const BorderSide(
                                  color: Colors.green, width: 3),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            minimumSize: Size.zero,
                          ),
                          child: const Text(
                            'Back',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (_isEditing)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: _saveProfile,
                                style: _editButtonStyle(),
                                child: const Text('Save',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 5),
                              ElevatedButton(
                                onPressed: _cancelEditing,
                                style: _editButtonStyle(),
                                child: const Text('Cancel',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          )
                        else
                          ElevatedButton(
                            onPressed: _startEditing,
                            style: _editButtonStyle(),
                            child: const Text('Edit',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: ListView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.manual,
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom + 80,
                      ),
                      children: [
                        if (!_initialDataLoaded)
                          const Center(child: CircularProgressIndicator())
                        else
                          Column(
                            children: [
                              _isEditing
                                  ? _buildEditableProfileSection(
                                      photoUrl: _currentPhotoUrl,
                                    )
                                  : _buildProfileSection(
                                      name: _currentName,
                                      location: _currentLocation,
                                      bio: _currentBio,
                                      photoUrl: _currentPhotoUrl,
                                      contactNumber: _currentContactNumber,
                                      email: _currentEmail,
                                    ),
                              const SizedBox(height: 40),
                              _buildManageProductsBox(),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _editButtonStyle() => ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: Color(0xFFF3B340), width: 3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        minimumSize: Size.zero,
      );

  Widget _buildProfileSection({
    required String name,
    required String location,
    required String bio,
    required String photoUrl,
    required String contactNumber,
    required String email,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.purple[200],
          backgroundImage: photoUrl.isNotEmpty
              ? NetworkImage(photoUrl) as ImageProvider<Object>
              : const AssetImage('assets/user_placeholder.png')
                  as ImageProvider<Object>,
          child: photoUrl.isEmpty
              ? const Icon(Icons.person, size: 70, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              shadows: [
                Shadow(blurRadius: 2, color: Colors.white, offset: Offset(1, 1))
              ],
              fontFamily: 'Futehodo-MaruGothic_1.00',
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          location,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            shadows: [
              Shadow(
                  blurRadius: 1, color: Colors.white, offset: Offset(0.5, 0.5))
            ],
            fontFamily: 'Futehodo-MaruGothic_1.00',
          ),
        ),
        const SizedBox(height: 10),
        if (contactNumber.isNotEmpty && contactNumber != 'Contact Not Set')
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.phone, size: 18, color: Colors.black54),
                const SizedBox(width: 8),
                Text(
                  contactNumber,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                     shadows: [
                        Shadow(blurRadius: 0.5, color: Colors.white, offset: Offset(0.25, 0.25))
                     ],
                  ),
                ),
              ],
            ),
          ),
        if (email.isNotEmpty && email != 'Email Not Set')
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.email, size: 18, color: Colors.black54),
                const SizedBox(width: 8),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                     shadows: [
                        Shadow(blurRadius: 0.5, color: Colors.white, offset: Offset(0.25, 0.25))
                     ],
                  ),
                   overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
         const SizedBox(height: 10),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Text(
            bio,
            style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                shadows: [
                  Shadow(
                      blurRadius: 1,
                      color: Colors.white,
                      offset: Offset(0.5, 0.5))
                ]),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatListScreen()),
              );
            },
            child: Image.asset(
              'assets/images/messenger.png',
              width: 50,
              height: 50,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableProfileSection({required String photoUrl}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.purple[200],
          backgroundImage: photoUrl.isNotEmpty
              ? NetworkImage(photoUrl) as ImageProvider<Object>
              : const AssetImage('assets/user_placeholder.png')
                  as ImageProvider<Object>,
          child: photoUrl.isEmpty
              ? const Icon(Icons.person, size: 70, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: TextField(
            controller: _nameController,
            focusNode: _nameFocus,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 6),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white70,
            ),
            textInputAction: TextInputAction.next,
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(_locationFocus);
            },
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 64),
          child: TextField(
            controller: _locationController,
            focusNode: _locationFocus,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              hintText: 'Location',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white70,
            ),
            textInputAction: TextInputAction.next,
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(_contactNumberFocus);
            },
          ),
        ),
        const SizedBox(height: 8),
         Padding(
          padding: const EdgeInsets.symmetric(horizontal: 64),
          child: TextField(
            controller: _contactNumberController,
            focusNode: _contactNumberFocus,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              hintText: 'Contact Number',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white70,
            ),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(_emailFocus);
            },
          ),
        ),
        const SizedBox(height: 8),
         Padding(
          padding: const EdgeInsets.symmetric(horizontal: 64),
          child: TextField(
            controller: _emailController,
            focusNode: _emailFocus,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              hintText: 'Email',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white70,
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(_bioFocus);
            },
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: TextField(
            controller: _bioController,
            focusNode: _bioFocus,
            textAlign: TextAlign.center,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Bio',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white70,
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              FocusScope.of(context).unfocus();
              _saveProfile();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildManageProductsBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3B340),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepOrange, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Manage Products',
            textAlign: TextAlign.center,
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
              border: Border.all(color: Colors.deepOrange, width: 2),
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
                  return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2));
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error loading products: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [_buildAddButton()],
                  );
                }

                final products = snapshot.data!.docs
                    .map((d) => Product.fromDocument(d))
                    .toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...products.map(
                        (p) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        ManagedProductDetailScreen(product: p)),
                              );
                            },
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: p.imageUrl.isNotEmpty
                                  ? NetworkImage(p.imageUrl)
                                      as ImageProvider<Object>
                                  : const AssetImage(
                                          'assets/product_placeholder.png')
                                      as ImageProvider<Object>,
                              child: p.imageUrl.isEmpty
                                  ? const Icon(Icons.shopping_bag_outlined,
                                      size: 30, color: Colors.black54)
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      _buildAddButton(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductFormScreen(product: null)),
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