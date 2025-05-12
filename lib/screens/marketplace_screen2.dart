import 'package:flutter/material.dart';

class FarmerDashboard extends StatelessWidget {
  const FarmerDashboard({super.key});

  // Update this method to navigate when carrot is clicked
  void onCarrotPressed(BuildContext context) {
    print("Carrot button pressed!");
    // Navigate to the next screen (e.g., `/marketplace_screen` route)
    Navigator.pushNamed(context, '/marketplace_screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/AgriMarket.png', // Your background image
              fit: BoxFit.cover,
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: const StadiumBorder(),
                        ),
                        child: const Text("Back"),
                      ),
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundImage: AssetImage("assets/user.jpg"), // replace with your asset
                            radius: 16,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text("Farmer", style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Bar graph (tappable)
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/graph.dart');
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

                // Price list
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
                        // Search
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

                        // Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text("Item", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("Prices\n(As of Date here)", textAlign: TextAlign.right),
                          ],
                        ),
                        const Divider(),

                        // Tappable Item Row
                        buildItemRow("Carrots", "100 per kg", context), // Pass context here
                        const Divider(),
                        buildItemRow("Carrots", "100 per kg", context),
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

  static Widget buildItemRow(String item, String price, BuildContext context) {
    return InkWell(
      onTap: () {
        print("$item button pressed");
        // Navigate when tapped
        Navigator.pushNamed(context, '/marketplace_screen'); // Use desired route here
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(item, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(price, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
