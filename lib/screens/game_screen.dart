import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'home.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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

  factory SeedData.fromMap(Map<String, dynamic> map) {
    return SeedData(
      name: map['name'],
      harvestingDays: map['harvestingDays'],
      iconAsset: map['iconAsset'],
      strengths: List<String>.from(map['strengths'] ?? []),
      weaknesses: List<String>.from(map['weaknesses'] ?? []),
    );
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
  loadingToHome,
  loadingGame
}

enum DailyAction { water, fertilize, weedPest, prepareSoil, doNothing }

enum AIJudgementCategory { smartAndEffective, ineffectiveOrTooLate, comedicUseless }

String enumToString(dynamic e) {
  return e.toString().split('.').last;
}

GameStage stringToGameStage(String s) {
  return GameStage.values.firstWhere(
    (e) => enumToString(e) == s,
    orElse: () => GameStage.intro,
  );
}

AIJudgementCategory? stringToAIJudgementCategory(String? s) {
  if (s == null) return null;
  return AIJudgementCategory.values.firstWhere(
    (e) => enumToString(e) == s,
    orElse: () => AIJudgementCategory.comedicUseless,
  );
}


class GameScreen extends StatefulWidget {
  final bool loadGame;
  const GameScreen({super.key, this.loadGame = false});

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

  String _cropQuality = "Unknown";
  int _harvestValue = 0;
  int _profitOrLoss = 0;
  String _gameOutcome = "";

  final TextEditingController weatherResponseController = TextEditingController();

  bool _isProcessingSelection = false;

  final Map<String, String> _terrainDescriptions = {
    'Mountain': 'Cold climate, rocky soil, high elevation.',
    'Hills': 'Mild climate, good drainage.',
    'Lowlands': 'Warm and humid, ideal for wet crops.'
  };

  final Map<String, SeedData> _seedInfo = {
    'Adlay Rice': SeedData(
        name: 'Adlay Rice',
        harvestingDays: 12,
        iconAsset: 'assets/images/adlay_seed_icon.png',
        strengths: ['Rainy', 'Flooding'],
        weaknesses: ['Heatwave (El Nino)', 'Locust Swarm']),
    'Corn': SeedData(
        name: 'Corn',
        harvestingDays: 9,
        iconAsset: 'assets/images/corn_seed_icon.png',
        strengths: ['Sunny', 'Heatwave (El Nino)'],
        weaknesses: ['Flooding', 'Thunderstorm']),
    'Potatoes': SeedData(
        name: 'Potatoes',
        harvestingDays: 10,
        iconAsset: 'assets/images/potato_seed_icon.png',
        strengths: ['Cloudy', 'Thunderstorm'],
        weaknesses: ['Heatwave (El Nino)', 'Locust Swarm']),
    'Tomato': SeedData(
        name: 'Tomato',
        harvestingDays: 7,
        iconAsset: 'assets/images/tomato_seed_icon.png',
        strengths: ['Sunny'],
        weaknesses: ['Typhoon', 'Flooding', 'Heatwave (El Nino)']),
    'Mango': SeedData(
         name: 'Mango',
         harvestingDays: 15,
         iconAsset: 'assets/images/mango_seed_icon.png',
         strengths: ['Sunny', 'Heatwave (El Nino)'],
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
         weaknesses: ['Heatwave (El Nino)', 'Locust Swarm', 'Pests']),
  };

  List<String> _availableSeedKeys = [];
  final int _numberOfSeedOptions = 4;

  final List<String> _introMessages = [
    "Welcome Aspiring Farmer!, Each option you pick will lead you down a different path.",
    "Sometimes, a choice might not have a big impact right away, but it could influence things later on.",
    "So, when you see a choice, take a moment to think about what you want to happen!"
  ];

  final List<String> _normalWeatherEvents = ['Sunny', 'Rainy', 'Cloudy'];

  final List<String> _disasterWeatherEvents = [
    'Thunderstorm',
    'Typhoon',
    'Heatwave (El Nino)',
    'Locust Swarm',
    'Flooding'
  ];

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

  final List<String> _gameTips = [
    "Tip: Matching seeds to terrain strengths can boost your harvest!",
    "Tip: Pay attention to weather forecasts; they can save your crops.",
    "Tip: Fertilizing at the right time can significantly improve crop health.",
    "Tip: Some disasters are unavoidable, but smart choices can mitigate damage.",
    "Tip: Keep an eye on your item stock! Some actions require tools.",
    "Tip: 'Preparing Soil' uses a shovel and can give a small health boost.",
  ];

