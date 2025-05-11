import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'home.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

// Holds information for each seed type
class SeedData {
  final String name;
  final int harvestingDays;
  final String iconAsset;
  final List<String> strengths;
  final List<String> weaknesses;

  SeedData({
    required this.name,
    required this.harvestingDays,
    required this.iconAsset,
    required this.strengths,
    required this.weaknesses,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'harvestingDays': harvestingDays,
      'iconAsset': iconAsset,
      'strengths': strengths,
      'weaknesses': weaknesses,
    };
  }
}

enum GameStage {
  intro,
  terrainSelection,
  seedSelection,
  dailyCycle,
  weatherForecast,
  weatherEvent,
  playerWeatherAction,
  aiJudgement,
  harvesting,
  results,
  showTips,
  loadingToHome
}

// Player's possible actions each day
enum DailyAction { water, fertilize, weedPest, prepareSoil, doNothing }

// AI's judgement categories
enum AIJudgementCategory { smartAndEffective, ineffectiveOrTooLate, comedicUseless }

// Main screen for the game
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameStage _currentStage = GameStage.intro;
  int _currentMessageIndex = 0;

  String? _selectedTerrain;
  SeedData? _selectedSeedData;

  int _money = 200;
  int _currentDay = 1;
  double _cropHealth = 100.0;
  String _cropStatusMessage = "Ready to plant!";
  int _totalInvestment = 0;

  // Player's inventory
  Map<String, int> _inventory = {
    'Fertilizer': 2,
    'Pest Spray': 2,
    'Shovel': 1,
  };

  String? _currentWeatherHint;
  String? _currentWeatherEvent;
  String? _playerWeatherResponse;
  AIJudgementCategory? _aiJudgement;
  String _aiJudgementFeedback = "";

  bool _showWeatherImageOverlay = false;
  Timer? _weatherImageTimer;

  // Harvest results
  String _cropQuality = "Unknown";
  int _harvestValue = 0;
  int _profitOrLoss = 0;
  String _gameOutcome = "";

  final TextEditingController weatherResponseController = TextEditingController();

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
        harvestingDays: 12,
        iconAsset: 'assets/images/adlay_seed_icon.png',
        strengths: ['Rainy', 'Flooding'],
        weaknesses: ['Heatwave', 'Locust Swarm']),
    'Corn': SeedData(
        name: 'Corn',
        harvestingDays: 9,
        iconAsset: 'assets/images/corn_seed_icon.png',
        strengths: ['Sunny', 'Heatwave'],
        weaknesses: ['Flooding', 'Thunderstorm']),
    'Potatoes': SeedData(
        name: 'Potatoes',
        harvestingDays: 10,
        iconAsset: 'assets/images/potato_seed_icon.png',
        strengths: ['Cloudy', 'Thunderstorm'],
        weaknesses: ['Heatwave', 'Locust Swarm']),
    'Tomato': SeedData(
        name: 'Tomato',
        harvestingDays: 7,
        iconAsset: 'assets/images/tomato_seed_icon.png',
        strengths: ['Sunny'],
        weaknesses: ['Typhoon', 'Flooding', 'Heatwave']),
    'Mango': SeedData(
        name: 'Mango',
        harvestingDays: 15,
        iconAsset: 'assets/images/mango_seed_icon.png',
        strengths: ['Sunny', 'Heatwave'],
        weaknesses: ['Typhoon', 'Locust Swarm']),
     'Coconut': SeedData(
         name: 'Coconut',
         harvestingDays: 18,
         iconAsset: 'assets/images/coconut_seed_icon.png',
         strengths: ['Sunny', 'Rainy'],
         weaknesses: ['Flooding', 'Typhoon']),
     'Ampalaya': SeedData(
         name: 'Ampalaya',
         harvestingDays: 8,
         iconAsset: 'assets/images/ampalaya_seed_icon.png',
         strengths: ['Rainy', 'Cloudy'],
         weaknesses: ['Heatwave', 'Locust Swarm', 'Pests']),
  };

  List<String> _availableSeedKeys = [];
  final int _numberOfSeedOptions = 4;

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
  List<String> _allWeatherEvents = [];

  // Image assets for weather
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

  final Map<String, String> _itemImageAssets = {
    'Fertilizer': 'assets/images/fertilizer.png',
    'Pest Spray': 'assets/images/pest spray.png',
    'Shovel': 'assets/images/shovel.png',
  };

  final Map<String, String> _uiImageAssets = {
    'Harvest Time': 'assets/images/HarvestTime 1.png',
  };

  // Tips displayed at the end of a season
  final List<String> _gameTips = [
    "Tip: Matching seeds to terrain strengths can boost your harvest!",
    "Tip: Pay attention to weather forecasts; they can save your crops.",
    "Tip: Fertilizing at the right time can significantly improve crop health.",
    "Tip: Some disasters are unavoidable, but smart choices can mitigate damage.",
    "Tip: Keep an eye on your item stock! Some actions require tools.",
    "Tip: 'Preparing Soil' uses a shovel and can give a small health boost.",
  ];

  Future<File> _getLogFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/gamestate_log.jsonl');
  }

  // Appends a state snapshot to the log file
  Future<void> _logGameState(String eventType, {String? eventDetails}) async {
    try {
      final file = await _getLogFile();
      final timestamp = DateTime.now().toIso8601String();

      final Map<String, dynamic> stateSnapshot = {
        'timestamp': timestamp,
        'currentStage': _currentStage.toString().split('.').last,
        'eventType': eventType,
        'eventDetails': eventDetails,
        'day': _currentDay,
        'money': _money,
        'cropHealth': _cropHealth,
        'cropStatusMessage': _cropStatusMessage,
        'totalInvestment': _totalInvestment,
        'inventory': _inventory,
        'selectedTerrain': _selectedTerrain,
        'selectedSeed': _selectedSeedData?.toMap(),
        'weatherHint': _currentWeatherHint,
        'weatherEvent': _currentWeatherEvent,
        'playerWeatherResponse': _playerWeatherResponse,
        'aiJudgement': _aiJudgement?.toString().split('.').last,
        'aiJudgementFeedback': _aiJudgementFeedback,
        if (_currentStage == GameStage.results) ...{
          'cropQuality': _cropQuality,
          'harvestValue': _harvestValue,
          'profitOrLoss': _profitOrLoss,
          'gameOutcome': _gameOutcome,
        },
      };

      final String jsonLine = jsonEncode(stateSnapshot);
      await file.writeAsString('$jsonLine\n', mode: FileMode.append);
    } catch (e) {
      print('Error logging game state: $e');
    }
  }

  // Clears the game state log file
  Future<void> _clearLogFile() async {
    try {
      final file = await _getLogFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error clearing game state log: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _allWeatherEvents = [..._normalWeatherEvents, ..._disasterWeatherEvents];
    _clearLogFile();
    _startIntroSequence();
    _logGameState('AppStart', eventDetails: 'Intro sequence started');
  }

  // Displays intro messages sequentially
  void _startIntroSequence() async {
    _currentStage = GameStage.intro;
    _logGameState('StageChange', eventDetails: 'Intro');
    for (int i = 0; i < _introMessages.length; i++) {
      if (!mounted) return;
      setState(() => _currentMessageIndex = i);
      await Future.delayed(Duration(seconds: i == 0 ? 2 : 3));
    }
    if (!mounted) return;
    setState(() => _currentStage = GameStage.terrainSelection);
     _logGameState('StageChange', eventDetails: 'Terrain Selection');
  }

  // Skips the intro messages
  void _skipIntro() {
    setState(() => _currentStage = GameStage.terrainSelection);
    _logGameState('Action', eventDetails: 'Skipped Intro');
    _logGameState('StageChange', eventDetails: 'Terrain Selection');
  }

  // Sets the selected terrain and moves to seed selection
  void _selectTerrain(String terrain) {
    _generateRandomSeedOptions();

    setState(() {
      _selectedTerrain = terrain;
      _currentStage = GameStage.seedSelection;
    });
    _logGameState('Action', eventDetails: 'Selected Terrain: $terrain');
    _logGameState('StageChange', eventDetails: 'Seed Selection');
  }

  // Generates random seed options for the season
  void _generateRandomSeedOptions() {
      final random = Random();
      final allSeedKeys = _seedInfo.keys.toList();
      allSeedKeys.shuffle(random);
      _availableSeedKeys = allSeedKeys.take(min(_numberOfSeedOptions, allSeedKeys.length)).toList();
       _logGameState('SeedOptionsGenerated', eventDetails: 'Available seeds: ${_availableSeedKeys.join(', ')}');
  }

  // Sets the selected seed, resets game state, and starts the daily cycle
  void _selectSeed(String seedKey) {
    setState(() {
      _selectedSeedData = _seedInfo[seedKey];
      _totalInvestment = 0;
      _currentDay = 1;
      _cropHealth = 100.0;
      _inventory = {
        'Fertilizer': 2,
        'Pest Spray': 2,
        'Shovel': 1,
      };
      _cropStatusMessage = "Planted ${_selectedSeedData!.name}";
      _currentStage = GameStage.dailyCycle;
    });
    _logGameState('Action', eventDetails: 'Selected Seed: $seedKey');
    _logGameState('StageChange', eventDetails: 'Daily Cycle');
  }

  // Handles the player's chosen daily action
  void _handleDailyAction(DailyAction action) {
    if (_selectedSeedData == null) return;
    String actionMessage = "";
    int cost = 0;
    double healthChange = 0;
    String? itemConsumed;
    bool canPerformAction = true;

    _logGameState('PlayerAction', eventDetails: 'Attempted Daily Action: ${action.toString().split('.').last}');

    switch (action) {
      case DailyAction.water:
        actionMessage = "You watered the crops.";
        healthChange = 5;
        break;
      case DailyAction.fertilize:
        cost = 20;
        itemConsumed = 'Fertilizer';
        if ((_inventory[itemConsumed] ?? 0) > 0 && _money >= cost) {
          _money -= cost;
          _totalInvestment += cost;
          _inventory[itemConsumed] = (_inventory[itemConsumed] ?? 0) - 1;
          actionMessage = "You fertilized the crops (Used 1x $itemConsumed). Cost: ₱$cost";
          healthChange = 15;
        } else {
          canPerformAction = false;
          if (_money < cost) actionMessage = "Not enough money to fertilize! Needs ₱$cost.";
          else actionMessage = "You need Fertilizer to do that! You have ${_inventory[itemConsumed] ?? 0}.";
        }
        break;
      case DailyAction.weedPest:
        cost = 15;
        itemConsumed = 'Pest Spray';
        if ((_inventory[itemConsumed] ?? 0) > 0 && _money >= cost) {
          _money -= cost;
          _totalInvestment += cost;
          _inventory[itemConsumed] = (_inventory[itemConsumed] ?? 0) - 1;
          actionMessage = "You applied weed/pest control (Used 1x $itemConsumed). Cost: ₱$cost";
          healthChange = 10;
        } else {
          canPerformAction = false;
          if (_money < cost) actionMessage = "Not enough money for weed/pest control! Needs ₱$cost.";
          else actionMessage = "You need Pest Spray to do that! You have ${_inventory[itemConsumed] ?? 0}.";
        }
        break;
      case DailyAction.prepareSoil:
        cost = 10;
        itemConsumed = 'Shovel';
        if ((_inventory[itemConsumed] ?? 0) > 0 && _money >= cost) {
          _money -= cost;
          _totalInvestment += cost;
          actionMessage = "You prepared the soil with the Shovel. Cost: ₱$cost";
          healthChange = 8;
        } else {
          canPerformAction = false;
          if (_money < cost) actionMessage = "Not enough money to prepare soil! Needs ₱$cost.";
          else actionMessage = "You need a Shovel to prepare the soil! You have ${_inventory[itemConsumed] ?? 0}.";
        }
        break;
      case DailyAction.doNothing:
        actionMessage = "You chose to do nothing for the day.";
        healthChange = -5;
        break;
    }

    if (canPerformAction || action == DailyAction.water || action == DailyAction.doNothing) {
      _cropHealth = (_cropHealth + healthChange).clamp(0.0, 100.0);

      _logGameState(
        'DailyActionOutcome',
        eventDetails: '${action.toString().split('.').last} - Success: $canPerformAction, HealthChange: $healthChange, NewHealth: $_cropHealth',
      );

      if (_cropHealth <= 0) {
        _cropStatusMessage = "$actionMessage Your crops have withered!";
      } else {
        _cropStatusMessage = "$actionMessage Crop health: ${_cropHealth.toStringAsFixed(1)}%";
      }

      setState(() {
        _currentStage = GameStage.weatherForecast;
      });
      _logGameState('StageChange', eventDetails: 'Weather Forecast');

    } else {
      setState(() {
        _cropStatusMessage = actionMessage;
      });
       _logGameState(
        'DailyActionOutcome',
        eventDetails: '${action.toString().split('.').last} - Failed (Insufficient Funds/Items)',
      );
    }
  }

  // Generates a weather forecast and the actual weather event
  void _generateWeatherForecast() {
    if (_selectedSeedData == null) return;
    final random = Random();
    String upcomingWeather;

    bool isDisasterForecastLikely = random.nextDouble() < 0.3;

    if (isDisasterForecastLikely) {
      if (_selectedSeedData!.weaknesses.isNotEmpty && random.nextBool()) {
        List<String> possibleDisasters = _disasterWeatherEvents.where(_selectedSeedData!.weaknesses.contains).toList();
        if(possibleDisasters.isNotEmpty){
          upcomingWeather = possibleDisasters[random.nextInt(possibleDisasters.length)];
          _currentWeatherHint = "Warning! A challenging weather event related to ${_selectedSeedData!.weaknesses.join('/')} might be coming: '$upcomingWeather'.";
        } else {
          upcomingWeather = _disasterWeatherEvents[random.nextInt(_disasterWeatherEvents.length)];
          _currentWeatherHint = "The air feels heavy... Expect potential danger.";
        }
      } else {
        upcomingWeather = _disasterWeatherEvents[random.nextInt(_disasterWeatherEvents.length)];
        _currentWeatherHint = "Be prepared! Extreme weather is possible.";
      }
    } else {
      if (_selectedSeedData!.strengths.isNotEmpty && random.nextBool()) {
        List<String> possibleNormalStrengths = _normalWeatherEvents.where(_selectedSeedData!.strengths.contains).toList();
        if(possibleNormalStrengths.isNotEmpty){
          upcomingWeather = possibleNormalStrengths[random.nextInt(possibleNormalStrengths.length)];
          _currentWeatherHint = "Forecast looks good! Weather favorable to your crops might arrive: '$upcomingWeather'.";
        } else {
          upcomingWeather = _normalWeatherEvents[random.nextInt(_normalWeatherEvents.length)];
          _currentWeatherHint = "Expect typical weather conditions.";
        }
      } else {
        upcomingWeather = _normalWeatherEvents[random.nextInt(_normalWeatherEvents.length)];
        _currentWeatherHint = "An interesting weather pattern is forming.";
      }
    }

    bool isActualWeatherDisaster = random.nextDouble() < 0.2;
    if (isActualWeatherDisaster) {
      _currentWeatherEvent = _disasterWeatherEvents[random.nextInt(_disasterWeatherEvents.length)];
    } else {
      _currentWeatherEvent = _normalWeatherEvents[random.nextInt(_normalWeatherEvents.length)];
    }

    setState(() {
      _currentStage = GameStage.weatherEvent;
    });
    _logGameState(
        'WeatherGenerated',
        eventDetails: 'Forecast: $_currentWeatherHint, Actual: $_currentWeatherEvent'
    );
     _logGameState('StageChange', eventDetails: 'Weather Event');
  }

  // Processes the player's typed action during a weather event and calculates effects
  void _processPlayerWeatherAction() {
    final playerInput = weatherResponseController.text.toLowerCase().trim();
    _playerWeatherResponse = playerInput.isEmpty ? "[No Action]" : playerInput;

    _logGameState(
        'PlayerWeatherInput',
        eventDetails: 'Input: "$playerInput", Weather Event: "$_currentWeatherEvent"'
    );

    bool isDisaster = _disasterWeatherEvents.contains(_currentWeatherEvent);
    _aiJudgementFeedback = "";
    AIJudgementCategory potentialJudgement = AIJudgementCategory.comedicUseless;
    double healthEffect = 0;
    bool recognizedAction = false;
    bool effectiveActionTaken = false;

    double initialHealth = _cropHealth;

    if (playerInput.isEmpty) {
      recognizedAction = true;
      healthEffect = isDisaster ? -30 : -5;
      potentialJudgement = isDisaster ? AIJudgementCategory.ineffectiveOrTooLate : AIJudgementCategory.ineffectiveOrTooLate;
      _aiJudgementFeedback = "Doing nothing during a disaster ($_currentWeatherEvent) was very risky!";
    } else {
      if ((playerInput.contains("spray") || playerInput.contains("pest") || playerInput.contains("bug")) && (_currentWeatherEvent == 'Locust Swarm')) {
        recognizedAction = true;
        String item = 'Pest Spray';
        if ((_inventory[item] ?? 0) > 0) {
          _inventory[item] = (_inventory[item] ?? 0) - 1;
          healthEffect += 30;
          potentialJudgement = AIJudgementCategory.smartAndEffective;
          _aiJudgementFeedback = "Using $item directly against the $_currentWeatherEvent was highly effective!";
          effectiveActionTaken = true;
        } else {
          healthEffect -= 15;
          potentialJudgement = AIJudgementCategory.ineffectiveOrTooLate;
          _aiJudgementFeedback = "You tried to use $item against $_currentWeatherEvent but didn't have any left! You have ${_inventory[item] ?? 0}.";
        }
      } else if ((playerInput.contains("fertilize") || playerInput.contains("nutrients")) && !isDisaster) {
        recognizedAction = true;
        String item = 'Fertilizer';
        if ((_inventory[item] ?? 0) > 0) {
          _inventory[item] = (_inventory[item] ?? 0) - 1;
          healthEffect += 15;
          potentialJudgement = AIJudgementCategory.smartAndEffective;
          _aiJudgementFeedback = "Applying $item provided valuable nutrients for growth.";
          effectiveActionTaken = true;
        } else {
          healthEffect -= 5;
          potentialJudgement = AIJudgementCategory.ineffectiveOrTooLate;
          _aiJudgementFeedback = "You wanted to fertilize but ran out! You have ${_inventory[item] ?? 0}.";
        }
      } else if ((playerInput.contains("water") || playerInput.contains("irrigate")) && (_currentWeatherEvent == "Heatwave (El Nino)" || _currentWeatherEvent == "Sunny")) {
        recognizedAction = true;
        healthEffect += (isDisaster ? 20 : 10);
        potentialJudgement = AIJudgementCategory.smartAndEffective;
        _aiJudgementFeedback = "Watering helped counter the dry effects of $_currentWeatherEvent.";
        effectiveActionTaken = true;
      } else if ((playerInput.contains("prepare") || playerInput.contains("reinforce") || playerInput.contains("secure") || playerInput.contains("shovel")) && isDisaster) {
        recognizedAction = true;
        String item = 'Shovel';
        if ((_inventory[item] ?? 0) > 0) {
          healthEffect += 15;
          potentialJudgement = AIJudgementCategory.smartAndEffective;
          _aiJudgementFeedback = "You took steps to prepare the farm for $_currentWeatherEvent.";
          effectiveActionTaken = true;
        } else {
          healthEffect -= 10;
          potentialJudgement = AIJudgementCategory.ineffectiveOrTooLate;
          _aiJudgementFeedback = "You wanted to prepare for $_currentWeatherEvent, but lacked the necessary tools! You need a Shovel.";
        }
      } else if ((playerInput.contains("ignore") || playerInput.contains("nothing"))) {
        recognizedAction = true;
        healthEffect -= (isDisaster ? 25 : 10);
        potentialJudgement = AIJudgementCategory.ineffectiveOrTooLate;
        _aiJudgementFeedback = "Ignoring $_currentWeatherEvent proved costly!";
      } else if (playerInput.contains("harvest") && isDisaster && _currentDay < (_selectedSeedData?.harvestingDays ?? 99)) {
        recognizedAction = true;
        healthEffect -= 10;
        potentialJudgement = AIJudgementCategory.ineffectiveOrTooLate;
        _aiJudgementFeedback = "Emergency harvest during $_currentWeatherEvent? Risky, might not yield much.";
      }

      if (!recognizedAction) {
        healthEffect -= (isDisaster ? 15 : 5);
        potentialJudgement = AIJudgementCategory.comedicUseless;
        _aiJudgementFeedback = "'$playerInput'... an interesting response to $_currentWeatherEvent. The crops are confused.";
      }
    }

    double traitEffect = 0;
    bool weatherMatchesWeakness = _selectedSeedData != null && _selectedSeedData!.weaknesses.contains(_currentWeatherEvent);
    bool weatherMatchesStrength = _selectedSeedData != null && _selectedSeedData!.strengths.contains(_currentWeatherEvent);

    if (weatherMatchesWeakness) {
      traitEffect = isDisaster && effectiveActionTaken ? -5 : -15;
      _cropStatusMessage = "${_currentWeatherEvent} impacted your crops!";
    } else if (weatherMatchesStrength) {
      traitEffect = 8;
      _cropStatusMessage = "${_currentWeatherEvent} was beneficial for your crops!";
    } else {
      if (!_cropStatusMessage.contains("You ")) {
         _cropStatusMessage = "${_selectedSeedData?.name} status update:";
      }
    }

    _cropHealth = (_cropHealth + healthEffect + traitEffect).clamp(0.0, 100.0);

    if (_cropHealth <= 0) {
      _cropStatusMessage += "\nYour crops didn't survive the day.";
    } else {
       if (!_cropStatusMessage.contains("withered")) {
         _cropStatusMessage += " (Health: ${_cropHealth.toStringAsFixed(0)}%)";
       }
    }

    _aiJudgement = potentialJudgement;
    weatherResponseController.clear();

    _logGameState(
        'WeatherEventOutcome',
        eventDetails: 'Event: "$_currentWeatherEvent", PlayerInput: "$_playerWeatherResponse", HealthEffect: $healthEffect, TraitEffect: $traitEffect, TotalHealthChange: ${(_cropHealth - initialHealth).toStringAsFixed(1)}, FinalHealth: ${_cropHealth.toStringAsFixed(1)}, AIJudgement: ${_aiJudgement.toString().split('.').last}, Feedback: "$_aiJudgementFeedback"'
    );

    setState(() {
      _currentStage = GameStage.aiJudgement;
    });
     _logGameState('StageChange', eventDetails: 'AI Judgement');
  }

  // Proceeds from AI judgement to next day or harvest
  void _proceedFromAIJudgement() {
    if (_selectedSeedData == null) return;

    if (_currentDay >= (_selectedSeedData?.harvestingDays ?? 99) || _cropHealth <= 0) {
      setState(() {
        _currentStage = GameStage.harvesting;
      });
      _logGameState('StageChange', eventDetails: 'Harvesting');
    } else {
      setState(() {
        _currentDay++;
        _currentStage = GameStage.dailyCycle;
      });
      _logGameState('NewDay', eventDetails: 'Day $_currentDay started');
      _logGameState('StageChange', eventDetails: 'Daily Cycle');
    }
  }

  // Calculates the harvest results based on crop health and investment
  void _calculateHarvest() {
    if (_selectedSeedData == null) return;

    _logGameState('CalculatingHarvest', eventDetails: 'Starting harvest calculation...');

    if (_cropHealth > 90) {
      _cropQuality = "Excellent";
    } else if (_cropHealth > 70) _cropQuality = "Good";
    else if (_cropHealth > 40) _cropQuality = "Average";
    else if (_cropHealth > 10) _cropQuality = "Poor";
    else _cropQuality = "Failed";

    int baseValuePerDay = 10 + (_selectedSeedData!.harvestingDays);
    double qualityMultiplier = (_cropQuality == "Excellent") ? 2.5 :
                               (_cropQuality == "Good") ? 1.8 :
                               (_cropQuality == "Average") ? 1.0 :
                               (_cropQuality == "Poor") ? 0.4 : 0.0;

    _harvestValue = (_cropHealth <= 0 || _cropQuality == "Failed") ? 0 :
      (baseValuePerDay * _selectedSeedData!.harvestingDays * qualityMultiplier * (_cropHealth / 100.0)).toInt();

    _profitOrLoss = _harvestValue - _totalInvestment;
    _money += _profitOrLoss;

    if (_profitOrLoss > 100 && _cropQuality == "Excellent") {
      _gameOutcome = "Great Success!";
    } else if (_profitOrLoss > 0 && (_cropQuality == "Excellent" || _cropQuality == "Good")) {
       _gameOutcome = "Success!";
    } else if (_profitOrLoss >= -50 && (_cropQuality == "Average" || _cropQuality == "Poor")) {
      _gameOutcome = "Barely Survived";
    } else {
      _gameOutcome = "Failed Season";
    }

    _logGameState(
        'HarvestResults',
        eventDetails: 'Quality: $_cropQuality, Investment: $_totalInvestment, HarvestValue: $_harvestValue, Profit/Loss: $_profitOrLoss, Outcome: $_gameOutcome'
    );

    setState(() {
      _currentStage = GameStage.showTips;
    });
     _logGameState('StageChange', eventDetails: 'Show Tips Screen');
  }

  // Resets necessary state for a new season
  void _resetGameForContinue() {
    _generateRandomSeedOptions();

    setState(() {
      _currentStage = GameStage.terrainSelection;
      _selectedTerrain = null;
      _selectedSeedData = null;
      _currentDay = 1;
      _cropHealth = 100.0;
      _cropStatusMessage = "Ready for a new season!";
      _totalInvestment = 0;
      _inventory = {
        'Fertilizer': 2,
        'Pest Spray': 2,
        'Shovel': 1,
      };
    });
     _logGameState('GameReset', eventDetails: 'Starting a new season.');
     _logGameState('StageChange', eventDetails: 'Terrain Selection');
  }

  // Ends the current season and shows the summary tips screen
  void _quitGame() {
     setState(() {
       _currentStage = GameStage.showTips;
       _logGameState('GameEnded', eventDetails: 'Ended season. Money: ₱$_money. Outcome: $_gameOutcome');
       _logGameState('StageChange', eventDetails: 'Show Tips Screen (Manual End)');
     });
  }

  // Navigates back to the home screen after a loading state
  void _goToHomeScreen() {
     _logGameState('AppQuitIntent', eventDetails: 'Returning to Home Screen via Tips');
     setState(() {
       _currentStage = GameStage.loadingToHome;
     });
     _logGameState('StageChange', eventDetails: 'Loading to Home Screen');

     WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
             _clearLogFile();
             Navigator.of(context).pushAndRemoveUntil(
               MaterialPageRoute(builder: (context) => HomeScreen()),
                   (Route<dynamic> route) => false,
             );
        }
     });
  }

  // Determines the background image based on the current game stage or selected terrain
  String _getDynamicBackground() {
    if (_currentStage == GameStage.intro ||
        _currentStage == GameStage.terrainSelection ||
        _currentStage == GameStage.seedSelection ||
        _currentStage == GameStage.showTips ||
        _currentStage == GameStage.loadingToHome
        ) {
      return 'assets/images/Title Screen.png';
    }

    if (_selectedTerrain != null) {
      switch (_selectedTerrain) {
        case 'Mountain': return 'assets/images/Mountain.png';
        case 'Hills': return 'assets/images/Hill.png';
        case 'Lowlands': return 'assets/images/Lowlands.png';
      }
    }
    return 'assets/images/Title Screen.png';
  }

  String? _getWeatherImageAsset(String? event) {
    if (event == null) return null;
    return _weatherImageAssets[event];
  }

  String? _getItemImageAsset(String itemName) {
    return _itemImageAssets[itemName];
  }

  String? _getUIImageAsset(String imageName) {
    return _uiImageAssets[imageName];
  }

  @override
  Widget build(BuildContext context) {
    bool inGameplay = [
      GameStage.dailyCycle,
      GameStage.weatherForecast,
      GameStage.weatherEvent,
      GameStage.playerWeatherAction,
      GameStage.aiJudgement,
      GameStage.harvesting,
      GameStage.results,
    ].contains(_currentStage);

    bool bottomBarVisibleArea = inGameplay || _currentStage == GameStage.showTips;

    double topPadding = 80.0;
    double bottomPadding = bottomBarVisibleArea ? 150.0 : 40.0;

    if (_currentStage == GameStage.intro) {
       topPadding = 100.0;
       bottomPadding = 100.0;
    } else if (_currentStage == GameStage.loadingToHome) {
       topPadding = 0; bottomPadding = 0;
    }

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            _getDynamicBackground(),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          if (_currentStage != GameStage.loadingToHome)
            Positioned(
              top: topPadding,
              bottom: bottomPadding,
              left: 0,
              right: 0,
              child: Align(
                 alignment: Alignment.center,
                 child: SingleChildScrollView(
                   physics: const AlwaysScrollableScrollPhysics(),
                   child: Column(
                     mainAxisSize: MainAxisSize.min,
                     mainAxisAlignment: MainAxisAlignment.center,
                     crossAxisAlignment: CrossAxisAlignment.center,
                     children: [
                       _buildCurrentStageWidget(),
                     ],
                   ),
                 ),
              ),
            ),

          // Loading screen content
          if (_currentStage == GameStage.loadingToHome)
             Positioned.fill(
                child: Container(
                   color: Colors.black.withOpacity(0.5),
                   child: Center(
                       child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           mainAxisSize: MainAxisSize.min,
                           children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 20),
                                Text("Returning to Home...", style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Futehodo-MaruGothic_1.00')),
                           ],
                       ),
                   ),
                ),
             ),

          if (_showWeatherImageOverlay)
             Positioned(
               top: 80,
               left: 0,
               right: 0,
               child: AnimatedOpacity(
                 opacity: _showWeatherImageOverlay ? 1.0 : 0.0,
                 duration: const Duration(milliseconds: 500),
                 child: Center(
                   child: _buildWeatherImageOverlayWidget(),
                 ),
               ),
             ),

          if (inGameplay || _currentStage == GameStage.showTips)
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
                               Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                      _buildItemInfoWidget('Fertilizer', _inventory['Fertilizer'] ?? 0),
                                      _buildItemInfoWidget('Pest Spray', _inventory['Pest Spray'] ?? 0),
                                      _buildItemInfoWidget('Shovel', _inventory['Shovel'] ?? 0),
                                  ],
                               ),
                               SizedBox(height: 8),
                               Text(
                                 _cropStatusMessage,
                                 style: TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic, fontFamily: 'Futehodo-MaruGothic_1.00'),
                                 textAlign: TextAlign.center,
                               ),
                               SizedBox(height: 8),

                               Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                 children: [
                                   Flexible(child: _uiInfoChip("Day: $_currentDay/${_selectedSeedData?.harvestingDays ?? '?'}", icon: Icons.calendar_today)),
                                   Flexible(child: _uiInfoChip("₱ \$$_money", icon: Icons.account_balance_wallet)),
                                   Flexible(child: _uiInfoChip(
                                     "❤️ ${_cropHealth.toStringAsFixed(0)}%",
                                     icon: Icons.spa,
                                     statusColor: _getHealthColor(_cropHealth),
                                   )),
                                   Flexible(child: Text("(${_getCropStatusText(_cropHealth)})", style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Futehodo-MaruGothic_1.00'), overflow: TextOverflow.ellipsis)),
                                 ],
                               ),
                           ],
                       ),
                   ),
              ),
        ],
      ),
    );
  }

  Widget _buildWeatherImageOverlayWidget() {
      String? weatherImagePath = _getWeatherImageAsset(_currentWeatherEvent);
      if (weatherImagePath == null || !_showWeatherImageOverlay) {
          return const SizedBox.shrink();
      }

      return Center(
        child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Text("Weather Event", style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center,),
                    SizedBox(height: 4),
                    Image.asset(
                        weatherImagePath,
                        width: 60,
                        height: 60,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.cloud_queue, size: 60, color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(_currentWeatherEvent ?? 'Unknown', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Futehodo-MaruGothic_1.00')),
                ],
            ),
        ),
      );
  }

  Widget _buildItemInfoWidget(String itemName, int quantity) {
      String? imagePath = _getItemImageAsset(itemName);
      Widget iconWidget = imagePath != null
          ? Image.asset(
              imagePath,
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.category, size: 24, color: Colors.white70),
            )
          : Icon(Icons.category, size: 24, color: Colors.white70);

      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
             color: const Color.fromARGB(255, 96, 139, 104).withOpacity(0.5),
             borderRadius: BorderRadius.circular(5)
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
                iconWidget,
                SizedBox(width: 4),
                Text(
                    '$quantity',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Futehodo-MaruGothic_1.00',
                        shadows: [
                            Shadow(
                              blurRadius: 2.0,
                              color: Colors.black.withOpacity(0.5),
                              offset: Offset(1.0, 1.0),
                            ),
                        ]
                    ),
                ),
            ],
          ),
      );
  }

  // Returns the widget corresponding to the current game stage
  Widget _buildCurrentStageWidget() {
    switch (_currentStage) {
      case GameStage.intro:
        return _buildIntro();
      case GameStage.terrainSelection:
        return _buildTerrainSelection();
      case GameStage.seedSelection:
        return _buildSeedSelection();
      case GameStage.dailyCycle:
        return _buildDailyCycleChoices();
      case GameStage.weatherForecast:
        return buildWeatherForecastScreen();
      case GameStage.weatherEvent:
        return buildWeatherEventScreen();
      case GameStage.playerWeatherAction:
        return _buildPlayerWeatherActionScreen();
      case GameStage.aiJudgement:
        return _buildAIJudgementScreen();
      case GameStage.harvesting:
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if(_currentStage == GameStage.harvesting && mounted) {
              await Future.delayed(const Duration(milliseconds: 1000));
              if(mounted) {
                  _calculateHarvest();
              }
          }
        });

        return _paperContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(_getUIImageAsset('Harvest Time') ?? 'assets/images/HarvestTime 1.png', height: 80, errorBuilder: (context, error, stackTrace) => Text("Harvesting...", style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center,)),
              SizedBox(height: 10),
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 10),
              Text("Calculating results...", style: TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center,),
            ],
          ),
        );
      case GameStage.results:
        return _buildResultsScreen();
      case GameStage.showTips:
        return _buildTipsScreen();
      case GameStage.loadingToHome:
         return _buildLoadingToHomeScreen();
    }
  }

  //For the intro messages
  Widget _buildIntro() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _paperContainer(
          padding: const EdgeInsets.all(20),
          child: Text(
            _introMessages[_currentMessageIndex],
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Futehodo-MaruGothic_1.00', fontSize: 20, color: Colors.white),
          ),
        ),
        const SizedBox(height: 20),
        if (_currentMessageIndex < _introMessages.length - 1)
          _styledButton("Next", () {
            setState(() {
              _currentMessageIndex++;
            });
          }),
        if (_currentMessageIndex == _introMessages.length - 1)
          _styledButton("Start Farming!", _skipIntro),
      ],
    );
  }

  //Terrain selection
  Widget _buildTerrainSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _paperContainer(child: Text("Select Terrain", style: TextStyle(fontSize: 24, fontFamily: 'Futehodo-MaruGothic_1.00', color: Colors.white), textAlign: TextAlign.center,)),
        const SizedBox(height: 30),
        ..._terrainDescriptions.entries.map((entry) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: _styledButton(
            "${entry.key} \n(${entry.value})",
                () => _selectTerrain(entry.key),
            isMultiLine: true,
          ),
        )),
      ],
    );
  }

  //Seed selection
  Widget _buildSeedSelection() {
    if (_availableSeedKeys.isEmpty) {
         return _paperContainer(child: Text("No seeds available this season!", style: TextStyle(color: Colors.red, fontFamily: 'Futehodo-MaruGothic_1.00')));
    }

    final availableSeedData = _availableSeedKeys.map((key) => _seedInfo[key]).whereType<SeedData>().toList();
    List<Widget> seedButtons = [];
    for (int i = 0; i < availableSeedData.length; i += 2) {
      List<Widget> rowChildren = [];
      rowChildren.add(
          Flexible(
              child: _styledButton(
                  availableSeedData[i].name,
                      () => _selectSeed(availableSeedData[i].name)
              ),
          )
      );
      if (i + 1 < availableSeedData.length) {
         rowChildren.add(SizedBox(width: 10));
         rowChildren.add(
             Flexible(
                 child: _styledButton(
                     availableSeedData[i + 1].name,
                         () => _selectSeed(availableSeedData[i + 1].name)
                 ),
             )
         );
      }
      seedButtons.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: rowChildren,
      ));
      if (i + 2 < availableSeedData.length) {
          seedButtons.add(const SizedBox(height: 10));
      }
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
        ...seedButtons,
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDailyCycleChoices() {
    bool canFertilize = (_inventory['Fertilizer'] ?? 0) > 0 && _money >= 20;
    bool canWeedPest = (_inventory['Pest Spray'] ?? 0) > 0 && _money >= 15;
    bool canPrepareSoil = (_inventory['Shovel'] ?? 0) > 0 && _money >= 10;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _paperContainer(
          child: Text(
            "Day ${_currentDay}/${_selectedSeedData?.harvestingDays ?? 'N/A'}\nWhat will you do?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontFamily: 'Futehodo-MaruGothic_1.00', color: Colors.white),
          ),
        ),
        const SizedBox(height: 20),
        _styledButton("Water (Free)", () => _handleDailyAction(DailyAction.water)),
        SizedBox(height: 10),
        _styledButton(
            "Fertilize (₱20, Use 1x Fertilizer)",
            canFertilize ? () => _handleDailyAction(DailyAction.fertilize) : null,
        ),
        SizedBox(height: 10),
        _styledButton(
            "Weed/Pest Control (₱15, Use 1x Pest Spray)",
            canWeedPest ? () => _handleDailyAction(DailyAction.weedPest) : null,
        ),
        SizedBox(height: 10),
        _styledButton(
            "Prepare Soil (₱10, Requires Shovel)",
            canPrepareSoil ? () => _handleDailyAction(DailyAction.prepareSoil) : null,
        ),
        SizedBox(height: 10),
        _styledButton("Do Nothing (Risky)", () => _handleDailyAction(DailyAction.doNothing)),
      ],
    );
  }

  //For weather forecasting
  Widget buildWeatherForecastScreen() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(_currentStage == GameStage.weatherForecast && mounted) {
        await Future.delayed(Duration(seconds: 2));
        if(mounted) {
          _generateWeatherForecast();
        }
      }
    });

    return _paperContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Weather Alert!!", style: TextStyle(fontSize: 22, color: Colors.white, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center,),
            SizedBox(height:15),
            CircularProgressIndicator(color: Colors.white,),
            SizedBox(height:15),
            Text("Forecasting...", style: TextStyle(fontSize: 18, color: Colors.white70, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center,),
          ],
        )
    );
  }

  //Displays the weather event and hint
  Widget buildWeatherEventScreen() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentStage == GameStage.weatherEvent && mounted) {
        setState(() {
          _showWeatherImageOverlay = true;
        });

        _weatherImageTimer?.cancel();
        _weatherImageTimer = Timer(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _showWeatherImageOverlay = false;
            });
          }
        });
      }
    });

    return _paperContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Weather Alert!", style: TextStyle(fontSize: 24, color: Colors.orangeAccent, fontFamily: 'Futehodo-MaruGothic_1.00', fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
            SizedBox(height: 10),
            if(_currentWeatherHint != null)
              Text(_currentWeatherHint!, style: TextStyle(fontSize: 16, color: Colors.white70, fontStyle: FontStyle.italic, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center),
            SizedBox(height: 15),
            Text("Incoming Event: ${_currentWeatherEvent ?? 'Loading...'}", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center),
            SizedBox(height: 25),
            _styledButton("Prepare!", () => setState(() => _currentStage = GameStage.playerWeatherAction)),
          ],
        )
    );
  }

  //Player input during a weather event
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
            controller: weatherResponseController,
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

  //Displays the AI's judgement
  Widget _buildAIJudgementScreen() {
    return _paperContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("AI Farmer Judges:", style: TextStyle(fontSize: 22, color: Colors.white, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center,),
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
            Text("Crop Health: ${_cropHealth.toStringAsFixed(0)}%", style: TextStyle(fontSize: 18, color: _getHealthColor(_cropHealth), fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center,),
            SizedBox(height:25),
            _styledButton("Next Day", _proceedFromAIJudgement),
          ],
        )
    );
  }

  // Displays the harvest results
  Widget _buildResultsScreen() {
    String? harvestImagePath = _getUIImageAsset('Harvest Time');
    bool canContinue = _money >= 200;

    return _paperContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (harvestImagePath != null)
              Image.asset(
                harvestImagePath,
                height: 60,
                errorBuilder: (context, error, stackTrace) => Text("Harvest Time!", style: TextStyle(fontSize: 28, color: Colors.amber, fontFamily: 'Futehodo-MaruGothic_1.00', fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
               alignment: Alignment.center,
              )
            else
              Text("Harvest Time!", style: TextStyle(fontSize: 28, color: Colors.amber, fontFamily: 'Futehodo-MaruGothic_1.00', fontWeight: FontWeight.bold), textAlign: TextAlign.center,),

            SizedBox(height: 15),

            Text("Crop: ${_selectedSeedData?.name ?? 'N/A'}", style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center,),

            Text("Crop Quality: $_cropQuality", style: TextStyle(fontSize: 18, color: _cropQuality == "Excellent" ? Colors.greenAccent : (_cropQuality == "Failed" ? Colors.redAccent : Colors.yellowAccent), fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center,),
            SizedBox(height: 10),

            Text("Total Investment: ₱$_totalInvestment", style: TextStyle(fontSize: 16, color: Colors.white70, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center,),
            Text("Harvest Value: ₱$_harvestValue", style: TextStyle(fontSize: 18, color: Colors.lightGreenAccent, fontWeight: FontWeight.bold, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center,),
            Divider(color: Colors.white54, height: 20, thickness: 1),

            Text("Profit / Loss: ₱$_profitOrLoss", style: TextStyle(fontSize: 20, color: _profitOrLoss >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center,),
            SizedBox(height: 15),

            Text("Overall Outcome: $_gameOutcome", style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center,),
            SizedBox(height: 25),
            if(canContinue)
              _styledButton("Continue Planting (New Season)", _resetGameForContinue),
            SizedBox(height: 10),
            _styledButton("End Season Summary", _quitGame),
          ],
        )
    );
  }

  //Displays game tips and season summary before returning home
  Widget _buildTipsScreen() {
    final random = Random();
    String tip = _gameTips[random.nextInt(_gameTips.length)];
    String? harvestImagePath = _getUIImageAsset('Harvest Time');

    return _paperContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (harvestImagePath != null)
               Image.asset(
                  harvestImagePath,
                  height: 60,
                  errorBuilder: (context, error, stackTrace) => Text("Summary", style: TextStyle(fontSize: 28, color: Colors.amber, fontFamily: 'Futehodo-MaruGothic_1.00', fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                  alignment: Alignment.center,
               )
            else
               Text("Summary", style: TextStyle(fontSize: 28, color: Colors.amber, fontFamily: 'Futehodo-MaruGothic_1.00', fontWeight: FontWeight.bold), textAlign: TextAlign.center,),

            SizedBox(height:15),

            Text(tip, style: TextStyle(fontSize: 18, color: Colors.white70, fontStyle: FontStyle.italic, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center),
            SizedBox(height: 15),
            Divider(color: Colors.white54, height: 20, thickness: 1),

            Text("Last Season Summary:", style: TextStyle(fontSize: 18, color: const Color.fromARGB(255, 51, 162, 75), fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center,),
            SizedBox(height: 8),
            Text("Crop Quality: $_cropQuality", style: TextStyle(fontSize: 18, color: _cropQuality == "Excellent" ? Colors.greenAccent : (_cropQuality == "Failed" ? Colors.redAccent : Colors.yellowAccent), fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center,),
            SizedBox(height: 4),
            Text("Profit / Loss: ₱$_profitOrLoss", style: TextStyle(fontSize: 20, color: _profitOrLoss >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center,),
            SizedBox(height: 4),
            Text("Overall Outcome: $_gameOutcome", style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center,),

            SizedBox(height:25),
            _styledButton("Back to Home Screen", _goToHomeScreen),
          ],
        )
    );
  }

  // Widget for the loading screen transition
  Widget _buildLoadingToHomeScreen() {
      return Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                  CircularProgressIndicator(color: const Color.fromARGB(255, 12, 222, 9)),
                  SizedBox(height: 20),
                  Text("Returning to Home...", style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Futehodo-MaruGothic_1.00')),
              ],
          ),
      );
  }

  Widget _styledButton(String label, VoidCallback? onPressed, {bool isMultiLine = false}) {
    return _paperContainer(
      padding: EdgeInsets.zero,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: isMultiLine ? 12 : 24, vertical: isMultiLine ? 10: 12),
          minimumSize: Size(150, 40),
          foregroundColor: onPressed != null ? Colors.white : Colors.white54,
          backgroundColor: onPressed != null ? Colors.transparent : Colors.black.withOpacity(0.1),
          disabledForegroundColor: Colors.white54,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Futehodo-MaruGothic_1.00', fontSize: isMultiLine ? 16 : 18, color: onPressed != null ? Colors.white : Colors.white54),
        ),
      ),
    );
  }

  Widget _paperContainer({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(12),
    Alignment? alignment,
  }) {
    return Container(
      alignment: alignment,
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

  // Determines color based on crop health percentage
  Color _getHealthColor(double health){
    if(health > 75) return Colors.greenAccent.withOpacity(0.8);
    if(health > 45) return Colors.orangeAccent.withOpacity(0.8);
    return Colors.redAccent.withOpacity(0.8);
  }

  // Returns a text description for crop status based on health
  String _getCropStatusText(double health) {
    if (health > 90) return "Excellent";
    if (health > 70) return "Good";
    if (health > 40) return "Moderate";
    if (health > 10) return "Poor";
    return "Bad";
  }

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
          Flexible(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Futehodo-MaruGothic_1.00', fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    weatherResponseController.dispose();
    _weatherImageTimer?.cancel();
    super.dispose();
  }
}