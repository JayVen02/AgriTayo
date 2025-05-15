// import 'package:flutter/material.dart';

// class ManageProductsScreen extends StatelessWidget {
//   const ManageProductsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//              colors: [Color(0xFFF8F8B0), Color(0xA9E8E5)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     ElevatedButton(
//                       onPressed: () => Navigator.pop(context),
//                        style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.white,
//                            foregroundColor: Colors.black,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                             side: const BorderSide(color: Colors.green, width: 3),
//                           ),
//                           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//                            minimumSize: Size.zero,
//                         ),
//                         child: const Text(
//                           "Back",
//                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                     ),
//                     ElevatedButton(
//                       onPressed: () {
//                         print("Edit button tapped");
//                       },
//                        style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.white,
//                            foregroundColor: Colors.black,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                             side: const BorderSide(color: Colors.orange, width: 3),
//                           ),
//                           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//                            minimumSize: Size.zero,
//                         ),
//                         child: const Text(
//                           "Edit",
//                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 20),

//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF3B340),
//                       borderRadius: BorderRadius.circular(16),
//                        border: Border.all(color: Colors.deepOrange, width: 2),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           height: 200,
//                            margin: const EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: Colors.grey[300],
//                             borderRadius: BorderRadius.circular(12),
//                              border: Border.all(color: Colors.grey, width: 1),
//                           ),
//                            child: const Center(child: Text("Product Image", style: TextStyle(color: Colors.black54))),
//                         ),

//                          const Padding(
//                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                            child: Row(
//                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                              children: [
//                                Text("Name here:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
//                                Text("Price Here:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
//                              ],
//                            ),
//                          ),

//                          const Padding(
//                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                            child: Column(
//                              crossAxisAlignment: CrossAxisAlignment.start,
//                              children: [
//                                Text("Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
//                                SizedBox(height: 8),
//                                 Text(
//                                   "Man fuck carrots potatoes are better",
//                                   style: TextStyle(fontSize: 16, color: Colors.white70),
//                                 ),
//                              ],
//                            ),
//                          ),

//                          const Spacer(),

//                          Padding(
//                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//                            child: ElevatedButton(
//                              onPressed: () {
//                                print("Remove Product tapped");
//                              },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.red,
//                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                                 padding: const EdgeInsets.symmetric(vertical: 12),
//                               ),
//                              child: const Text("Remove Product", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
//                            ),
//                          ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//                const Spacer(),

//               Container(
//                 height: 150,
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Color(0xFF8BC34A), Color(0xFF4CAF50)],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   ),
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(60)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }