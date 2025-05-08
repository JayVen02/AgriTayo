import 'dart:async'; // Import for Timer
import 'dart:math';
import 'package:flutter/material.dart';
import 'home.dart';

// Class to hold seed information
class SeedData {
  final String name;
  final String trait;
  final int harvestingDays;
  final String iconAsset;
  final List<String> strengths;
  final List<String> weaknesses;

  // Constructor to create SeedData object
  SeedData({
    required this.name,
    required this.trait,
    required this.harvestingDays,
    required this.iconAsset,
    required this.strengths,
    required this.weaknesses,
  });
}

// Game progress stages
enum GameStage {
  intro,
  terrainSelection,
  seedSelection,
  dailyCycle, // Player action choices
  weatherForecast, // Hint/Loading weather
  weatherEvent, // Show the event
  playerWeatherAction, // Player input for weather
  aiJudgement, // AI feedback on weather action
  harvesting, // Calculating harvest
  results, // Show harvest results
  gameOver, // End screen after failing
  showTips // Show a tip before going home
}

// Player's daily choice
enum DailyAction { water, fertilize, weedPest, doNothing }

// AI's judgment types
enum AIJudgementCategory { smartAndEffective, ineffectiveOrTooLate, comedicUseless }

// Main screen of the game
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameStage _currentStage = GameStage.intro; // Start at intro stage
  int _currentMessageIndex = 0; // Which message to show now

  String? _selectedTerrain; // Player-selected land
  SeedData? _selectedSeedData; // Player-selected seed

  // Game variables
  int _money = 200; // Player's starting money
  int _currentDay = 1; // Start at day 1
  double _cropHealth = 100.0; // Health of the crop (max 100)
  String _cropStatusMessage = "Ready to plant!"; // Message about crop status
  int _totalInvestment = 0; // How much money spent

  String? _currentWeatherHint; // Hint for upcoming weather
  String? _currentWeatherEvent; // Actual weather event
  String? _playerWeatherResponse; // Player's action to weather
  AIJudgementCategory? _aiJudgement; // AI's opinion on player's action
  String _aiJudgementFeedback = ""; // What AI says to player

  // State for weather image overlay fade
  bool _showWeatherImageOverlay = false;
  Timer? _weatherImageTimer;

  // Harvest results
  String _cropQuality = "Unknown"; // How good the crop is
  int _harvestValue = 0; // How much money made from harvest
  int _profitOrLoss = 0; // Money earned or lost
  String _gameOutcome = ""; // Result: win, barely survived, or fail

  // For typing weather response
  final TextEditingController _weatherResponseController = TextEditingController();

  // Descriptions for different land types
  final Map<String, String> _terrainDescriptions = {
    'Mountain': 'Cold climate, rocky soil, high elevation.',
    'Hills': 'Mild climate, good drainage.',
    'Lowlands': 'Warm and humid, ideal for wet crops.'
  };

  // Information for each seed
  final Map<String, SeedData> _seedInfo = {
    'Adlay Rice': SeedData(
        name: 'Adlay Rice',
        trait: 'Thrives in humid and wet conditions.',
        harvestingDays: 12, // Grows fast for testing
        iconAsset: 'assets/images/adlay_seed_icon.png',
        strengths: ['Rainy', 'Flooding'],
        weaknesses: ['Heatwave', 'Locust Swarm']),
    'Corn': SeedData(
        name: 'Corn',
        trait: 'Grows well on sloped and drained soil.',
        harvestingDays: 9,
        iconAsset: 'assets/images/corn_seed_icon.png',
        strengths: ['Sunny', 'Heatwave'],
        weaknesses: ['Flooding', 'Thunderstorm']),
    'Potatoes': SeedData(
        name: 'Potatoes',
        trait: 'Tolerant to cold and rocky terrain.',
        harvestingDays: 10,
        iconAsset: 'assets/images/potato_seed_icon.png',
        strengths: ['Cloudy', 'Thunderstorm'],
        weaknesses: ['Heatwave', 'Locust Swarm']),
    'Tomato': SeedData(
        name: 'Tomato',
        trait: 'Sensitive to extreme weather changes.',
        harvestingDays: 7,
        iconAsset: 'assets/images/tomato_seed_icon.png',
        strengths: ['Sunny'],
        weaknesses: ['Typhoon', 'Flooding', 'Heatwave']),
  };

  // Messages shown at the start
  final List<String> _introMessages = [
    "Welcome Aspiring Farmer!, Each option you pick will lead you down a different path.",
    "Sometimes, a choice might not have a big impact right away, but it could influence things later on.",
    "So, when you see a choice, take a moment to think about what you want to happen!"
  ];

  // Normal weather types
  final List<String> _normalWeatherEvents = ['Sunny', 'Rainy', 'Cloudy'];

  // Dangerous weather types
  final List<String> _disasterWeatherEvents = [
    'Thunderstorm',
    'Typhoon',
    'Heatwave (El Nino)',
    'Locust Swarm',
    'Flooding'
  ];
  List<String> _allWeatherEvents = []; // Combined list of all weather

  // Mapping weather event strings to image assets
  final Map<String, String> _weatherImageAssets = {
    'Sunny': 'assets/images/sunny.png',
    'Rainy': 'assets/images/rain.png',
    'Cloudy': 'assets/images/cloud.png',
    'Thunderstorm': 'assets/images/thunderstorm.png',
    'Heatwave (El Nino)': 'assets/images/El Nino.png', 
    'Locust Swarm': 'assets/images/Locust.png', 
    'Flooding': 'assets/images/flooding.png',
    'Typhoon': 'assets/images/typhoon.png',
  };

  // Mapping item names to image assets
   final Map<String, String> _itemImageAssets = {
    'Fertilizer': 'assets/images/fertilizer.png',
    'Pest Spray': 'assets/images/pest spray.png',
    'Shovel': 'assets/images/shovel.png',
  };

  final Map<String, String> _uiImageAssets = {
    'Harvest Time': 'assets/images/HarvestTime 1.png',
  };


  // Tips to help player
  final List<String> _gameTips = [
    "Tip: Matching seeds to terrain strengths can boost your harvest!",
    "Tip: Pay attention to weather forecasts; they can save your crops.",
    "Tip: Fertilizing at the right time can significantly improve crop health.",
    "Tip: Some disasters are unavoidable, but smart choices can mitigate damage."
  ];

  @override
  void initState() {
    super.initState();
    // Combine normal and disaster weather into one list
    _allWeatherEvents = [..._normalWeatherEvents, ..._disasterWeatherEvents];
    _startIntroSequence(); // Start intro when game loads
  }

  // Show intro messages one by one
  void _startIntroSequence() async {
    _currentStage = GameStage.intro;
    for (int i = 0; i < _introMessages.length; i++) {
      if (!mounted) return;
      setState(() => _currentMessageIndex = i);
      await Future.delayed(Duration(seconds: i == 0 ? 2 : 3)); // Wait before next message
    }
    if (!mounted) return;
    setState(() => _currentStage = GameStage.terrainSelection); // Move to next stage
  }

  // Skip intro messages
  void _skipIntro() => setState(() => _currentStage = GameStage.terrainSelection);

  // Save selected terrain and move to seed selection
  void _selectTerrain(String terrain) {
    setState(() {
      _selectedTerrain = terrain;
      _currentStage = GameStage.seedSelection;
    });
  }

  void _selectSeed(String seedKey) {
    setState(() {
      // Set the selected seed info
      _selectedSeedData = _seedInfo[seedKey];
      // Reset money spent
      _totalInvestment = 0;
      // Reset day
      _currentDay = 1;
      // Reset crop health
      _cropHealth = 100.0;
      // Show message that seed is planted
      _cropStatusMessage = "Planted ${_selectedSeedData!.name}";
      // Go to next game stage (daily actions)
      _currentStage = GameStage.dailyCycle;
    });
  }

  void _handleDailyAction(DailyAction action) {
    if (_selectedSeedData == null) return;
    String actionMessage = "";
    int cost = 0;
    double healthChange = 0;

    // Check what action player chooses
    switch (action) {
      case DailyAction.water:
        // Watering increases health
        actionMessage = "You watered the crops.";
        healthChange = 5;
        break;
      case DailyAction.fertilize:
        // Fertilizing costs money, gives more health
        cost = 20;
        if (_money >= cost) {
          _money -= cost;
          _totalInvestment += cost;
          actionMessage = "You fertilized the crops. Cost: \$$cost";
          healthChange = 15;
        } else {
          actionMessage = "Not enough money to fertilize!";
        }
        break;
      case DailyAction.weedPest:
        // Remove pests, costs less than fertilize
        cost = 15;
        if (_money >= cost) {
          _money -= cost;
          _totalInvestment += cost;
          actionMessage = "You applied weed/pest control. Cost: \$$cost";
          healthChange = 10;
        } else {
          actionMessage = "Not enough money for weed/pest control!";
        }
        break;
      case DailyAction.doNothing:
        // Doing nothing reduces crop health
        actionMessage = "You chose to do nothing for the day.";
        healthChange = -5;
        break;
    }

    // Update crop health, make sure it stays between 0 and 100
    _cropHealth = (_cropHealth + healthChange).clamp(0.0, 100.0);
    if (_cropHealth <= 0) {
      // Crop dies
      _cropStatusMessage = "Your crops have withered!";
    } else {
      // Show message and updated health
      _cropStatusMessage = "$actionMessage Crop health: ${_cropHealth.toStringAsFixed(1)}%";
    }

    // Go to next stage (weather forecast)
    setState(() {
      _currentStage = GameStage.weatherForecast;
    });
  }

  void _generateWeatherForecast() {
    if (_selectedSeedData == null) return;
    final random = Random();
    String upcomingWeather;

    // 50% chance: give hint based on seed's strength or weakness
    if (random.nextBool() && (_selectedSeedData!.strengths.isNotEmpty || _selectedSeedData!.weaknesses.isNotEmpty)) {
        bool hintStrength = random.nextBool();
        if (hintStrength && _selectedSeedData!.strengths.isNotEmpty) {
            // Hint for good weather
            upcomingWeather = _selectedSeedData!.strengths[random.nextInt(_selectedSeedData!.strengths.length)];
            _currentWeatherHint = "Hint: Upcoming weather might favor your '${_selectedSeedData!.name}' if it's like '$upcomingWeather'.";
        } else if (_selectedSeedData!.weaknesses.isNotEmpty) {
            // Hint for bad weather
            upcomingWeather = _selectedSeedData!.weaknesses[random.nextInt(_selectedSeedData!.weaknesses.length)];
            _currentWeatherHint = "Hint: Be cautious, weather like '$upcomingWeather' could be challenging for your '${_selectedSeedData!.name}'.";
        } else {
            // If no good/bad weather found, random
            upcomingWeather = _allWeatherEvents[random.nextInt(_allWeatherEvents.length)];
            _currentWeatherHint = "Hint: The winds are changing...";
        }
    } else {
        // Random hint
        upcomingWeather = _allWeatherEvents[random.nextInt(_allWeatherEvents.length)];
        _currentWeatherHint = "Hint: An interesting weather pattern is forming.";
    }

    // Set actual weather for the day (may not match hint)
    _currentWeatherEvent = _allWeatherEvents[random.nextInt(_allWeatherEvents.length)];

    setState(() {
        _currentStage = GameStage.weatherEvent;
    });
  }

  void _processPlayerWeatherAction() {
    final playerInput = _weatherResponseController.text.toLowerCase();
    _playerWeatherResponse = playerInput;

    bool isDisaster = _disasterWeatherEvents.contains(_currentWeatherEvent);
    _aiJudgementFeedback = "";

    // Judge response based on input and weather
    if (playerInput.isEmpty && isDisaster) {
        // No action during disaster = big penalty
        _aiJudgement = AIJudgementCategory.ineffectiveOrTooLate;
        _aiJudgementFeedback = "Doing nothing during a disaster ($_currentWeatherEvent) can be risky!";
        _cropHealth -= 30;
    } else if (playerInput.isEmpty && !isDisaster) {
        // No action during normal weather = small penalty
        _aiJudgement = AIJudgementCategory.ineffectiveOrTooLate;
        _aiJudgementFeedback = "You chose to observe the $_currentWeatherEvent.";
        if(_currentWeatherEvent == 'Rainy' && !_selectedSeedData!.strengths.contains('Rainy')) _cropHealth -=5;
        if(_currentWeatherEvent == 'Sunny' && !_selectedSeedData!.strengths.contains('Sunny')) _cropHealth -=5;
    } else if (playerInput.contains("secure") || playerInput.contains("protect") || playerInput.contains("prepare")) {
        // Good response for disaster
        _aiJudgement = AIJudgementCategory.smartAndEffective;
        _aiJudgementFeedback = "A smart move to try and protect your crops from $_currentWeatherEvent!";
        if(isDisaster) _cropHealth -= 5;
        else _cropHealth += 5;
    } else if (playerInput.contains("water") && _currentWeatherEvent == "Heatwave (El Nino)") {
        // Smart watering in heat
        _aiJudgement = AIJudgementCategory.smartAndEffective;
        _aiJudgementFeedback = "Watering during a heatwave is a good call!";
        _cropHealth += 10;
    } else if (playerInput.contains("ignore") || playerInput.contains("nothing")) {
        // Bad choice for any weather
        _aiJudgement = AIJudgementCategory.ineffectiveOrTooLate;
        _aiJudgementFeedback = "Ignoring $_currentWeatherEvent might not be the best idea.";
        if(isDisaster) _cropHealth -= 25;
    } else if (playerInput.contains("harvest") && isDisaster) {
        // Trying to harvest early during disaster
        _aiJudgement = AIJudgementCategory.ineffectiveOrTooLate;
        _aiJudgementFeedback = "Emergency harvest during $_currentWeatherEvent? Risky, but might save something.";
        _cropHealth -= 10;
    } else {
        // Funny or weird response
        _aiJudgement = AIJudgementCategory.comedicUseless;
        _aiJudgementFeedback = "'$playerInput'... an interesting response to $_currentWeatherEvent. The crops are confused.";
        if(isDisaster) _cropHealth -= 15;
    }

    // Additional crop health effects based on weather
    if (_currentWeatherEvent == 'Locust Swarm') {
        _cropHealth -= 40;
        _cropStatusMessage = "Locusts ravaged the fields!";
    } else if (_currentWeatherEvent == 'Typhoon') {
        _cropHealth -= 35;
        _cropStatusMessage = "A typhoon caused significant damage!";
    } else if (_currentWeatherEvent == 'Flooding' && !_selectedSeedData!.strengths.contains('Flooding')) {
        _cropHealth -= 20;
        _cropStatusMessage = "Flooding damaged the non-resistant crops!";
    } else if (_currentWeatherEvent == 'Heatwave (El Nino)' && !_selectedSeedData!.strengths.contains('Heatwave')) {
        _cropHealth -= 20;
        _cropStatusMessage = "The intense heatwave stressed the crops.";
    } else if (_currentWeatherEvent == 'Rainy' && _selectedSeedData!.strengths.contains('Rainy')){
        _cropHealth += 10;
        _cropStatusMessage = "Beneficial rain for your crops!";
    } else if (_currentWeatherEvent == 'Sunny' && _selectedSeedData!.strengths.contains('Sunny')){
        _cropHealth += 10;
        _cropStatusMessage = "Perfect sunny weather for your crops!";
    } else {
       // Default status message if not a specific major event
       _cropStatusMessage = "${_selectedSeedData?.name} status: ${_cropHealth.toStringAsFixed(0)}% Health";
    }


    _cropHealth = _cropHealth.clamp(0.0, 100.0);
    if (_cropHealth <= 0) {
        _cropStatusMessage = "Your crops didn't survive the day.";
    }

    _weatherResponseController.clear();
    setState(() {
      _currentStage = GameStage.aiJudgement;
    });
  }

  void _proceedFromAIJudgement() {
    if (_selectedSeedData == null) return;

    // If crop is ready to harvest or died, go to harvest
    if (_currentDay >= _selectedSeedData!.harvestingDays || _cropHealth <= 0) {
      setState(() {
        _currentStage = GameStage.harvesting;
      });
    } else {
      // Otherwise, go to next day
      setState(() {
        _currentDay++;
        // Update status message for the new day
        _cropStatusMessage = "Day $_currentDay: ${_selectedSeedData?.name} is growing...";
        _currentStage = GameStage.dailyCycle;
      });
    }
  }

  void _calculateHarvest() {
    if (_selectedSeedData == null) return;

    // Decide quality based on health
    if (_cropHealth > 90) _cropQuality = "Excellent";
    else if (_cropHealth > 70) _cropQuality = "Good";
    else if (_cropHealth > 40) _cropQuality = "Average";
    else if (_cropHealth > 10) _cropQuality = "Poor";
    else _cropQuality = "Failed";

    // Set value per day, with bonus for quality and health
    int baseValuePerDay = 10 + (_selectedSeedData!.harvestingDays);
    double qualityMultiplier = (_cropQuality == "Excellent") ? 2.0 :
                               (_cropQuality == "Good") ? 1.5 :
                               (_cropQuality == "Average") ? 1.0 :
                               (_cropQuality == "Poor") ? 0.5 : 0.1;

    _harvestValue = (_cropHealth <=0) ? 0 :
      (baseValuePerDay * _selectedSeedData!.harvestingDays * qualityMultiplier * (_cropHealth / 100.0)).toInt();

    // Subtract money spent, calculate profit/loss
    _profitOrLoss = _harvestValue - _totalInvestment;
    _money += _profitOrLoss;

    // Set game result
    if (_profitOrLoss > 50 && _cropQuality != "Failed") {
      _gameOutcome = "Success!";
    } else if (_profitOrLoss >= -20 && _cropQuality != "Failed") {
      _gameOutcome = "Barely Survived";
    } else {
      _gameOutcome = "Failed";
    }

// This move the game to "results" screen
    setState(() {
      _currentStage = GameStage.results;
    });
  }

  void _resetGameForContinue() {
    setState(() {
      _currentStage = GameStage.terrainSelection; // Go back to terrain select screen
      _selectedTerrain = null; // remove old terrain choice
      _selectedSeedData = null; // remove old seed choice
      _currentDay = 1; // start new day 1
      _cropHealth = 100.0; // full health
      _cropStatusMessage = "Ready for a new season!"; // message for new season
      _totalInvestment = 0; // money spent in this new game
      // money from old season still kept
    });
  }

  void _quitGame() {
    setState(() {
      // Decide if game over or show tips before going home
      if (_money < 0) { // Simple condition for game over
         _currentStage = GameStage.gameOver;
      } else {
         _currentStage = GameStage.showTips; // move to tips screen
      }
    });
  }

  void _goToHomeScreen() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomeScreen()), // go to home
      (Route<dynamic> route) => false, // remove all old screens
    );
  }

