import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gym_tracker/models/exercise_model.dart';
import '../helpers/database_helper.dart';
import 'package:intl/intl.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;

  ExerciseDetailScreen({required this.exercise});

  @override
  _ExerciseDetailScreenState createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _progressData = [];
  String _selectedMetric = 'weight';

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    final data = await _databaseHelper.getExerciseProgress(widget.exercise.id!);
    setState(() {
      _progressData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedMetric,
              items: ['weight', 'reps', 'negative_reps'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(_capitalizeMetric(value)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMetric = newValue!;
                });
              },
            ),
          ),
          Expanded(
            child: _progressData.isEmpty
                ? Center(child: Text('No progress data available'))
                : _buildChart(),
          ),
          Expanded(
            child: _buildProgressList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final spots = _progressData.asMap().entries.map((entry) {
      final value = entry.value[_selectedMetric] as num;
      return FlSpot(entry.key.toDouble(), value.toDouble());
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() % 5 == 0 &&
                      value.toInt() < _progressData.length) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        DateFormat('MMM d').format(DateTime.parse(
                            _progressData[value.toInt()]['date'])),
                        style: TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return Text('');
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(1),
                    style: TextStyle(fontSize: 10),
                  );
                },
                reservedSize: 40,
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          minX: 0,
          maxX: (spots.length - 1).toDouble(),
          minY: spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b) - 1,
          maxY: spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) + 1,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Theme.of(context).primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressList() {
    return ListView.builder(
      itemCount: _progressData.length,
      itemBuilder: (context, index) {
        final entry = _progressData[index];
        return ListTile(
          title: Text(
              DateFormat('MMMM d, y').format(DateTime.parse(entry['date']))),
          subtitle: Text(
            'Weight: ${entry['weight']}kg, Reps: ${entry['reps']}, Negative Reps: ${entry['negative_reps']}',
          ),
          trailing: Text(
            '${_capitalizeMetric(_selectedMetric)}: ${entry[_selectedMetric]}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  String _capitalizeMetric(String metric) {
    return metric
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
