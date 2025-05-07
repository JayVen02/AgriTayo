import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _stage = 0; // 0 = intro, 1 = terrain
  int _currentMessage = 0;

  final List<String> _messages = [
    "Each option you pick will lead you down a different path.",
    "Sometimes, a choice might not have a big impact right away, but it could influence things later on.",
    "So, when you see a choice, take a moment to think about what you want to happen!"
  ];

  @override
  void initState() {
    super.initState();
    _startIntroSequence();
  }

  void _startIntroSequence() async {
    for (int i = 0; i < _messages.length; i++) {
      setState(() {
        _currentMessage = i;
      });
      await Future.delayed(Duration(seconds: i == 0 ? 3 : 4));
    }
    setState(() {
      _stage = 1; // move to terrain selection
    });
  }

  void _selectTerrain(String terrain) {
    // TODO: Add your farming game logic here.
    print('Selected terrain: $terrain');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/Title Screen.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _stage == 0 ? _buildIntro() : _buildTerrainSelection(),
            ),
          ),
        ],
      ),
    );
  }

  // Intro sequence text widget
  Widget _buildIntro() {
    return _buildIntroText(_messages[_currentMessage]);
  }

  Widget _buildIntroText(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 50),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/Paper.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Futehodo-MaruGothic_1.00',
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // Terrain selection widget
  Widget _buildTerrainSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 50),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/Paper.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: const Text(
            'Select Terrain',
            style: TextStyle(
              fontSize: 32,
              fontFamily: 'Futehodo-MaruGothic_1.00',
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 40),
        _terrainButton('Mountain'),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _terrainButton('Hills'),
            const SizedBox(width: 20),
            _terrainButton('Lowlands'),
          ],
        ),
      ],
    );
  }

  Widget _terrainButton(String label) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/Paper.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: TextButton(
        onPressed: () => _selectTerrain(label),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Futehodo-MaruGothic_1.00',
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}