String _getDynamicBackground() {
  // If intro, terrain select, seed select, tips or game over -> show title screen or specific non-gameplay screen background
  if (_currentStage == GameStage.intro ||
      _currentStage == GameStage.terrainSelection ||
      _currentStage == GameStage.seedSelection ||
      _currentStage == GameStage.showTips ||
      _currentStage == GameStage.gameOver ||
      _currentStage == GameStage.results) { // Also results screen could use a neutral background
    return 'assets/images/Title Screen.png'; // Use title screen or a dedicated game over/results background
  }

  // If terrain selected, change background to that terrain image
  if (_selectedTerrain != null) {
    switch (_selectedTerrain) {
      case 'Mountain': return 'assets/images/Mountain.png';
      case 'Hills': return 'assets/images/Hill.png';
      case 'Lowlands': return 'assets/images/Lowlands.png';
    }
  }

  // default image if no match or in active gameplay without specific terrain image
  return 'assets/images/Title Screen.png';
}

    // Helper to get weather image path
    String? _getWeatherImageAsset(String? event) {
      if (event == null) return null;
      return _weatherImageAssets[event];
    }

    // Helper to get item image path
    String? _getItemImageAsset(String itemName) {
        return _itemImageAssets[itemName];
    }

    // Helper to get general UI image path
    String? _getUIImageAsset(String imageName) {
        return _uiImageAssets[imageName];
    }


