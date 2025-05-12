import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agritayo/models/product.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price;
      _descriptionController.text = widget.product!.description;
      _imageUrlController.text = widget.product!.imageUrl;
      _imageUrlController.addListener(() {
        setState(() {});
      });
    } else {
       _imageUrlController.addListener(() {
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to save products.')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final productData = {
        'name': _nameController.text,
        'price': _priceController.text,
        'description': _descriptionController.text,
        'imageUrl': _imageUrlController.text,
        'sellerId': currentUser!.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      try {
        if (widget.product == null) {
          productData['createdAt'] = FieldValue.serverTimestamp();
          await FirebaseFirestore.instance.collection('products').add(productData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully!')),
          );
        } else {
          await FirebaseFirestore.instance.collection('products').doc(widget.product!.id).update(productData);
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully!')),
          );
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save product: $e')),
        );
        print('Error saving product: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteProduct() async {
     if (widget.product == null) return;

     setState(() {
       _isLoading = true;
     });

     try {
       await FirebaseFirestore.instance.collection('products').doc(widget.product!.id).delete();
        ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Product deleted successfully!')),
       );
       Navigator.pop(context);
     } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Failed to delete product: $e')),
       );
        print('Error deleting product: $e');
     } finally {
       setState(() {
         _isLoading = false;
       });
     }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    final screenTitle = isEditing ? 'Edit Product' : 'Add New Product';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F8B0), Color(0xFFA9E8E5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
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
                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                           screenTitle,
                           style: const TextStyle(
                             fontSize: 20,
                             fontWeight: FontWeight.bold,
                             color: Colors.black,
                             overflow: TextOverflow.ellipsis,
                           ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                 Expanded(
                   child: SingleChildScrollView(
                     padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                          Container(
                             height: 200,
                              margin: const EdgeInsets.only(bottom: 16),
                             decoration: BoxDecoration(
                               color: Colors.grey[300],
                               borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey, width: 1),
                                image: _imageUrlController.text.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(_imageUrlController.text),
                                          fit: BoxFit.cover,
                                          onError: (exception, stackTrace) {
                                            print('Error loading image: $exception');
                                          },
                                        )
                                      : null,
                             ),
                              child: _imageUrlController.text.isEmpty
                                     ? const Center(child: Text("Image Preview", style: TextStyle(color: Colors.black54)))
                                     : null,
                           ),

                          TextFormField(
                             controller: _imageUrlController,
                             decoration: InputDecoration(
                               labelText: 'Image URL',
                               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                               filled: true,
                               fillColor: Colors.white.withOpacity(0.8),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                             ),
                             keyboardType: TextInputType.url,
                             validator: (value) {
                                return null;
                             },
                           ),

                         const SizedBox(height: 16),

                         TextFormField(
                             controller: _nameController,
                             decoration: InputDecoration(
                               labelText: 'Product Name',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                               filled: true,
                               fillColor: Colors.white.withOpacity(0.8),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                             ),
                             validator: (value) {
                               if (value == null || value.isEmpty) {
                                 return 'Please enter a product name';
                               }
                               return null;
                             },
                           ),
                         const SizedBox(height: 16),

                          TextFormField(
                             controller: _priceController,
                             decoration: InputDecoration(
                               labelText: 'Price',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                               filled: true,
                               fillColor: Colors.white.withOpacity(0.8),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                             ),
                             keyboardType: TextInputType.text,
                             validator: (value) {
                               if (value == null || value.isEmpty) {
                                 return 'Please enter a price';
                               }
                               return null;
                             },
                           ),
                         const SizedBox(height: 16),

                          TextFormField(
                             controller: _descriptionController,
                             decoration: InputDecoration(
                               labelText: 'Details/Description',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                               filled: true,
                               fillColor: Colors.white.withOpacity(0.8),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                             ),
                             maxLines: 3,
                           ),
                       ],
                     ),
                   ),
                 ),

                 Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                   child: _isLoading
                       ? const Center(child: CircularProgressIndicator())
                       : Column(
                           crossAxisAlignment: CrossAxisAlignment.stretch,
                           children: [
                              ElevatedButton(
                                onPressed: _saveProduct,
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: Colors.green,
                                   foregroundColor: Colors.white,
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                   padding: const EdgeInsets.symmetric(vertical: 12),
                                 ),
                                child: Text(isEditing ? "Save Changes" : "Add Product", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                             if (isEditing)
                                const SizedBox(height: 12),
                             if (isEditing)
                                ElevatedButton(
                                   onPressed: _deleteProduct,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                   child: const Text("Delete Product", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                 ),
                           ],
                         ),
                 ),

                Container(
                  height: 150,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF8BC34A), Color(0xFF4CAF50)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(60)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}