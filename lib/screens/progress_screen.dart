import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gym_tracker/themes/app_themes.dart';
import '../helpers/database_helper.dart';
import 'package:intl/intl.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _allProgressData = [];
  List<Map<String, dynamic>> _filteredProgressData = [];
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    final data = await _databaseHelper.getDailyLogs();
    setState(() {
      _allProgressData = data;
      _filteredProgressData = data;
      if (data.isNotEmpty) {
        _startDate = DateTime.parse(data.first['date']);
        _endDate = DateTime.parse(data.last['date']);
      }
    });
  }

  void _updateFilteredData() {
    if (_startDate == null || _endDate == null) return;
    setState(() {
      _filteredProgressData = _allProgressData.where((entry) {
        final date = DateTime.parse(entry['date']);
        return date.isAfter(_startDate!.subtract(Duration(days: 1))) &&
            date.isBefore(_endDate!.add(Duration(days: 1)));
      }).toList();
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    if (_allProgressData.isEmpty) return;

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.parse(_allProgressData.first['date']),
      lastDate: DateTime.parse(_allProgressData.last['date']),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _updateFilteredData();
      });
    }
  }

  Widget _buildChart() {
    if (_filteredProgressData.isEmpty) {
      return Center(
          child: Text('No progress data available for selected range'));
    }

    final spots = _filteredProgressData.map((entry) {
      final date = DateTime.parse(entry['date']);
      final daysFromStart = date.difference(_startDate!).inDays;
      return FlSpot(daysFromStart.toDouble(), entry['weight'].toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final date = _startDate!.add(Duration(days: value.toInt()));
                if (date.isAfter(_endDate!)) {
                  return SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    DateFormat('MM/dd').format(date),
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                );
              },
              reservedSize: 32,
              interval: (_filteredProgressData.length / 5).ceil().toDouble(),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        minX: 0,
        maxX: _endDate!.difference(_startDate!).inDays.toDouble(),
        minY: spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b) - 1,
        maxY: spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) + 1,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppThemes.getChartColor(context),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppThemes.getChartColor(context),
                  strokeWidth: 2,
                  strokeColor: Theme.of(context).scaffoldBackgroundColor,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppThemes.getChartColor(context).withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressList() {
    return ListView.builder(
      itemCount: _filteredProgressData.length,
      itemBuilder: (context, index) {
        final entry = _filteredProgressData[index];
        final date = DateTime.parse(entry['date']);
        return Dismissible(
          key: Key(entry['id'].toString()),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            _deleteWeightLog(entry['id']);
          },
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ListTile(
              title: Text(DateFormat('MMMM d, y').format(date)),
              trailing: Text(
                '${entry['weight'].toStringAsFixed(1)} kg',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteWeightLog(int id) async {
    await _databaseHelper.deleteWeightLog(id);
    _loadProgressData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Date'),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _startDate != null && _endDate != null
                  ? 'Date Range: ${DateFormat('MMM d, y').format(_startDate!)} - ${DateFormat('MMM d, y').format(_endDate!)}'
                  : 'No date range selected',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildChart(),
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildProgressList(),
          ),
        ],
      ),
    );
  }
}