@override
Widget build(BuildContext context) {
  // Check if we are in one of the gameplay stages (after seed selection)
  bool inGameplay = [
    GameStage.dailyCycle,
    GameStage.weatherForecast,
    GameStage.weatherEvent,
    GameStage.playerWeatherAction,
    GameStage.aiJudgement,
  ].contains(_currentStage);

  return Scaffold(
    body: Stack(
      children: [
        // show background image that change depends on stage
        Image.asset(
          _getDynamicBackground(),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),

        // put the main stage UI in center of screen with padding
        // This shows the prompt, choices, messages for the current stage
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildCurrentStageWidget(), // build the UI based on game stage
          ),
        ),

        // Show weather event image at top, status/items at bottom during gameplay stages
        if (inGameplay) ..._buildGameplayElements(),

      ],
    ),
  );
}

  // Builds the dynamic overlay elements visible during gameplay stages
  List<Widget> _buildGameplayElements() {
    // Get the current weather image asset path
    String? weatherImagePath = _getWeatherImageAsset(_currentWeatherEvent);

    return [
      AnimatedOpacity(
        opacity: _showWeatherImageOverlay ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        child: Positioned(
          top: 16,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.topCenter,
             // Only build the container content if visible and image path exists
            child: weatherImagePath != null && _showWeatherImageOverlay
                ? Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Weather Event", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        SizedBox(height: 4),
                        Image.asset(
                          weatherImagePath,
                          width: 60,
                          height: 60,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.cloud_queue, size: 60, color: Colors.white),
                        ),
                        SizedBox(height: 4),
                        Text(_currentWeatherEvent ?? 'Unknown', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),

                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),


      // 2. Bottom UI Bar (Money, Status, Items)
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          color: Colors.black.withOpacity(0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               // Crop Status Message / Name
               Text(
                _cropStatusMessage,
                style: TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
               SizedBox(height: 8),

              // Row for Day, Money, Health (Status)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _uiInfoChip("Day: $_currentDay/${_selectedSeedData?.harvestingDays ?? '?'}", icon: Icons.calendar_today),
                  _uiInfoChip("💰 \$$_money", icon: Icons.account_balance_wallet),
                  _uiInfoChip(
                    "❤️ ${_cropHealth.toStringAsFixed(0)}% (${_getCropStatusText(_cropHealth)})",
                    icon: Icons.spa,
                    statusColor: _getHealthColor(_cropHealth), 
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Row for Item Icons (Fertilizer, Pest Spray, Shovel)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute space
                children: [
                  _buildItemIcon('Fertilizer'),
                  _buildItemIcon('Pest Spray'),
                  _buildItemIcon('Shovel'),
                  // _buildItemIcon('Hoe')
                ],
              ),
            ],
          ),
        ),
      ),

       // 3. Settings Button (Top Right Corner)
       // Commented out as per request
       /*
       Positioned(
         top: 16, // Match weather image top padding
         right: 16, // Distance from right
         child: Container(
            decoration: BoxDecoration(
                 color: Colors.black.withOpacity(0.6),
                 shape: BoxShape.circle
                ),
           child: IconButton(
             icon: Icon(Icons.settings, color: Colors.white, size: 30),
             onPressed: () {
               // TODO: Implement Settings functionality
               print("Settings button pressed!");
               // Example: Maybe show a settings dialog
             },
           ),
         ),
       ),
       */
    ];
  }

   // Helper to build an interactive item icon
   Widget _buildItemIcon(String itemName) {
     String? imagePath = _getItemImageAsset(itemName);
     // Use a generic icon if image is not found or null
     Widget iconWidget = imagePath != null
         ? Image.asset(
             imagePath,
             width: 40,
             height: 40,
             // fit: BoxFit.contain, // Added fit to prevent stretching
             errorBuilder: (context, error, stackTrace) => Icon(Icons.category, size: 40, color: Colors.white),
           )
         : Icon(Icons.category, size: 40, color: Colors.white);

     return Container(
        decoration: BoxDecoration(
           color: Colors.blueGrey.withOpacity(0.5), // Optional: background for the slot
           borderRadius: BorderRadius.circular(8)
        ),
        padding: const EdgeInsets.all(4),
       child: InkWell( // Use InkWell for tap feedback
         onTap: () {
           // TODO: Implement item usage logic here
           print("$itemName icon pressed!");
           // For now, maybe display a temporary message or just print
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text("Used $itemName! (Functionality not implemented yet)"),
               duration: Duration(seconds: 1),
             ),
           );
         },
         child: SizedBox( 
             width: 48,
             height: 48,
             child: Center(child: iconWidget)
         ),
       ),
     );
   }


  // check what is the current stage of game, and return matching UI
