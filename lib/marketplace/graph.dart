import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agritayo/screens/profile_screen.dart';

class DemandData {
  final String item;
  final List<DemandPeriod> demandHistory;

  DemandData({required this.item, required this.demandHistory});

  factory DemandData.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) throw StateError('Demand data document is null or empty');
    final List<dynamic> history = data['demand_history'] ?? [];
    final demandHistory = history.map((item) => DemandPeriod.fromMap(item as Map<String, dynamic>)).toList();
    return DemandData(
      item: data['item'] ?? 'Unknown Item',
      demandHistory: demandHistory,
    );
  }
}

class DemandPeriod {
  final String period;
  final double value;

  DemandPeriod({required this.period, required this.value});

  factory DemandPeriod.fromMap(Map<String, dynamic> map) {
    final value = map['value'];
    double parsedValue = 0.0;
    if (value is num) {
      parsedValue = value.toDouble();
    } else if (value is String) {
      parsedValue = double.tryParse(value) ?? 0.0;
    }
    return DemandPeriod(
      period: map['period'] ?? 'N/A',
      value: parsedValue,
    );
  }
}

class RankingItem {
  final String item;
  final double percentage;

  RankingItem({required this.item, required this.percentage});

  factory RankingItem.fromMap(Map<String, dynamic> map) {
     final percentage = map['percentage'];
     double parsedPercentage = 0.0;
      if (percentage is num) {
        parsedPercentage = percentage.toDouble();
      } else if (percentage is String) {
        parsedPercentage = double.tryParse(percentage) ?? 0.0;
      }

    return RankingItem(
      item: map['item'] ?? 'Unknown Item',
      percentage: parsedPercentage,
    );
  }
}

class MonthlyRanking {
  final String month;
  final List<RankingItem> rankings;

  MonthlyRanking({required this.month, required this.rankings});

