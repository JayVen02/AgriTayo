import 'package:flutter/material.dart';

class Graph extends StatelessWidget {
  const Graph({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/AgriMarket.png', // Use your actual file name
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Top Bar with Back and Profile
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/marketplace_screen2');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(color: Colors.green),
                          ),
                        ),
                        child: const Text("Back", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundImage: AssetImage('assets/user.jpg'), // Adjust as needed
                            radius: 20,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Name", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text("Farmer", style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Graph card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.yellow[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: const [
                        // Mock chart area
                        SizedBox(
                          height: 120,
                          child: Center(child: Text("Bar Chart Placeholder")),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Demand for Potatoes",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Textttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
