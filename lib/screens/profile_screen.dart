import 'package:flutter/material.dart';
import 'marketplace_screen.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
            children: [
              // Back and Message Icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const MarketplaceScreen()),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.green, width: 3),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        child: const Text(
                          "Back",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    Image.asset(
                      'assets/images/message.png',
                      width: 35,
                      height: 35,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Name, Location, Status
              const Text(
                "Name",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                  fontFamily: 'Futehodo-MaruGothic_1.00',
                ),
              ),
              const Text(
                "Location",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 1, color: Colors.black)],
                  fontFamily: 'Futehodo-MaruGothic_1.00',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Live Laugh Love",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 1, color: Colors.black)],
                  fontFamily: 'Futehodo-MaruGothic_1.00',
                ),
              ),

              const SizedBox(height: 40),

              // Manage Products Section
              Container(
                width: 300,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3B340),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Manage Products",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 1, color: Colors.black)],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.deepOrange, style: BorderStyle.solid, width: 2),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.transparent,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(5, (_) {
                          return CircleAvatar(
                            radius: 25,
                            backgroundImage: const AssetImage('assets/images/carrot.jpg'),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Bottom landscape wave - mimic with container
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
    );
  }
}
