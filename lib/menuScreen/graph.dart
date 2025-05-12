import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../screens/home.dart';

class Graph extends StatefulWidget {
  const Graph({super.key});

  @override
  _MarketPricePageState createState() => _MarketPricePageState();
}

class _MarketPricePageState extends State<Graph> {
  bool isGraphExpanded = false;
  bool isPriceListDisabled = false; 

  void _onGraphClick() {
    setState(() {
      isGraphExpanded = !isGraphExpanded;
      isPriceListDisabled = isGraphExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/AgriMarket.png"),
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
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
    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
  ),
),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage('assets/images/AgriMarket.png'),
                          ),
                          SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text("Farmer", style: TextStyle(fontSize: 12)),
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
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.yellow[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    height: isGraphExpanded ? 300 : 120, 
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.orange, 
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: isGraphExpanded
                                ? Center(
                                    child: Text(
                                      "Text Here",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  )
                                : BarChart(
                                    BarChartData(
                                      gridData: FlGridData(show: false),
                                      titlesData: FlTitlesData(show: false),
                                      borderData: FlBorderData(show: false),
                                      barGroups: [
                                        BarChartGroupData(
                                          x: 0,
                                          barRods: [
                                            BarChartRodData(
                                              toY: 1,
                                              color: Colors.green,
                                              width: 30,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ],
                                        ),
                                        BarChartGroupData(
                                          x: 1,
                                          barRods: [
                                            BarChartRodData(
                                              toY: 1.5,
                                              color: Colors.green,
                                              width: 30,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ],
                                        ),
                                        BarChartGroupData(
                                          x: 2,
                                          barRods: [
                                            BarChartRodData(
                                              toY: 1.4,
                                              color: Colors.green,
                                              width: 30,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ],
                                        ),
                                        BarChartGroupData(
                                          x: 3,
                                          barRods: [
                                            BarChartRodData(
                                              toY: 3.4,
                                              color: Colors.green,
                                              width: 30,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ],
                                        ),
                                        BarChartGroupData(
                                          x: 4,
                                          barRods: [
                                            BarChartRodData(
                                              toY: 2,
                                              color: Colors.green,
                                              width: 30,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ],
                                        ),
                                        BarChartGroupData(
                                          x: 5,
                                          barRods: [
                                            BarChartRodData(
                                              toY: 2.2,
                                              color: Colors.green,
                                              width: 30,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ],
                                        ),
                                        BarChartGroupData(
                                          x: 6,
                                          barRods: [
                                            BarChartRodData(
                                              toY: 1.8,
                                              color: Colors.green,
                                              width: 30,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text("Demand for Potatoes", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12),

                if (!isPriceListDisabled)
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        border: Border.all(color: Colors.orange, width: 25.0),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Search",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          SizedBox(height: 12),

                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Item", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text("Prices\n(As of Date here)", textAlign: TextAlign.right),
                            ],
                          ),
                          Divider(),

                          // List of Items
                          Expanded(
                            child: ListView(
                              children: [
                                _buildClickableItem("Carrots", "100 per kg", (itemName) => _onItemClick(context, itemName)),
                                Divider(),
                                _buildClickableItem("Tomatoes", "80 per kg", (itemName) => _onItemClick(context, "Tomatoes")),
                              ],
                            ),
                          )
                        ],
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

  Widget _buildClickableItem(String name, String price, Function(String) onTap) {
    return InkWell(
      onTap: () => onTap(name),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: TextStyle(fontWeight: FontWeight.w500)),
            Text(price, style: TextStyle(fontWeight: FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}

class _onItemClick {
  _onItemClick(BuildContext context, String itemName);
}