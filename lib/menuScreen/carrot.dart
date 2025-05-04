// import 'package:flutter/material.dart';
// // import 'buynow.dart';

// class CarrotScreen extends StatelessWidget {
//   final String item;
//   final String price;

//   const CarrotScreen({super.key, required this.item, required this.price});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFE6E0A8),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   GestureDetector(
//                          onTap: () {
//         if (item == 'Carrots') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => BuyNow()),
//           );
//         }
//       },g
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         border: Border.all(color: Colors.green, width: 3),
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       child: const Text(
//                         'Back',
//                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: const [
//                           Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
//                           Text('Farmer', style: TextStyle(fontSize: 12)),
//                         ],
//                       ),
//                       const SizedBox(width: 8),
//                       const CircleAvatar(
//                         backgroundImage: AssetImage('assets/avatar.png'),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             // Main content box
//             Expanded(
//               child: Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   border: Border.all(color: Colors.orange, width: 4),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('Back', style: TextStyle(fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 10),
//                     Container(
//                       height: 150,
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[300],
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Center(child: Text('Image Placeholder')),
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text('Name: $item', style: const TextStyle(fontWeight: FontWeight.bold)),
//                         Text('Price: $price', style: const TextStyle(fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     const Text('Basic info here:', style: TextStyle(fontWeight: FontWeight.bold)),
//                     const Spacer(),
//                     ElevatedButton(
//                       onPressed: () {},
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                       ),
//                       child: const Center(child: Text('Buy now', style: TextStyle(fontSize: 18))),
//                     ),
//                     const SizedBox(height: 10),
//                     ElevatedButton(
//                       onPressed: null,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.grey[300],
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                       ),
//                       child: const Center(
//                           child: Text('Message',
//                               style: TextStyle(fontSize: 18, color: Colors.green))),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
