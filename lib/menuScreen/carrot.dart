import 'package:flutter/material.dart';
// import 'package:flutter_application_1/menuScreen/message.dart'; // Removed as the file does not exist
import '../main.dart';
import 'message.dart';



class Carrot extends StatelessWidget {
  const Carrot({super.key});

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
        fit: StackFit.expand, // Makes the image cover the whole screen
        children: [
          Image.asset(
            'assets/AgriMarket.png', // Replace with your image asset
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row with Back Button and Profile
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => MarketPricePage()), // Replace with your main page widget
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Button background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20), // Rounded corners
                            side: BorderSide(color: Colors.green), // Green border
                          ),
                        ),
                        child: Text(
                          "Back",
                          style: TextStyle(
                            color: const Color.fromARGB(255, 0, 0, 0), // Text color
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Profile Section
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
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
                          SizedBox(width: 8),
                          CircleAvatar(
                            radius: 20, // Size of the circle
                            backgroundImage: AssetImage('assets/AgriMarket.png'), // Replace with your image asset
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Centered Box
                Expanded(
                  child: Center(
                    child: Container(
                      width: 370, // Width of the outer box
                      height: 600, // Height of the outer box
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(1), // Background color with opacity
                        border: Border.all(
                          color: const Color.fromARGB(255, 252, 178, 29), // Border color
                          width: 10, // Border thickness
                        ),
                        borderRadius: BorderRadius.circular(12), // Rounded corners
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Transform.translate(
                              offset: Offset(-5, 1), // Move -20 on the x-axis and 0 on the y-axis
                              child: Text(
                                'Name Here                  Price Here:\nBasic info Here:',
                                style: TextStyle(
                                  fontSize:15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 40, // Offset on the y-axis
                            left: 10, // Center the inner box horizontally
                            child: Container(
                              width: 330, // Width of the inner box
                              height: 200, // Height of the inner box
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 232, 232, 232).withOpacity(0.8), // Background color for the inner box
                                border: Border.all(
                                  color: const Color.fromARGB(255, 236, 236, 236), // Border color for the inner box
                                  width: 5, // Border thickness
                                ),
                                borderRadius: BorderRadius.circular(16), // Rounded corners
                              ),
                            ),
                            
                          ),
                          Stack(
                            children: [
                              // Other widgets in the stack
                              Positioned(
                                bottom: 15, // Offset from the bottom of the container
                                left: 0,
                                right: 0,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Center(
                                              child: Container(
                                                width: 300, // Width of the dialog
                                                height: 300, // Height of the dialog
                                                decoration: BoxDecoration(
                                                  color: Colors.green, // Background color
                                                  borderRadius: BorderRadius.circular(12), // Rounded corners
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "You have purchased",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: "MyFont",
                                                      color: Colors.white, // Text color
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF00A814), // Button background color
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12), // Rounded corners
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12), // Button padding
                                      ),
                                      child: Text(
                                        "Buy Now",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white, // Button text color
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16), // Spacing between buttons
                                    ElevatedButton(
                                      onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const SigmaBoyApp()),
                                            );
                                        print("Message button pressed");
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(255, 198, 198, 198), // Button background color
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20), // Rounded corners
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 120, vertical: 12), // Button padding
                                      ),
                                      child: Text(
                                        "Message",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: const Color.fromARGB(255, 0, 183, 0), // Button text color
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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