   factory MonthlyRanking.fromDocument(DocumentSnapshot doc) {
     final data = doc.data() as Map<String, dynamic>?;
     if (data == null) throw StateError('Ranking data document is null or empty');
     final List<dynamic> rankingList = data['ranking'] ?? [];
     final rankings = rankingList.map((item) => RankingItem.fromMap(item as Map<String, dynamic>)).toList();

     rankings.sort((a, b) => b.percentage.compareTo(a.percentage));

     return MonthlyRanking(
       month: data['month'] ?? 'N/A Month',
       rankings: rankings,
     );
   }
}

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  bool isGraphExpanded = false;

  void _onGraphClick() {
    setState(() {
      isGraphExpanded = !isGraphExpanded;
    });
  }

  List<BarChartGroupData> _buildBarGroups(List<DemandPeriod> history) {
    final displayHistory = history.length > 12 ? history.sublist(history.length - 12) : history;

    return displayHistory.asMap().entries.map((entry) {
      int index = entry.key;
      DemandPeriod periodData = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: periodData.value,
            color: Colors.green,
            width: 25,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
         showingTooltipIndicators: [0],
      );
    }).toList();
  }

  Widget _buildBarChartContent(DemandData demandData) {
     final displayedHistory = demandData.demandHistory.length > 12 ? demandData.demandHistory.sublist(demandData.demandHistory.length - 12) : demandData.demandHistory;

     if (displayedHistory.isEmpty) {
       return const Center(child: Text("Not enough history data for graph."));
     }

     final barGroups = _buildBarGroups(displayedHistory);
     final maxHistoryValue = displayedHistory.map((e) => e.value).reduce((a, b) => a > b ? a : b);


    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text("Demand History for ${demandData.item}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            child: BarChart(
              BarChartData(
                maxY: maxHistoryValue * 1.2,
                titlesData: FlTitlesData(
                   show: true,
                   bottomTitles: AxisTitles(
                     sideTitles: SideTitles(
                       showTitles: true,
                       getTitlesWidget: (value, meta) {
                          final historyIndex = value.toInt();

                          if (historyIndex >= 0 && historyIndex < displayedHistory.length) {
                             final period = displayedHistory[historyIndex].period;
                             return SideTitleWidget(
                               space: 4.0,
                               child: Text(period.split(' ')[0].substring(0, 3), style: TextStyle(fontSize: 10)),
                               meta: meta,
                             );
                          }
                         return const Text('');
                       },
                       interval: 1,
                       reservedSize: 22,
                     ),
                   ),
                   leftTitles: AxisTitles(
                     sideTitles: SideTitles(
                       showTitles: true,
                       reservedSize: 30,
                       getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString(), style: TextStyle(fontSize: 10));
                       }
                     ),
                   ),
                   topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                   rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
                gridData: FlGridData(
                   show: true,
                   drawVerticalLine: false,
                   drawHorizontalLine: true,
                   getDrawingHorizontalLine: (value) => FlLine(
                       color: Colors.grey[300],
                       strokeWidth: 0.5,
                   ),
                ),
                 barTouchData: BarTouchData(
                   touchTooltipData: BarTouchTooltipData(
                     tooltipRoundedRadius: 8,
                     getTooltipItem: (group, groupIndex, rod, rodIndex) {
                       final displayHistory = demandData.demandHistory.length > 12 ? demandData.demandHistory.sublist(demandData.demandHistory.length - 12) : demandData.demandHistory;

                       if (groupIndex < 0 || groupIndex >= displayHistory.length) {
                         return null;
                       }
                       final periodData = displayHistory[groupIndex];

                       return BarTooltipItem(
                         '${periodData.period}\n${rod.toY.toStringAsFixed(1)}',
                         const TextStyle(
                           color: Colors.white,
                           fontWeight: FontWeight.bold,
                           fontSize: 14,
                         ),
                       );
                     },
                   ),
                 ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankingListContent(MonthlyRanking rankingData) {
    if (rankingData.rankings.isEmpty) {
      return const Center(child: Text("No ranking data available for this month."));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Text("Top Selling Crops - ${rankingData.month}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: rankingData.rankings.length,
            itemBuilder: (context, index) {
              final item = rankingData.rankings[index];
              return ListTile(
                leading: CircleAvatar(
                   backgroundColor: Colors.green,
                   child: Text('${index + 1}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                title: Text(item.item, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text('${item.percentage.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold)),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    String firstName = (user?.displayName?.split(' ').first ?? 'Guest');
    String? photoUrl = user?.photoURL;

     final Stream<DocumentSnapshot> historyStream =
         FirebaseFirestore.instance.collection('demand_summary').doc('latest_monthly').snapshots();

     final Stream<DocumentSnapshot> rankingStream =
         FirebaseFirestore.instance.collection('monthly_rankings').doc('current').snapshots();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/AgriMarket.png"),
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
                          Navigator.pop(context);
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
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileScreen()),
                          );
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                                  ? NetworkImage(photoUrl)
                                  : const AssetImage('assets/user.jpg') as ImageProvider,
                              radius: 16,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(firstName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const Text("Farmer", style: TextStyle(fontSize: 11)),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: GestureDetector(
                    onTap: _onGraphClick,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.yellow[100],
                        borderRadius: BorderRadius.circular(12),
                         border: Border.all(color: Colors.orange[700] ?? Colors.orange, width: 2)
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                         child: Container(
                             decoration: BoxDecoration(
                                color: Colors.orange[300],
                                borderRadius: BorderRadius.circular(8),
                             ),
                             child: StreamBuilder<DocumentSnapshot>(
                               stream: historyStream,
                               builder: (context, historySnapshot) {
                                 return StreamBuilder<DocumentSnapshot>(
                                   stream: rankingStream,
                                   builder: (context, rankingSnapshot) {
                                     if (historySnapshot.connectionState == ConnectionState.waiting ||
                                         rankingSnapshot.connectionState == ConnectionState.waiting) {
                                       return const Center(child: CircularProgressIndicator());
                                     }
                                     if (historySnapshot.hasError) {
                                       return Center(child: Text('Error loading history: ${historySnapshot.error}'));
                                     }
                                     if (rankingSnapshot.hasError) {
                                        return Center(child: Text('Error loading ranking: ${rankingSnapshot.error}'));
                                      }

                                     final bool historyDataExists = historySnapshot.hasData && historySnapshot.data!.exists && historySnapshot.data!.data() != null;
                                     final bool rankingDataExists = rankingSnapshot.hasData && rankingSnapshot.data!.exists && rankingSnapshot.data!.data() != null;

                                     if (isGraphExpanded) {
                                       if (rankingDataExists) {
                                          try {
                                             final rankingData = MonthlyRanking.fromDocument(rankingSnapshot.data!);
                                             return _buildRankingListContent(rankingData);
                                          } catch (e) {
                                            return Center(child: Text('Error parsing ranking data: $e'));
                                          }
                                       } else {
                                         return const Center(child: Text('No monthly ranking data available.'));
                                       }
                                     } else {
                                       if (historyDataExists) {
                                          try {
                                             final demandData = DemandData.fromDocument(historySnapshot.data!);
                                              if (demandData.demandHistory.isEmpty) {
                                                 return const Center(child: Text("No history data to display chart."));
                                              }
                                             return _buildBarChartContent(demandData);
                                          } catch (e) {
                                            return Center(child: Text('Error parsing history data: $e'));
                                          }
                                       } else {
                                         return const Center(child: Text('No history data available.'));
                                       }
                                     }
                                   },
                                 );
                               },
                             ),
                           ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                 Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                   child: Text(
                     isGraphExpanded
                         ? "Tap to see monthly history"
                         : "Tap to see this month's ranking",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                   ),
                 ),
                 const SizedBox(height: 12),

              ],
            ),
          ),
        ],
      ),
    );
  }
}