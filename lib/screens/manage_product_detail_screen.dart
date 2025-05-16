import 'package:flutter/material.dart';
import 'product_form_screen.dart';
import 'package:agritayo/models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManagedProductDetailScreen extends StatelessWidget {
  final Product product;

  const ManagedProductDetailScreen({super.key, required this.product});

  void _removeProduct(BuildContext context) async {
     try {
       await FirebaseFirestore.instance.collection('products').doc(product.id).delete();
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Product removed successfully!")),
        );
       Navigator.pop(context);
     } catch (e) {
       print("Error removing product: $e");
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Failed to remove product: $e")),
        );
     }
  }

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    ElevatedButton(
                      onPressed: () {
                         Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProductFormScreen(product: product)),
                         );
                      },
                       style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                           foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(color: Colors.orange, width: 3),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                           minimumSize: Size.zero,
                        ),
                        child: const Text(
                          "Edit",
                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3B340),
                      borderRadius: BorderRadius.circular(16),
                       border: Border.all(color: Colors.deepOrange, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 200,
                           margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                             border: Border.all(color: Colors.grey, width: 1),
                             image: product.imageUrl.isNotEmpty
                                 ? DecorationImage(
                                     image: NetworkImage(product.imageUrl),
                                     fit: BoxFit.cover,
                                   )
                                 : null,
                          ),
                           child: product.imageUrl.isEmpty
                               ? const Center(child: Text("No Image Available", style: TextStyle(color: Colors.black54)))
                               : null,
                        ),

                         Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                           child: Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               Expanded(
                                   child: Text(
                                     product.name,
                                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                      overflow: TextOverflow.ellipsis,
                                   )),
                               const SizedBox(width: 16),
                                Text(
                                  "php ${product.price}",
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                             ],
                           ),
                         ),

                         Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               const Text("Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                               SizedBox(height: 8),
                                Text(
                                  product.description,
                                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                                ),
                             ],
                           ),
                         ),

                         const Spacer(),

                         Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                           child: ElevatedButton(
                             onPressed: () => _removeProduct(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                             child: const Center(child: Text("Remove Product", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
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
      ),
    );
  }
}