  Future<File> _getGameStateFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File(p.join(directory.path, 'gamestate.json'));
  }

  Future<void> _saveGameState() async {
    if (!mounted) return;

    final file = await _getGameStateFile();

    final Map<String, dynamic> state = {
      'currentStage': enumToString(_currentStage),
      'currentMessageIndex': _currentMessageIndex,
      'selectedTerrain': _selectedTerrain,
      'selectedSeedData': _selectedSeedData?.toMap(),
      'money': _money,
      'currentDay': _currentDay,
      'cropHealth': _cropHealth,
      'cropStatusMessage': _cropStatusMessage,
      'totalInvestment': _totalInvestment,
      'inventory': _inventory,
      'currentWeatherHint': _currentWeatherHint,
      'currentWeatherEvent': _currentWeatherEvent,
      'playerWeatherResponse': _playerWeatherResponse,
      'aiJudgement': _aiJudgement != null ? enumToString(_aiJudgement!) : null,
      'aiJudgementFeedback': _aiJudgementFeedback,
      'cropQuality': _cropQuality,
      'harvestValue': _harvestValue,
      'profitOrLoss': _profitOrLoss,
      'gameOutcome': _gameOutcome,
      'availableSeedKeys': _availableSeedKeys,
      'isProcessingSelection': _isProcessingSelection,
    };

    try {
      final jsonString = jsonEncode(state);
      await file.writeAsString(jsonString);
      _logGameState('Save', eventDetails: 'Game state saved.');
    } catch (e) {
      print('Error saving game state: $e');
       _logGameState('Error', eventDetails: 'Error saving game state: $e');
    }
  }

  Future<bool> _loadGameState() async {
    final file = await _getGameStateFile();

    if (!await file.exists()) {
      print('No save file found.');
       _logGameState('Load', eventDetails: 'No save file found.');
      return false;
    }

    try {
      final jsonString = await file.readAsString();
      final Map<String, dynamic> state = jsonDecode(jsonString);

      if (mounted) {
        setState(() {
          _currentStage = stringToGameStage(state['currentStage'] ?? 'intro');
          _currentMessageIndex = state['currentMessageIndex'] ?? 0;

          _selectedTerrain = state['selectedTerrain'];
          final selectedSeedMap = state['selectedSeedData'];
          _selectedSeedData = selectedSeedMap != null ? SeedData.fromMap(selectedSeedMap) : null;

          _money = state['money'] ?? 200;
          _currentDay = state['currentDay'] ?? 1;
          _cropHealth = (state['cropHealth'] ?? 100.0).toDouble();
          _cropStatusMessage = state['cropStatusMessage'] ?? "Ready to plant!";
          _totalInvestment = state['totalInvestment'] ?? 0;
          _inventory = Map<String, int>.from(state['inventory'] ?? {
             'Fertilizer': 2,
             'Pest Spray': 2,
             'Shovel': 1,
          });

          _currentWeatherHint = state['currentWeatherHint'];
          _currentWeatherEvent = state['currentWeatherEvent'];
          _playerWeatherResponse = state['playerWeatherResponse'];
          _aiJudgement = stringToAIJudgementCategory(state['aiJudgement']);
          _aiJudgementFeedback = state['aiJudgementFeedback'] ?? "";

          _cropQuality = state['cropQuality'] ?? "Unknown";
          _harvestValue = state['harvestValue'] ?? 0;
          _profitOrLoss = state['profitOrLoss'] ?? 0;
          _gameOutcome = state['gameOutcome'] ?? "";
          _availableSeedKeys = List<String>.from(state['availableSeedKeys'] ?? []);

          _isProcessingSelection = state['isProcessingSelection'] ?? false;
        });
      }
      print('Game state loaded successfully. Resuming at stage: $_currentStage');
      _logGameState('LoadSuccess', eventDetails: 'Game state loaded. Resuming at stage: $_currentStage');
      return true;

    } catch (e) {
      print('Error loading game state: $e');
      _logGameState('Error', eventDetails: 'Error loading game state: $e');
      return false;
    }
  }

  Future<void> _clearSaveFile() async {
    final file = await _getGameStateFile();
    try {
      if (await file.exists()) {
        await file.delete();
        _logGameState('Save', eventDetails: 'Game state save file cleared.');
      }
    } catch (e) {
      print('Error clearing game state save file: $e');
      _logGameState('Error', eventDetails: 'Error clearing game state save file: $e');
    }
  }


  Future<File> _getLogFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/gamestate_log.jsonl');
  }

  Future<void> _logGameState(String eventType, {String? eventDetails}) async {
    try {
      final file = await _getLogFile();
      final timestamp = DateTime.now().toIso8601String();

      final Map<String, dynamic> stateSnapshot = {
        'timestamp': timestamp,
        'currentStage': enumToString(_currentStage),
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
        'aiJudgement': _aiJudgement != null ? enumToString(_aiJudgement!) : null,
        'aiJudgementFeedback': _aiJudgementFeedback,
        if (_currentStage == GameStage.results || _currentStage == GameStage.showTips) ...{
          'cropQuality': _cropQuality,
          'harvestValue': _harvestValue,
          'profitOrLoss': _profitOrLoss,
          'gameOutcome': _gameOutcome,
        },
        'isProcessingSelection': _isProcessingSelection,
      };

      final String jsonLine = jsonEncode(stateSnapshot);
      await file.writeAsString('$jsonLine\n', mode: FileMode.append);
    } catch (e) {
      print('Error logging game state: $e');
    }
  }

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
    _clearLogFile();

    if (widget.loadGame) {
      _currentStage = GameStage.loadingGame;
      _logGameState('StageChange', eventDetails: 'Initiating Game Load');
      _loadGameState().then((loaded) {
        if (!mounted) return;
        if (loaded) {
          print('Game loaded, resuming at stage: $_currentStage');
           _logGameState('LoadSuccess', eventDetails: 'Resuming at stage: $_currentStage');
           if (_currentStage == GameStage.terrainSelection || _currentStage == GameStage.seedSelection || _currentStage == GameStage.showTips) {
             setState(() {
               _isProcessingSelection = false;
             });
           }
        } else {
          print('Load failed or no save found, starting new game.');
          _logGameState('LoadFailed', eventDetails: 'No save found or load error, starting new game.');
          _startIntroSequence();
        }
      });
    } else {
      _clearSaveFile();
      _clearLogFile();
      _startIntroSequence();
    }
  }

  void _startIntroSequence() async {
    if (!mounted) return;
    setState(() => _currentStage = GameStage.intro);
    _logGameState('StageChange', eventDetails: 'Intro Started');
    for (int i = 0; i < _introMessages.length; i++) {
      if (!mounted) return;
      setState(() => _currentMessageIndex = i);
      await Future.delayed(Duration(seconds: i == 0 ? 2 : 3));
    }
    if (!mounted) return;
    setState(() {
       _currentStage = GameStage.terrainSelection;
       _isProcessingSelection = false;
    });
     _logGameState('StageChange', eventDetails: 'Terrain Selection');
     await _saveGameState();
  }

  void _skipIntro() async {
    if (_isProcessingSelection && _currentStage == GameStage.intro) {
        return;
    }
     if (!mounted) return;
     setState(() {
       _isProcessingSelection = true;
     });

    if (!mounted) return;
     setState(() {
       _currentStage = GameStage.terrainSelection;
     });
    _logGameState('Action', eventDetails: 'Skipped Intro');
    _logGameState('StageChange', eventDetails: 'Terrain Selection');
    await _saveGameState();

     if (!mounted) return;
     setState(() {
        _isProcessingSelection = false;
     });
  }


  void _selectTerrain(String terrain) async {
    if (_isProcessingSelection) {
       return;
    }

     if (!mounted) return;
     setState(() {
       _isProcessingSelection = true;
     });

    _generateRandomSeedOptions();

    if (!mounted) return;
    setState(() {
      _selectedTerrain = terrain;
      _currentStage = GameStage.seedSelection;
    });
    _logGameState('Action', eventDetails: 'Selected Terrain: $terrain');
    _logGameState('StageChange', eventDetails: 'Seed Selection');

    await Future.delayed(const Duration(milliseconds: 100));

    await _saveGameState();

    if (!mounted) return;
     setState(() {
        _isProcessingSelection = false;
     });
  }

  void _generateRandomSeedOptions() {
      final random = Random();
      final allSeedKeys = _seedInfo.keys.toList();
      allSeedKeys.shuffle(random);
      _availableSeedKeys = allSeedKeys.take(min(_numberOfSeedOptions, allSeedKeys.length)).toList();
       _logGameState('SeedOptionsGenerated', eventDetails: 'Available seeds: ${_availableSeedKeys.join(', ')}');
  }

  void _selectSeed(String seedKey) async {
     if (_isProcessingSelection) {
        return;
     }

    if (_seedInfo[seedKey] == null) {
      print("Error: Selected unknown seed key: $seedKey");
      _logGameState('Error', eventDetails: 'Attempted to select unknown seed: $seedKey');
       if (!mounted) return;
       setState(() {
         _isProcessingSelection = false;
       });
      return;
    }

     if (!mounted) return;
     setState(() {
       _isProcessingSelection = true;
     });

    if (!mounted) return;
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
      _cropStatusMessage = "Planted ${_selectedSeedData!.name}! Day $_currentDay";
      _currentStage = GameStage.dailyCycle;
    });

    await Future.delayed(const Duration(milliseconds: 100));

    _logGameState('Action', eventDetails: 'Selected Seed: $seedKey. New Season Started.');
    _logGameState('StageChange', eventDetails: 'Daily Cycle');
    await _saveGameState();

     if (!mounted) return;
     setState(() {
        _isProcessingSelection = false;
     });
  }

  void _handleDailyAction(DailyAction action) async {
    if (_selectedSeedData == null) {
        _logGameState('Error', eventDetails: 'Attempted DailyAction with null _selectedSeedData');
        return;
    }

    String actionMessage = "";
    int cost = 0;
    double healthChange = 0;
    String? itemConsumed;
    bool canPerformAction = true;

    _logGameState('PlayerAction', eventDetails: 'Attempted Daily Action: ${enumToString(action)}');

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
          if (_money < cost) {
            actionMessage = "Not enough money to fertilize! Needs ₱$cost.";
          } else {
            actionMessage = "You need Fertilizer to do that! You have ${_inventory[itemConsumed] ?? 0}.";
          }
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
          if (_money < cost) {
            actionMessage = "Not enough money for weed/pest control! Needs ₱$cost.";
          } else {
            actionMessage = "You need Pest Spray to do that! You have ${_inventory[itemConsumed] ?? 0}.";
          }
        }
        break;
      case DailyAction.prepareSoil:
        cost = 10;
        itemConsumed = 'Shovel';
         if ((_inventory[itemConsumed] ?? 0) > 0 && _money >= cost) {
            _money -= cost;
            _totalInvestment += cost;
             _inventory[itemConsumed] = (_inventory[itemConsumed] ?? 0) - 1;
            actionMessage = "You prepared the soil (Used 1x $itemConsumed). Cost: ₱$cost";
            healthChange = 8;
         } else {
            canPerformAction = false;
             if (_money < cost) {
                actionMessage = "Not enough money to prepare soil! Needs ₱$cost.";
             } else {
                actionMessage = "You need a Shovel to prepare the soil! You have ${_inventory[itemConsumed] ?? 0}.";
             }
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
        eventDetails: '${enumToString(action)} - Success: $canPerformAction, HealthChange: ${healthChange.toStringAsFixed(1)}, NewHealth: ${_cropHealth.toStringAsFixed(1)}',
      );

      if (_cropHealth <= 0) {
        _cropStatusMessage = "$actionMessage\nYour crops withered during the day!";
      } else {
         _cropStatusMessage = "$actionMessage (Health: ${_cropHealth.toStringAsFixed(0)}%)";
      }


      if (!mounted) return;
      setState(() {
        _currentStage = GameStage.weatherForecast;
      });
      _logGameState('StageChange', eventDetails: 'Weather Forecast');
      await _saveGameState();

    } else {
      if (!mounted) return;
      setState(() {
        _cropStatusMessage = actionMessage;
      });
       _logGameState(
        'DailyActionOutcome',
        eventDetails: '${enumToString(action)} - Failed (Insufficient Funds/Items): $actionMessage',
      );
       await _saveGameState();
    }
  }

  void _generateWeatherForecast() {
    if (_selectedSeedData == null) {
         _logGameState('Error', eventDetails: 'Attempted Weather Forecast with null _selectedSeedData');
        return;
    }
    final random = Random();
    String upcomingWeatherHint = "An interesting weather pattern is forming.";
    String actualWeatherEvent;

    bool isActualWeatherDisaster = random.nextDouble() < 0.25;

    if (isActualWeatherDisaster) {
       List<String> possibleDisasters = _disasterWeatherEvents.toList();
       List<String> weaknessDisasters = _selectedSeedData!.weaknesses.where(_disasterWeatherEvents.contains).toList();

       if (weaknessDisasters.isNotEmpty && random.nextDouble() < 0.6) {
          actualWeatherEvent = weaknessDisasters[random.nextInt(weaknessDisasters.length)];
          upcomingWeatherHint = "Warning! Weather unfavorable to your crops, potentially '${actualWeatherEvent}', might be coming.";
       } else {
          actualWeatherEvent = possibleDisasters[random.nextInt(possibleDisasters.length)];
          upcomingWeatherHint = "Be prepared! Extreme weather is possible.";
       }
    } else {
       List<String> possibleNormalEvents = _normalWeatherEvents.toList();
       List<String> strengthNormalEvents = _selectedSeedData!.strengths.where(_normalWeatherEvents.contains).toList();

       if (strengthNormalEvents.isNotEmpty && random.nextDouble() < 0.6) {
          actualWeatherEvent = strengthNormalEvents[random.nextInt(strengthNormalEvents.length)];
           upcomingWeatherHint = "Forecast looks good! Weather favorable to your crops, possibly '${actualWeatherEvent}', is expected.";
       } else {
          actualWeatherEvent = possibleNormalEvents[random.nextInt(possibleNormalEvents.length)];
          upcomingWeatherHint = "Expect typical weather conditions.";
       }
    }

    _currentWeatherHint = upcomingWeatherHint;
    _currentWeatherEvent = actualWeatherEvent;

    if (!mounted) return;
    setState(() {
      _currentStage = GameStage.weatherEvent;
    });
    _logGameState(
        'WeatherGenerated',
        eventDetails: 'ForecastHint: "$_currentWeatherHint", ActualEvent: "$_currentWeatherEvent"'
    );
     _logGameState('StageChange', eventDetails: 'Weather Event');
  }

  void _processPlayerWeatherAction() async {
    if (_selectedSeedData == null) {
        _logGameState('Error', eventDetails: 'Attempted Weather Action processing with null _selectedSeedData');
        return;
    }

    final playerInput = weatherResponseController.text.toLowerCase().trim();
    _playerWeatherResponse = playerInput.isEmpty ? "[No Action]" : playerInput;

    _logGameState(
        'PlayerWeatherInput',
        eventDetails: 'Input: "$playerInput", Weather Event: "$_currentWeatherEvent"'
    );

    bool isDisaster = _disasterWeatherEvents.contains(_currentWeatherEvent);
    _aiJudgementFeedback = "";
    AIJudgementCategory potentialJudgement = AIJudgementCategory.comedicUseless;
    double healthEffectFromAction = 0;
    bool recognizedAction = false;

    double initialHealth = _cropHealth;

    if (playerInput.isEmpty || playerInput.contains("do nothing") || playerInput.contains("nothing")) {
        recognizedAction = true;
        healthEffectFromAction -= (isDisaster ? 25 : 10);
        potentialJudgement = AIJudgementCategory.ineffectiveOrTooLate;
        _aiJudgementFeedback = playerInput.isEmpty ? "You didn't react to $_currentWeatherEvent." : "'${weatherResponseController.text}'... Ignoring $_currentWeatherEvent proved costly!";
    } else {
      if ((playerInput.contains("spray") || playerInput.contains("pest") || playerInput.contains("bug")) && (_currentWeatherEvent == 'Locust Swarm' || (_selectedSeedData!.weaknesses.contains('Pests') && !isDisaster))) {
        recognizedAction = true;
        String item = 'Pest Spray';
        if ((_inventory[item] ?? 0) > 0) {
          _inventory[item] = (_inventory[item] ?? 0) - 1;
          healthEffectFromAction += (_currentWeatherEvent == 'Locust Swarm' ? 30 : 15);
          potentialJudgement = AIJudgementCategory.smartAndEffective;
          _aiJudgementFeedback = (_currentWeatherEvent == 'Locust Swarm') ? "Using $item directly against the $_currentWeatherEvent was highly effective!" : "Using $item helped control pests.";
        } else {
          healthEffectFromAction -= (isDisaster ? 15 : 5);
          potentialJudgement = AIJudgementCategory.ineffectiveOrTooLate;
          _aiJudgementFeedback = "You tried to use $item but didn't have any left! You have ${_inventory[item] ?? 0}.";
        }
      } else if ((playerInput.contains("fertilize") || playerInput.contains("nutrients")) && !isDisaster) {
         recognizedAction = true;
         String item = 'Fertilizer';
         if ((_inventory[item] ?? 0) > 0) {
            _inventory[item] = (_inventory[item] ?? 0) - 1;
            healthEffectFromAction += 15;
            potentialJudgement = AIJudgementCategory.smartAndEffective;
            _aiJudgementFeedback = "Applying $item provided valuable nutrients for growth.";
         } else {
            healthEffectFromAction -= 5;
            potentialJudgement = AIJudgementCategory.ineffectiveOrTooLate;
            _aiJudgementFeedback = "You wanted to fertilize but ran out! You have ${_inventory[item] ?? 0}.";
         }
      } else if ((playerInput.contains("water") || playerInput.contains("irrigate")) && (_currentWeatherEvent == "Heatwave (El Nino)" || _currentWeatherEvent == "Sunny" || _currentWeatherEvent == "Cloudy" || _currentWeatherEvent == "Thunderstorm")) {
        recognizedAction = true;
        double effect = 0;
        String feedback = "";
        AIJudgementCategory judgement = AIJudgementCategory.smartAndEffective;

        if(_currentWeatherEvent == "Heatwave (El Nino)" || _currentWeatherEvent == "Sunny") {
            effect = 20;
            feedback = "Watering helped counter the dry effects of $_currentWeatherEvent.";
        } else if (_currentWeatherEvent == "Cloudy") {
             effect = 5;
             feedback = "Watering during cloudy weather provides some moisture.";
        } else if (_currentWeatherEvent == "Thunderstorm") {
            effect = 10;
            feedback = "Watering after the thunderstorm helped the crops recover.";
        } else {
             effect = 0;
             feedback = "Your watering didn't seem to have a strong effect on the weather.";
             judgement = AIJudgementCategory.comedicUseless;
        }

        healthEffectFromAction += effect;
        potentialJudgement = judgement;
        _aiJudgementFeedback = feedback;

      } else if ((playerInput.contains("prepare") || playerInput.contains("reinforce") || playerInput.contains("secure") || playerInput.contains("protect")) && isDisaster) {
        recognizedAction = true;
        healthEffectFromAction += 15;
        potentialJudgement = AIJudgementCategory.smartAndEffective;
        _aiJudgementFeedback = "You took smart steps to prepare the farm for $_currentWeatherEvent, mitigating some damage.";

      } else if (playerInput.contains("harvest") && isDisaster && _currentDay < (_selectedSeedData?.harvestingDays ?? 99)) {
        recognizedAction = true;
        healthEffectFromAction -= 10;
        potentialJudgement = AIJudgementCategory.ineffectiveOrTooLate;
        _aiJudgementFeedback = "Emergency harvest during $_currentWeatherEvent? Risky, might not yield much later.";
      }

      if (!recognizedAction) {
        healthEffectFromAction -= (isDisaster ? 15 : 5);
        potentialJudgement = AIJudgementCategory.comedicUseless;
        _aiJudgementFeedback = "'${weatherResponseController.text}'... an interesting response to $_currentWeatherEvent. The crops are confused.";
      }
    }

    double weatherDirectEffect = 0;
    if (_currentWeatherEvent == 'Heatwave (El Nino)' || _currentWeatherEvent == 'Flooding' || _currentWeatherEvent == 'Typhoon' || _currentWeatherEvent == 'Locust Swarm') {
       weatherDirectEffect = -20;
    } else if (_currentWeatherEvent == 'Thunderstorm') {
       weatherDirectEffect = -10;
    } else if (_currentWeatherEvent == 'Sunny') {
       weatherDirectEffect = 5;
    } else if (_currentWeatherEvent == 'Rainy' || _currentWeatherEvent == 'Cloudy') {
       weatherDirectEffect = 0;
    }

    double traitEffect = 0;
    bool weatherMatchesWeakness = _selectedSeedData != null && _selectedSeedData!.weaknesses.contains(_currentWeatherEvent);
    bool weatherMatchesStrength = _selectedSeedData != null && _selectedSeedData!.strengths.contains(_currentWeatherEvent);

    if (weatherMatchesWeakness) {
      traitEffect = isDisaster ? -15 : -8;
       if (!_cropStatusMessage.startsWith("You ")) {
         _cropStatusMessage = "$_currentWeatherEvent negatively impacted your crops!";
       } else {
          _cropStatusMessage += "\n...and ${_currentWeatherEvent} negatively impacted your crops!";
       }

    } else if (weatherMatchesStrength) {
      traitEffect = isDisaster ? 5 : 8;
       if (!_cropStatusMessage.startsWith("You ")) {
         _cropStatusMessage = "$_currentWeatherEvent was beneficial for your crops!";
       } else {
          _cropStatusMessage += "\n...and ${_currentWeatherEvent} was beneficial for your crops!";
       }
    } else {
      if (!_cropStatusMessage.startsWith("You ") && !_cropStatusMessage.contains("impacted") && !_cropStatusMessage.contains("beneficial")) {
         _cropStatusMessage = "${_selectedSeedData?.name} status after $_currentWeatherEvent:";
      }
    }

    _cropHealth = (_cropHealth + healthEffectFromAction + weatherDirectEffect + traitEffect).clamp(0.0, 100.0);

    if (_cropHealth <= 0) {
      if (!_cropStatusMessage.contains("withered")) {
         _cropStatusMessage += "\nYour crops didn't survive the day.";
      }
    } else {
       if (_cropStatusMessage.contains("(Health:")) {
          _cropStatusMessage = _cropStatusMessage.split('(Health:')[0].trim();
       }
       _cropStatusMessage += " (Health: ${_cropHealth.toStringAsFixed(0)}%)";
    }


    _aiJudgement = potentialJudgement;
    weatherResponseController.clear();

    _logGameState(
        'WeatherEventOutcome',
        eventDetails: 'Event: "$_currentWeatherEvent", PlayerInput: "$_playerWeatherResponse", ActionHealthEffect: ${healthEffectFromAction.toStringAsFixed(1)}, WeatherDirectEffect: ${weatherDirectEffect.toStringAsFixed(1)}, TraitEffect: ${traitEffect.toStringAsFixed(1)}, TotalHealthChange: ${(healthEffectFromAction + weatherDirectEffect + traitEffect).toStringAsFixed(1)}, FinalHealth: ${_cropHealth.toStringAsFixed(1)}, AIJudgement: ${enumToString(_aiJudgement)}, Feedback: "$_aiJudgementFeedback"'
    );

    if (!mounted) return;
    setState(() {
      _currentStage = GameStage.aiJudgement;
    });
     _logGameState('StageChange', eventDetails: 'AI Judgement');
     await _saveGameState();
  }


  void _proceedFromAIJudgement() async {
    if (_selectedSeedData == null) {
        _logGameState('Error', eventDetails: 'Attempted proceedFromAIJudgement with null _selectedSeedData');
        return;
    }

    if (_currentDay >= (_selectedSeedData?.harvestingDays ?? 99) || _cropHealth <= 0) {
      if (!mounted) return;
      setState(() {
        _currentStage = GameStage.harvesting;
      });
      _logGameState('StageChange', eventDetails: 'Harvesting');
    } else {
      if (!mounted) return;
      setState(() {
        _currentDay++;
        _currentStage = GameStage.dailyCycle;
        _cropStatusMessage = "${_selectedSeedData?.name} is growing... Day $_currentDay";
      });
      _logGameState('NewDay', eventDetails: 'Day $_currentDay started');
      _logGameState('StageChange', eventDetails: 'Daily Cycle');
      await _saveGameState();
    }
  }

  void _calculateHarvest() async {
    if (_selectedSeedData == null) {
         _logGameState('Error', eventDetails: 'Attempted harvest calculation with null _selectedSeedData');
        return;
    }

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
      ((baseValuePerDay * _selectedSeedData!.harvestingDays * qualityMultiplier) * (_cropHealth / 100.0)).toInt();

    _profitOrLoss = _harvestValue - _totalInvestment;
    _money += _profitOrLoss;

    if (_profitOrLoss > 100 && _cropQuality == "Excellent") {
      _gameOutcome = "Great Success!";
    } else if (_profitOrLoss > 0 && (_cropQuality == "Excellent" || _cropQuality == "Good")) {
       _gameOutcome = "Success!";
    } else if (_profitOrLoss >= 0 && (_cropQuality == "Average" || _cropQuality == "Poor")) {
       _gameOutcome = "Season Survived";
    } else if (_profitOrLoss >= -50 && _cropQuality != "Failed") {
        _gameOutcome = "Barely Survived";
    }
    else {
      _gameOutcome = "Failed Season";
    }

    _logGameState(
        'HarvestResults',
        eventDetails: 'Quality: $_cropQuality, Investment: $_totalInvestment, HarvestValue: $_harvestValue, Profit/Loss: $_profitOrLoss, Outcome: $_gameOutcome, NewMoney: $_money'
    );

    if (!mounted) return;
    setState(() {
      _currentStage = GameStage.results;
    });
     _logGameState('StageChange', eventDetails: 'Results Screen');
     await _saveGameState();
  }

  void _proceedFromResultsToTips() async {
     if (!mounted) return;
     setState(() {
       _currentStage = GameStage.showTips;
     });
     _logGameState('StageChange', eventDetails: 'Show Tips Screen');
     await _saveGameState();
  }


  void _resetGameForContinue() async {
     if (_isProcessingSelection) {
        return;
     }

    if (!mounted) return;
     setState(() {
       _isProcessingSelection = true;
     });

    _generateRandomSeedOptions();

    if (!mounted) return;
    setState(() {
      _currentStage = GameStage.terrainSelection;
      _selectedTerrain = null;
      _selectedSeedData = null;
      _currentDay = 1;
      _cropHealth = 100.0;
      _cropStatusMessage = "Ready for a new season!";
      _totalInvestment = 0;
      _inventory = _inventory;

      _cropQuality = "Unknown";
      _harvestValue = 0;
      _profitOrLoss = 0;
      _gameOutcome = "";

    });
     _logGameState('GameReset', eventDetails: 'Starting a new season. Money: ₱$_money, Inventory: $_inventory');
     _logGameState('StageChange', eventDetails: 'Terrain Selection (New Season)');
     await _saveGameState();

     if (!mounted) return;
     setState(() {
        _isProcessingSelection = false;
     });
  }


  void _goToHomeScreen() async {
     if (_isProcessingSelection) {
        return;
     }
     if (!mounted) return;
     setState(() {
       _isProcessingSelection = true;
     });

     _logGameState('AppQuitIntent', eventDetails: 'Returning to Home Screen from Tips');
     await _clearSaveFile();

     if (!mounted) return;
     setState(() {
       _currentStage = GameStage.loadingToHome;
     });
     _logGameState('StageChange', eventDetails: 'Loading to Home Screen');

     WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
             Navigator.of(context).pushAndRemoveUntil(
               MaterialPageRoute(builder: (context) => HomeScreen()),
                   (Route<dynamic> route) => false,
             );
        }
     });
  }

  String _getDynamicBackground() {
    if (_currentStage == GameStage.intro ||
        _currentStage == GameStage.showTips ||
        _currentStage == GameStage.loadingToHome ||
        _currentStage == GameStage.loadingGame ||
        _currentStage == GameStage.terrainSelection ||
        _currentStage == GameStage.seedSelection
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
    bool bottomBarVisibleArea = [
      GameStage.dailyCycle,
      GameStage.weatherForecast,
      GameStage.weatherEvent,
      GameStage.playerWeatherAction,
      GameStage.aiJudgement,
      GameStage.harvesting,
      GameStage.results,
      GameStage.showTips,
    ].contains(_currentStage);

    double topPadding = 80.0;
    double bottomPadding = bottomBarVisibleArea ? 150.0 : 40.0;

    if (_currentStage == GameStage.intro || _currentStage == GameStage.loadingGame) {
       topPadding = 100.0;
       bottomPadding = 100.0;
    } else if (_currentStage == GameStage.loadingToHome) {
       topPadding = 0; bottomPadding = 0;
    }


    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
             child: Image.asset(
                _getDynamicBackground(),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.green[700]),
             ),
          ),

          if (_currentStage != GameStage.loadingToHome && _currentStage != GameStage.loadingGame)
            Positioned(
              top: topPadding,
              bottom: bottomPadding,
              left: 0,
              right: 0,
              child: Center(
                 child: Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                   child: SingleChildScrollView(
                     physics: const BouncingScrollPhysics(),
                     child: _buildCurrentStageWidget(),
                   ),
                 ),
              ),
            ),

          if (_currentStage == GameStage.loadingToHome || _currentStage == GameStage.loadingGame)
             Positioned.fill(
                child: Container(
                   color: Colors.black.withOpacity(0.8),
                   child: Center(
                       child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           mainAxisSize: MainAxisSize.min,
                           children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 20),
                                Text(
                                   _currentStage == GameStage.loadingGame ? "Loading Game..." : "Returning to Home...",
                                   style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Futehodo-MaruGothic_1.00')
                                ),
                           ],
                       ),
                   ),
                ),
             ),

          if (_showWeatherImageOverlay && _currentWeatherEvent != null)
             Positioned(
               top: 80,
               left: 0,
               right: 0,
               child: Center(
                 child: _buildWeatherImageOverlayWidget(),
               ),
             ),

          if (bottomBarVisibleArea)
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
                               Padding(
                                 padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                        _buildItemInfoWidget('Fertilizer', _inventory['Fertilizer'] ?? 0),
                                        SizedBox(width: 2),
                                        _buildItemInfoWidget('Pest Spray', _inventory['Pest Spray'] ?? 0),
                                        SizedBox(width: 2),
                                        _buildItemInfoWidget('Shovel', _inventory['Shovel'] ?? 0),
                                    ],
                                 ),
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
      if (weatherImagePath == null) {
          return const SizedBox.shrink();
      }

      return Container(
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
              await Future.delayed(const Duration(milliseconds: 1500));
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
              Text("Gathering crops and calculating results...", style: TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center,),
            ],
          ),
        );
      case GameStage.results:
         WidgetsBinding.instance.addPostFrameCallback((_) async {
            await Future.delayed(const Duration(seconds: 4));
            if (mounted && _currentStage == GameStage.results) {
               _proceedFromResultsToTips();
            }
         });
        return _buildResultsScreen();
      case GameStage.showTips:
        return _buildTipsScreen();
      case GameStage.loadingToHome:
      case GameStage.loadingGame:
         return const SizedBox.shrink();
    }
  }

  Widget _buildIntro() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
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

  Widget _buildTerrainSelection() {
    if (_terrainDescriptions.isEmpty) {
         return _paperContainer(child: Text("Error: No terrain options available!", style: TextStyle(color: Colors.red, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center,));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _paperContainer(child: Text("Select Terrain", style: TextStyle(fontSize: 24, fontFamily: 'Futehodo-MaruGothic_1.00', color: Colors.white), textAlign: TextAlign.center,)),
        const SizedBox(height: 30),
        ..._terrainDescriptions.entries.map((entry) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: _styledButton(
            "${entry.key} \n(${entry.value})",
                _isProcessingSelection ? null : () => _selectTerrain(entry.key),
            isMultiLine: true,
          ),
        )),
      ],
    );
  }

  Widget _buildSeedSelection() {
    if (_availableSeedKeys.isEmpty) {
         return _paperContainer(child: Text("Error: No seeds available this season!", style: TextStyle(color: Colors.red, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center,));
    }

    final availableSeedData = _availableSeedKeys.map((key) => _seedInfo[key]).whereType<SeedData>().toList();
    if (availableSeedData.isEmpty) {
       return _paperContainer(child: Text("Error: Could not load seed data!", style: TextStyle(color: Colors.red, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center,));
    }

    List<Widget> seedButtons = [];
    for (int i = 0; i < availableSeedData.length; i += 2) {
      List<Widget> rowChildren = [];
      rowChildren.add(
          Flexible(
              child: _styledButton(
                  availableSeedData[i].name,
                      _isProcessingSelection ? null : () => _selectSeed(availableSeedData[i].name)
              ),
          )
      );
      if (i + 1 < availableSeedData.length) {
         rowChildren.add(SizedBox(width: 10));
         rowChildren.add(
             Flexible(
                 child: _styledButton(
                     availableSeedData[i + 1].name,
                         _isProcessingSelection ? null : () => _selectSeed(availableSeedData[i + 1].name)
                 ),
             )
         );
      }
      seedButtons.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rowChildren,
      ));
      if (i + 2 <= availableSeedData.length) {
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
      ],
    );
  }

  Widget _buildDailyCycleChoices() {
    bool canFertilize = (_inventory['Fertilizer'] ?? 0) > 0 && _money >= 20;
    bool canWeedPest = (_inventory['Pest Spray'] ?? 0) > 0 && _money >= 15;
    bool canPrepareSoil = (_inventory['Shovel'] ?? 0) > 0 && _money >= 10;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _paperContainer(
          child: Text(
            "Day $_currentDay/${_selectedSeedData?.harvestingDays ?? 'N/A'}\nWhat will you do?",
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
            "Prepare Soil (₱10, Use 1x Shovel)",
            canPrepareSoil ? () => _handleDailyAction(DailyAction.prepareSoil) : null,
        ),
        SizedBox(height: 10),
        _styledButton("Do Nothing (Risky)", () => _handleDailyAction(DailyAction.doNothing)),
      ],
    );
  }

  Widget buildWeatherForecastScreen() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(_currentStage == GameStage.weatherForecast && mounted) {
        await Future.delayed(const Duration(seconds: 2));
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

  Widget buildWeatherEventScreen() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentStage == GameStage.weatherEvent && mounted) {
        setState(() {
          _showWeatherImageOverlay = true;
        });

        _weatherImageTimer?.cancel();
        _weatherImageTimer = Timer(const Duration(seconds: 4), () {
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
            Text("Weather Alert!", style: TextStyle(fontSize: 24, color: const Color.fromARGB(255, 244, 0, 0), fontFamily: 'Futehodo-MaruGothic_1.00', fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
            SizedBox(height: 10),
            if(_currentWeatherHint != null)
              Text(_currentWeatherHint!, style: TextStyle(fontSize: 16, color: Colors.white70, fontStyle: FontStyle.italic, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center),
            SizedBox(height: 15),
            Text("Incoming Event: ${_currentWeatherEvent ?? 'Loading...'}", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center),
            SizedBox(height: 25),
            _styledButton("Respond to Weather!", () => setState(() => _currentStage = GameStage.playerWeatherAction)),
          ],
        )
    );
  }

  Widget _buildPlayerWeatherActionScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
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
              contentPadding: EdgeInsets.zero,
            ),
            onSubmitted: (_) => _processPlayerWeatherAction(),
          ),
        ),
        const SizedBox(height: 20),
        _styledButton("Submit Action", _processPlayerWeatherAction),
      ],
    );
  }

  Widget _buildAIJudgementScreen() {
     WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(seconds: 4));
        if (mounted && _currentStage == GameStage.aiJudgement) {
           _proceedFromAIJudgement();
        }
     });

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
                  _aiJudgement == AIJudgementCategory.ineffectiveOrTooLate ? const Color.fromARGB(255, 197, 73, 2) : Colors.yellowAccent,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Futehodo-MaruGothic_1.00'
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height:10),
            Text(_aiJudgementFeedback, style: TextStyle(fontSize: 16, color: Colors.white70, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center),
            SizedBox(height:20),
            Text("Crop Health: ${_cropHealth.toStringAsFixed(0)}%", style: TextStyle(fontSize: 18, color: _getHealthColor(_cropHealth), fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center,),
          ],
        )
    );
  }

  Widget _buildResultsScreen() {
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
          ],
        )
    );
  }

  Widget _buildTipsScreen() {
    final random = Random();
    String tip = _gameTips[random.nextInt(_gameTips.length)];
    String? harvestImagePath = _getUIImageAsset('Harvest Time');

    bool canContinueSeason = _money >= 10;
    bool showContinueButton = _gameOutcome != "Failed Season" && canContinueSeason;


    return Column(
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

          _paperContainer(
            padding: const EdgeInsets.all(12),
            child: Text(tip, style: TextStyle(fontSize: 18, color: Colors.white70, fontStyle: FontStyle.italic, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center),
          ),
          SizedBox(height: 15),
          Divider(color: Colors.white54, height: 20, thickness: 1),

          _paperContainer(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 Text("Last Season Summary:", style: TextStyle(fontSize: 18, color: const Color.fromARGB(255, 51, 162, 75), fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center,),
                 SizedBox(height: 8),
                 Text("Crop Quality: $_cropQuality", style: TextStyle(fontSize: 18, color: _cropQuality == "Excellent" ? Colors.greenAccent : (_cropQuality == "Failed" ? Colors.redAccent : Colors.yellowAccent), fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center,),
                 SizedBox(height: 4),
                 Text("Profit / Loss: ₱$_profitOrLoss", style: TextStyle(fontSize: 20, color: _profitOrLoss >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center,),
                  SizedBox(height: 4),
                 Text("Current Money: ₱$_money", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center,),
                 SizedBox(height: 4),
                 Text("Overall Outcome: $_gameOutcome", style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Futehodo-MaruGothic_1.00'), textAlign: TextAlign.center,),
              ],
            ),
          ),


          SizedBox(height:25),
          if(showContinueButton) ...[
            _styledButton("Continue Planting (New Season)", _isProcessingSelection ? null : _resetGameForContinue),
            SizedBox(height: 10),
          ],
          _styledButton("End Game (Back to Home)", _isProcessingSelection ? null : _goToHomeScreen),
        ],
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
          backgroundColor: Colors.transparent,
          disabledForegroundColor: Colors.white54,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
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
    double? width,
    double? height,
  }) {
    return Container(
      alignment: alignment,
      padding: padding,
      width: width,
      height: height,
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

  Color _getHealthColor(double health){
    if(health > 75) return Colors.greenAccent.withOpacity(0.9);
    if(health > 45) return Colors.orangeAccent.withOpacity(0.9);
    return Colors.redAccent.withOpacity(0.9);
  }

  String _getCropStatusText(double health) {
    if (health > 90) return "Excellent";
    if (health > 70) return "Good";
    if (health > 40) return "Moderate";
    if (health > 10) return "Poor";
    return "Bad";
  }

  Widget _uiInfoChip(String text, {IconData? icon, Color? statusColor}) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: statusColor ?? Colors.blueGrey.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, color: Colors.white, size: 14),
            if (icon != null) SizedBox(width: 4),
            Flexible(
                child: Text(
                    text,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Futehodo-MaruGothic_1.00', fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                )
            ),
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