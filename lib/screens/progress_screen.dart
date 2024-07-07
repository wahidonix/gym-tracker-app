import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../helpers/database_helper.dart';
import 'package:intl/intl.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<FlSpot> _allWeightData = [];
  List<FlSpot> _displayedWeightData = [];
  List<Map<String, dynamic>> _logs = [];
  double _minY = 0, _maxY = 100;
  List<DateTime> _allDates = [];
  List<DateTime> _displayedDates = [];
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadWeightData();
  }

  Future<void> _loadWeightData() async {
    final logs = await _databaseHelper.getDailyLogs();
    if (logs.isEmpty) {
      setState(() => _logs = []);
      return;
    }

    setState(() {
      _logs = logs;
      _allDates = logs.map((log) => DateTime.parse(log['date'])).toList();
      _allWeightData = List.generate(logs.length,
          (index) => FlSpot(index.toDouble(), logs[index]['weight']));
      _startDate = _allDates.first;
      _endDate = _allDates.last;
      _updateDisplayedData();
    });
  }

  void _updateDisplayedData() {
    if (_startDate == null || _endDate == null) return;

    _displayedWeightData = [];
    _displayedDates = [];
    for (int i = 0; i < _logs.length; i++) {
      final date = DateTime.parse(_logs[i]['date']);
      if (date.isAfter(_startDate!.subtract(Duration(days: 1))) &&
          date.isBefore(_endDate!.add(Duration(days: 1)))) {
        _displayedWeightData
            .add(FlSpot(_displayedDates.length.toDouble(), _logs[i]['weight']));
        _displayedDates.add(date);
      }
    }

    if (_displayedWeightData.isNotEmpty) {
      _minY = _displayedWeightData
              .map((spot) => spot.y)
              .reduce((a, b) => a < b ? a : b) -
          1;
      _maxY = _displayedWeightData
              .map((spot) => spot.y)
              .reduce((a, b) => a > b ? a : b) +
          1;
    }
  }

  String _getDateString(double value) {
    final index = value.toInt();
    if (index >= 0 && index < _displayedDates.length) {
      return DateFormat('MMM d').format(_displayedDates[index]);
    }
    return '';
  }

  Future<void> _selectDateRange(BuildContext context) async {
    if (_allDates.isEmpty) return;

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: _allDates.first,
      lastDate: _allDates.last,
      initialDateRange: DateTimeRange(
          start: _startDate ?? _allDates.first,
          end: _endDate ?? _allDates.last),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _updateDisplayedData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Progress'),
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
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _displayedWeightData.isEmpty
                  ? Center(child: Text('No data available for selected range'))
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value % 7 == 0 ||
                                    value == _displayedWeightData.length - 1) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      _getDateString(value),
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
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toStringAsFixed(1),
                                  style: TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: true),
                        minX: 0,
                        maxX: (_displayedWeightData.length - 1).toDouble(),
                        minY: _minY,
                        maxY: _maxY,
                        lineBarsData: [
                          LineChartBarData(
                            spots: _displayedWeightData,
                            isCurved: true,
                            color: Theme.of(context).primaryColor,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          Expanded(
            flex: 3,
            child: ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                final date = DateTime.parse(log['date']);
                if (_startDate != null &&
                    _endDate != null &&
                    date.isAfter(_startDate!.subtract(Duration(days: 1))) &&
                    date.isBefore(_endDate!.add(Duration(days: 1)))) {
                  final weight = log['weight'].toStringAsFixed(1);
                  return ListTile(
                    title: Text('${DateFormat('MMMM d, y').format(date)}'),
                    trailing: Text('$weight kg',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () {
                      // You can add functionality here when a list item is tapped
                    },
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
