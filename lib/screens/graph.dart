import 'package:agritayo/screens/marketplace_screen.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Import the fl_chart package
// import 'package:agritayo/main.dart'; // Unused import removed

class Graph extends StatefulWidget {
  const Graph({super.key});

  @override
  _MarketPricePageState createState() => _MarketPricePageState();
}

class _MarketPricePageState extends State<Graph> {
  bool isGraphExpanded = false; // Tracks whether the graph widget is expanded
  bool isPriceListDisabled = false; // Tracks whether the price list is disabled

  void _onGraphClick() {
    setState(() {
      isGraphExpanded = !isGraphExpanded; // Toggle graph expansion
      isPriceListDisabled = isGraphExpanded; // Disable price list when graph is expanded
    });
  }

  void _handleItemClick(BuildContext context, String itemName, String itemPrice) {
    print("Item clicked: $itemName, Price: $itemPrice");
    // TODO: Implement actual navigation or action for item click
    // For example, you could navigate to the MarketplaceScreen for this item if applicable,
    // or show a detail dialog.
    // Navigator.push(context, MaterialPageRoute(builder: (context) => MarketplaceScreen(item: itemName)));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/AgriMarket.png"), // Ensure this path is correct
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Assuming Graph screen is pushed onto stack, pop to go back
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            // Fallback if it cannot pop (e.g. it's the first screen)
                            // Or navigate to a specific home/main screen
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const MarketplaceScreen()),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Colors.green),
                          ),
                        ),
                        child: const Text(
                          "Back",
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Row( // Added const
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage('assets/images/AgriMarket.png'), // Ensure this path is correct
                          ),
                          SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text("Farmer", style: TextStyle(fontSize: 12)),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),

                // 🔹 Graph Section
                GestureDetector(
                  onTap: _onGraphClick, // Handle graph click
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.yellow[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    height: isGraphExpanded ? 300 : 120, // Expand height when clicked
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.orange, // Background color for the bar chart
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: isGraphExpanded
                                ? const Center( // Added const
                                    child: Text(
                                      "Text Here", // Placeholder for expanded graph view
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  )
                                : BarChart( // Ensure fl_chart is in pubspec.yaml
                                    BarChartData(
                                      gridData: const FlGridData(show: false),
                                      titlesData: const FlTitlesData(show: false),
                                      borderData: FlBorderData(show: false),
                                      barGroups: [
                                        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 1, color: Colors.green, width: 30, borderRadius: BorderRadius.circular(4))]),
                                        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 1.5, color: Colors.green, width: 30, borderRadius: BorderRadius.circular(4))]),
                                        BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 1.4, color: Colors.green, width: 30, borderRadius: BorderRadius.circular(4))]),
                                        BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 3.4, color: Colors.green, width: 30, borderRadius: BorderRadius.circular(4))]),
                                        BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 2, color: Colors.green, width: 30, borderRadius: BorderRadius.circular(4))]),
                                        BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 2.2, color: Colors.green, width: 30, borderRadius: BorderRadius.circular(4))]),
                                        BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 1.8, color: Colors.green, width: 30, borderRadius: BorderRadius.circular(4))]),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text("Demand for Potatoes", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 🔹 Price List
                if (!isPriceListDisabled)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        border: Border.all(color: Colors.orange, width: 25.0),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search Bar
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const TextField( // Added const
                              decoration: InputDecoration(
                                hintText: "Search",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Header
                          const Row( // Added const
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Item", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text("Prices\n(As of Date here)", textAlign: TextAlign.right),
                            ],
                          ),
                          const Divider(),

                          // List of Items
                          Expanded(
                            child: ListView(
                              children: [
                                _buildClickableItem("Carrots", "100 per kg", (itemName, itemPrice) => _handleItemClick(context, itemName, itemPrice)),
                                const Divider(),
                                _buildClickableItem("Tomatoes", "80 per kg", (itemName, itemPrice) => _handleItemClick(context, itemName, itemPrice)),
                                // Add more items as needed
                              ],
                            ),
                          )
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

  Widget _buildClickableItem(String name, String price, Function(String itemName, String itemPrice) onTap) {
    return InkWell(
      onTap: () => onTap(name, price),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(price, style: const TextStyle(fontWeight: FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}

// Removed class _onItemClick as it was not used correctly.
// Replaced with _handleItemClick method.