Widget _buildCurrentStageWidget() {
  switch (_currentStage) {
    case GameStage.intro:
      return _buildIntro(); // show intro screen
    case GameStage.terrainSelection:
      return _buildTerrainSelection(); // show terrain choosing UI
    case GameStage.seedSelection:
      return _buildSeedSelection(); // show seed choosing UI
    case GameStage.dailyCycle:
    case GameStage.weatherForecast:
    case GameStage.weatherEvent:
    case GameStage.playerWeatherAction:
    case GameStage.aiJudgement:

       // These stages use the central widget area for prompts/input/feedback
       // The main daily cycle action buttons are shown in _buildDailyCycleChoices
       // Weather/AI stages show their specific info panels
       switch(_currentStage) {
         case GameStage.dailyCycle: return _buildDailyCycleChoices();
         case GameStage.weatherForecast: return _buildWeatherForecastScreen();

         // The weather event screen triggers the weather image overlay visibility
         case GameStage.weatherEvent: return _buildWeatherEventScreen();
         case GameStage.playerWeatherAction: return _buildPlayerWeatherActionScreen();
         case GameStage.aiJudgement: return _buildAIJudgementScreen();
         default: return const SizedBox.shrink();
       }
    case GameStage.harvesting:
      // delay running harvest logic after current frame render
      WidgetsBinding.instance.addPostFrameCallback((_) async {
         // Add a slight delay before calculating harvest to make it feel less instantaneous
        await Future.delayed(const Duration(milliseconds: 500));
        if(mounted) {
            _calculateHarvest();
        }
      });
      // show text while harvest is calculating
      return _paperContainer(
        child: Text("Calculating harvest...", style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Futehodo-MaruGothic_1.00')),
      );
    case GameStage.results:
      return _buildResultsScreen(); // show final game result and outcome
    case GameStage.showTips:
      return _buildTipsScreen(); // show random farming tips
    case GameStage.gameOver:
      // show game over text and button to go home screen
      return _paperContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Game Over!", style: TextStyle(color: Colors.redAccent, fontSize: 24, fontFamily: 'Futehodo-MaruGothic_1.00', fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Your farm didn't make it.", style: TextStyle(color: Colors.white70, fontSize: 18, fontFamily: 'Futehodo-MaruGothic_1.00')),
            SizedBox(height: 20),
            _styledButton("Back to Home", _goToHomeScreen),
          ],
        ),
      );
    default:
      return const SizedBox.shrink(); // return empty widget if stage not match
  }
}

