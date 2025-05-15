import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    double parsedValue = (value is num) ? value.toDouble() : 0.0;
    return DemandPeriod(
      period: map['period'] ?? 'N/A',
      value: parsedValue,
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
    return history.asMap().entries.map((entry) {
      int index = entry.key;
      DemandPeriod periodData = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: periodData.value,
            color: Colors.green,
            width: 30,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    String firstName = (user?.displayName?.split(' ').first ?? 'Guest');
    String? photoUrl = user?.photoURL;

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
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: photoUrl != null
                                ? NetworkImage(photoUrl)
                                : const AssetImage('assets/user.jpg') as ImageProvider,
                            radius: 16,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(firstName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Text("Farmer", style: TextStyle(fontSize: 12)),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _onGraphClick,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.yellow[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    height: isGraphExpanded ? 400 : 120,
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('demand_summary').doc('latest_monthly').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error loading demand data: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || !snapshot.data!.exists || snapshot.data!.data() == null) {
                          return const Center(child: Text('No demand data available.'));
                        }
                        final demandData = DemandData.fromDocument(snapshot.data!);
                        final barGroups = _buildBarGroups(demandData.demandHistory);
                        return Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.orange[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: isGraphExpanded
                                    ? Center(
                                        child: Text(
                                          "Demand Graph for ${demandData.item}\n(Expanded View)",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                        ),
                                      )
                                    : barGroups.isNotEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0, right: 4.0),
                                            child: BarChart(
                                              BarChartData(
                                                maxY: demandData.demandHistory.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2,
                                                titlesData: FlTitlesData(show: false),
                                                borderData: FlBorderData(show: false),
                                                barGroups: barGroups,
                                                gridData: FlGridData(show: false),
                                              ),
                                            ),
                                          )
                                        : const Center(child: Text("Not enough data for graph.")),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text("Demand for ${demandData.item}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        );
                      },
                    ),
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
