import 'package:flutter/material.dart';
import 'package:easycoutcol/app/Records.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:easycoutcol/app/Records.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GraphRecordScreen extends StatefulWidget {
  static const String name = 'graph_record_name';
  int followID;
  GraphRecordScreen({super.key, required this.followID});
  @override
  State<GraphRecordScreen> createState() => _GraphRecordScreenState();
}

class _GraphRecordScreenState extends State<GraphRecordScreen> {
  List<Records> records = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  Future<List<Records>> fetchRecords() async {
    final apiUrl =dotenv.env['API_URL'] ?? 'http://localhost:8000';

    final response =
        await http.get(Uri.parse('$apiUrl/records/${widget.followID}'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List list = data['records'] ?? [];

      return list.map((e) => Records.fromJsonList(e)).toList();
    } else {
      throw Exception('Error ${response.statusCode}');
    }
  }

  // 🔹 CARGAR DATOS
  Future<void> loadRecords() async {
    try {
      final data = await fetchRecords();
      print(data);
      data.sort((a, b) => a.id.compareTo(b.id)); // ordenar
      setState(() {
        records = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 🔹 CONVERTIR A SPOTS
  List<FlSpot> getSpots() {
    return records.map((e) {
      return FlSpot(
        e.dayNumber.toDouble(),
        e.colonyCount.toDouble(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final spots = getSpots();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grafica de crecimiento'),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: AspectRatio(
                aspectRatio: 1.5,
                child: LineChart(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    LineChartData(
                      backgroundColor: Colors.transparent,

                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),

                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 11,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                'D${value.toInt()}',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 11,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipPadding: const EdgeInsets.all(8),
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              return LineTooltipItem(
                                'Día ${spot.x.toInt()}\n${spot.y.toInt()} UFC',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),

                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.4,
                          barWidth: 3,
                          isStrokeCapRound: true,

                          gradient: LinearGradient(
                            colors: [
                              Colors.indigo.shade400,
                              Colors.blueGrey.shade300,
                            ],
                          ),

                          // 🔘 Puntos discretos
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 3,
                                color: Colors.indigo.shade400,
                                strokeWidth: 1.5,
                                strokeColor: Colors.white,
                              );
                            },
                          ),

                          // 🌫 Área MUY sutil
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.indigo.withOpacity(0.15),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Registros',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 📋 Lista
            Expanded(
              child: ListView.builder(
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final item = records[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colors.primary,
                        child: Text(
                          '${item.dayNumber}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text('Día ${item.dayNumber}'),
                      subtitle: Text('Colonias: ${item.colonyCount} UFC'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "back",
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back_ios_new_rounded),
      ),
    );
  }
}