// -------------------- UI WIDGETS PER STAGE --------------------

  // Show intro message and skip button
Widget _buildIntro() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _paperContainer(
        padding: const EdgeInsets.all(20),
        child: Text(
          _introMessages[_currentMessageIndex], // show current intro message
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Futehodo-MaruGothic_1.00', fontSize: 20, color: Colors.white),
        ),
      ),
      const SizedBox(height: 20),
      _styledButton("Skip Intro", _skipIntro), // button to skip intro
    ],
  );
}

  // Show terrain options for player to pick
Widget _buildTerrainSelection() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _paperContainer(child: Text("Select Terrain", style: TextStyle(fontSize: 24, fontFamily: 'Futehodo-MaruGothic_1.00', color: Colors.white))),
      const SizedBox(height: 30),
      ..._terrainDescriptions.entries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _styledButton(
              "${entry.key}\n(${entry.value})", // show terrain name and its description
              () => _selectTerrain(entry.key),
              isMultiLine: true,
            ),
          )),
    ],
  );
}

// Show seed options to pick and display seed info
Widget _buildSeedSelection() {
  // We need specific keys for the specific layout shown in the second image
  const String adlayKey = 'Adlay Rice';
  const String cornKey = 'Corn';
  const String potatoKey = 'Potatoes';
  const String tomatoKey = 'Tomato';

  // You might want to add null checks here if _seedInfo could potentially be incomplete,
  // but assuming the map is correctly initialized.
  final SeedData? adlayData = _seedInfo[adlayKey];
  final SeedData? cornData = _seedInfo[cornKey];
  final SeedData? potatoData = _seedInfo[potatoKey];
  final SeedData? tomatoData = _seedInfo[tomatoKey];

  // Basic check to ensure seed data exists before trying to build buttons
  if (adlayData == null || cornData == null || potatoData == null || tomatoData == null) {
     return _paperContainer(child: Text("Error: Seed data not found!", style: TextStyle(color: Colors.red, fontFamily: 'Futehodo-MaruGothic_1.00')));
  }

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      _paperContainer(
        child: Text(
          "Select your starting seed",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontFamily: 'Futehodo-MaruGothic_1.00', color: Colors.white),
        ),
      ),
      const SizedBox(height: 30),

      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Corn Button
          _styledButton(
            cornData.name,
            () => _selectSeed(cornKey), // Pass the correct key to select the seed
          ),
          SizedBox(width: 10),

           _styledButton(
            potatoData.name,
            () => _selectSeed(potatoKey),
          ),
        ],
      ),
      const SizedBox(height: 10),

      _styledButton(
         adlayData.name,
         () => _selectSeed(adlayKey),
      ),
      const SizedBox(height: 10),

      _styledButton(
         tomatoData.name,
         () => _selectSeed(tomatoKey),
      ),

       const SizedBox(height: 20),
    ],
  );
}

  // Let player choose action for the day
