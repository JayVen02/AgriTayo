import 'package:flutter/material.dart';
import 'message_screen.dart'; // Import of ChatScreen
import 'profile_screen.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FullScreenImagePage();
  }
}

class FullScreenImagePage extends StatelessWidget {
  const FullScreenImagePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                // Back & Profile
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
        children: const [
          Text(
            "Name",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: "MyFont",
              color: Colors.black,
            ),
          ),
          Text(
            "Farmer",
            style: TextStyle(
              fontSize: 12,
              fontFamily: "MyFont",
              color: Colors.black,
            ),
          ),
        ],
      ),
      const SizedBox(width: 8),
      const CircleAvatar(
        radius: 20,
        backgroundImage: AssetImage('assets/AgriMarket.png'),
      ),
    ],
  ),
),

                    ],
                  ),
                ),

                // Marketplace Container
                Expanded(
                  child: Center(
                    child: Container(
                      width: 370,
                      height: 600,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFFFcb21d),
                          width: 10,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 50, bottom: 150, right: 80), // Adjust padding to avoid overlap
                              child: Text(
                                'Name Here                        Price Here:\nBasic info Here:',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 20, // Adjust as needed
                            left: 10,
                            right: 10, // Ensure it's centered or constrained
                            child: Container(
                              width: 330, // This width might be constrained by parent if using left/right
                              height: 200,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8E8E8),
                                border: Border.all(
                                  color: const Color(0xFFECECEC),
                                  width: 5,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              // You might want to add content here, e.g., an Image.network or placeholder
                              child: Center(child: Text("Product Image Area")),
                            ),
                          ),

                          // Buttons
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
                                      builder: (_) => Center( // Use Dialog widget for better alignment and theming
                                        child: AlertDialog(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          content: const Text(
                                            "You have purchased",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "MyFont",
                                              color: Colors.white,
                                            ),
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
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                                  ),
                                  child: const Text(
                                    "Buy Now",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const ChatScreen()), // Navigate to ChatScreen directly
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFC6C6C6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 12),
                                  ),
                                  child: const Text(
                                    "Message",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00B700),
                                    ),
                                  ),
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