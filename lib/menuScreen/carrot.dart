import 'package:flutter/material.dart';
import 'message.dart';
import '../screens/home.dart';

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
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/AgriMarket.png',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomeScreen()), 
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.green),
                          ),
                        ),
                        child: Text(
                          "Back",
                          style: TextStyle(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

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
                            radius: 20,
                            backgroundImage: AssetImage('assets/AgriMarket.png'), 
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
                      width: 370, 
                      height: 600, 
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(1), 
                        border: Border.all(
                          color: const Color.fromARGB(255, 252, 178, 29),
                          width: 10,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Transform.translate(
                              offset: Offset(-5, 1), 
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
                            top: 40,
                            left: 10,
                            child: Container(
                              width: 330,
                              height: 200,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 232, 232, 232).withOpacity(0.8), 
                                border: Border.all(
                                  color: const Color.fromARGB(255, 236, 236, 236), 
                                  width: 5,
                                ),
                                borderRadius: BorderRadius.circular(16), 
                              ),
                            ),
                            
                          ),
                          Stack(
                            children: [
                              // Other widgets in the stack
                              Positioned(
                                bottom: 15, 
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
                                          color: Colors.white, 
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const messages()),
                                            );
                                        print("Message button pressed");
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(255, 198, 198, 198),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 120, vertical: 12), 
                                      ),
                                      child: Text(
                                        "Message",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: const Color.fromARGB(255, 0, 183, 0),
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