Widget _buildDailyCycleChoices() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _paperContainer(
        child: Text(
          "Day $_currentDay of ${_selectedSeedData?.harvestingDays ?? 'N/A'}\nWhat will you do?",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontFamily: 'Futehodo-MaruGothic_1.00', color: Colors.white),
        ),
      ),
      const SizedBox(height: 20),
      _styledButton("Water (Free)", () => _handleDailyAction(DailyAction.water)),
      SizedBox(height: 10),
      _styledButton("Fertilize (\$20)", () => _handleDailyAction(DailyAction.fertilize)),
      SizedBox(height: 10),
      _styledButton("Weed/Pest Control (\$15)", () => _handleDailyAction(DailyAction.weedPest)),
      SizedBox(height: 10),
      _styledButton("Do Nothing (Risky)", () => _handleDailyAction(DailyAction.doNothing)),
    ],
  );
}

  // Simulate weather forecast animation
Widget _buildWeatherForecastScreen() {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
     // Delay slightly before generating forecast to show the "Forecasting..." text
    await Future.delayed(Duration(seconds: 1));
    if(mounted) { // Check if the widget is still in the tree
       _generateWeatherForecast();
    }
  });
  return _paperContainer(
    padding: const EdgeInsets.all(20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Weather Oracle says:", style: TextStyle(fontSize: 22, color: Colors.white, fontFamily: 'Futehodo-MaruGothic_1.00')),
        SizedBox(height:15),
        CircularProgressIndicator(color: Colors.white,),
        SizedBox(height:15),
        Text("Forecasting...", style: TextStyle(fontSize: 18, color: Colors.white70)),
      ],
    )
  );
}

  // Show weather warning and hint
Widget _buildWeatherEventScreen() {
  // Trigger the weather image overlay to show and start the fade timer
  WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
          _showWeatherImageOverlay = true;
      });
      // Start timer to hide it after 5 seconds
      _weatherImageTimer?.cancel(); // Cancel any previous timer
      _weatherImageTimer = Timer(const Duration(seconds: 5), () {
         if (mounted) { // Check if widget is still mounted before setting state
            setState(() {
              _showWeatherImageOverlay = false;
            });
         }
      });
  });

  return _paperContainer(
    padding: const EdgeInsets.all(20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Weather Alert!", style: TextStyle(fontSize: 24, color: Colors.orangeAccent, fontFamily: 'Futehodo-MaruGothic_1.00', fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        if(_currentWeatherHint != null)
          Text(_currentWeatherHint!, style: TextStyle(fontSize: 16, color: Colors.white70, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
        SizedBox(height: 15),
        Text("Incoming Event: ${_currentWeatherEvent ?? 'Loading...'}", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        SizedBox(height: 25),
        _styledButton("Continue", () => setState(() => _currentStage = GameStage.playerWeatherAction)),
      ],
    )
  );
}


  // Let player type their response to the weather event
Widget _buildPlayerWeatherActionScreen() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _paperContainer(
        child: Text(
          "${_currentWeatherEvent ?? 'Weather event'} is here!\nWhat should you do?",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontFamily: 'Futehodo-MaruGothic_1.00', color: Colors.white),
        ),
      ),
      const SizedBox(height: 20),
      _paperContainer(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: TextField(
          controller: _weatherResponseController,
          style: TextStyle(color: Colors.black87, fontFamily: 'Futehodo-MaruGothic_1.00'),
          decoration: InputDecoration(
            hintText: "Type your action (e.g., 'water', 'secure crops')",
            hintStyle: TextStyle(color: Colors.black45, fontFamily: 'Futehodo-MaruGothic_1.00'),
            border: InputBorder.none,
          ),
          onSubmitted: (_) => _processPlayerWeatherAction(),
        ),
      ),
      const SizedBox(height: 20),
      _styledButton("Submit Action", _processPlayerWeatherAction),
    ],
  );
}

  // Show AI response to player's action
Widget _buildAIJudgementScreen() {
  return _paperContainer(
    padding: const EdgeInsets.all(20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("AI Farmer Judges:", style: TextStyle(fontSize: 22, color: Colors.white, fontFamily: 'Futehodo-MaruGothic_1.00')),
        SizedBox(height: 10),
        Text(
          _aiJudgement == AIJudgementCategory.smartAndEffective ? "Smart & Effective!" :
          _aiJudgement == AIJudgementCategory.ineffectiveOrTooLate ? "Ineffective or Too Late..." :
          "Comedic / Useless...",
          style: TextStyle(
            fontSize: 20,
            color: _aiJudgement == AIJudgementCategory.smartAndEffective ? Colors.greenAccent :
                   _aiJudgement == AIJudgementCategory.ineffectiveOrTooLate ? Colors.orangeAccent : Colors.yellowAccent,
            fontWeight: FontWeight.bold,
             fontFamily: 'Futehodo-MaruGothic_1.00'
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height:10),
        Text(_aiJudgementFeedback, style: TextStyle(fontSize: 16, color: Colors.white70, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center),
        SizedBox(height:20),
        Text("Crop Health: ${_cropHealth.toStringAsFixed(1)}%", style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Futehodo-MaruGothic_1.00')),
        SizedBox(height:25),
        _styledButton("Next", _proceedFromAIJudgement),
      ],
    )
  );
}

// Function to show final results after gameplay (like summary screen)
// Shows crop name, quality, profit/loss, and next actions
  Widget _buildResultsScreen() {
    // Get the path for the Harvest Time image
    String? harvestImagePath = _getUIImageAsset('Harvest Time');

    // Check if player can continue based on game outcome
    bool canContinue = _gameOutcome == "Success!" || _gameOutcome == "Barely Survived";

    // Return a container styled like paper with summary info inside
    return _paperContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Display the "Harvest Time" image if available, otherwise show the text
          if (harvestImagePath != null)
             Image.asset(
                harvestImagePath,
                height: 60, // Adjust height as needed
                 // Add error builder in case image is missing
                errorBuilder: (context, error, stackTrace) => Text("Harvest Time!", style: TextStyle(fontSize: 28, color: Colors.amber, fontFamily: 'Futehodo-MaruGothic_1.00', fontWeight: FontWeight.bold)),
             )
          else
             Text("Harvest Time!", style: TextStyle(fontSize: 28, color: Colors.amber, fontFamily: 'Futehodo-MaruGothic_1.00', fontWeight: FontWeight.bold)),

          SizedBox(height: 15),

          // Show selected crop name or N/A if not chosen
          Text("Crop: ${_selectedSeedData?.name ?? 'N/A'}", style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Futehodo-MaruGothic_1.00')),

          // Show crop quality with different colors based on rating
          Text("Crop Quality: $_cropQuality", style: TextStyle(fontSize: 18, color: _cropQuality == "Excellent" ? Colors.greenAccent : (_cropQuality == "Failed" ? Colors.redAccent : Colors.yellowAccent), fontFamily: 'Futehodo-MaruGothic_1.00')),
          SizedBox(height: 10),
          
          // Investment and earning display
          Text("Total Investment: \$${_totalInvestment}", style: TextStyle(fontSize: 16, color: Colors.white70, fontFamily: 'Futehodo-MaruGothic_1.00')),
          Text("Harvest Value: \$${_harvestValue}", style: TextStyle(fontSize: 18, color: Colors.lightGreenAccent, fontWeight: FontWeight.bold, fontFamily: 'Futehodo-MaruGothic_1.00')),
          Divider(color: Colors.white54, height: 20, thickness: 1), // Divider line between sections

          // Show if profit or loss in bright color
          Text("Profit / Loss: \$${_profitOrLoss}", style: TextStyle(fontSize: 20, color: _profitOrLoss >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontFamily: 'Futehodo-MaruGothic_1.00')),
          SizedBox(height: 15),

          // Game result text
           Text("Overall Outcome: $_gameOutcome", style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Futehodo-MaruGothic_1.00')),
          SizedBox(height: 25),

          // If allowed to continue, show button
          if(canContinue)
            _styledButton("Continue Planting", _resetGameForContinue), 
          SizedBox(height: 10),
          // If can't continue (failed), the button quits the season/ends the game
          _styledButton(canContinue ? "Quit Farming" : "End Season", _quitGame),
        ],
      )
    );
  }

// Function to show random farming tip on screen
// Called maybe between levels or after player fails
   Widget _buildTipsScreen() {
    final random = Random();
    String tip = _gameTips[random.nextInt(_gameTips.length)]; // Pick a random tip from list
    return _paperContainer( // Return paper-styled screen with tip
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           // Show the farming tip in italics
          Text("Farmer's Almanac", style: TextStyle(fontSize: 22, color: Colors.white, fontFamily: 'Futehodo-MaruGothic_1.00')),
          SizedBox(height:15),
          Text(tip, style: TextStyle(fontSize: 18, color: Colors.white70, fontStyle: FontStyle.italic, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center),
          SizedBox(height:25),
          _styledButton("Back to Home Screen", _goToHomeScreen),
        ],
      )
    );
  }

  // -------------------- REUSABLE UI HELPERS --------------------

  // Styled button reused in many screens
// isMultiLine decides padding/font size
  Widget _styledButton(String label, VoidCallback onPressed, {bool isMultiLine = false}) {
    return _paperContainer(
      padding: EdgeInsets.zero,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: isMultiLine ? 12 : 24, vertical: isMultiLine ? 10: 12),
            minimumSize: Size(150, 40)
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Futehodo-MaruGothic_1.00', fontSize: isMultiLine ? 16 : 18, color: Colors.white),
        ),
      ),
    );
  }

// Makes a container that looks like paper with shadow
// Used to wrap different parts of UI
Widget _paperContainer({
  required Widget child,
  EdgeInsets padding = const EdgeInsets.all(12),
  Alignment? alignment, // Added alignment parameter
}) {
  return Container(
    alignment: alignment, // Apply alignment
    padding: padding,
    decoration: BoxDecoration(
      image: const DecorationImage(
        image: AssetImage('assets/images/Paper.png'),
        fit: BoxFit.fill,
      ),
      borderRadius: BorderRadius.circular(5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 5,
          offset: const Offset(2, 3),
        ),
      ],
    ),
    child: child,
  );
}

//get color for crop health: green = good, orange = okay, red = bad
  Color _getHealthColor(double health){
    if(health > 75) return Colors.green.withOpacity(0.8);
    if(health > 45) return Colors.orange.withOpacity(0.8);
    return Colors.red.withOpacity(0.8);
  }

// Get text for crop status based on health
String _getCropStatusText(double health) {
    if (health > 90) return "Excellent";
    if (health > 70) return "Good";
    if (health > 40) return "Moderate";
    if (health > 10) return "Poor";
    return "Bad";
}

// Builds one small info chip with icon and text
// Used for day, money, health info
  Widget _uiInfoChip(String text, {IconData? icon, Color? statusColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor ?? Colors.blueGrey.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, color: Colors.white, size: 16),
          if (icon != null) SizedBox(width: 5),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Futehodo-MaruGothic_1.00', fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

// Called when the widget is removed from the screen (important for memory)
// Disposes controller and timer to clean up
   @override
  void dispose() {
    _weatherResponseController.dispose();
    _weatherImageTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }
}