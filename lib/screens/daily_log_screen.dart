import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import 'package:gym_tracker/models/exercise_model.dart';
import 'package:intl/intl.dart';

class DailyLogScreen extends StatefulWidget {
  @override
  _DailyLogScreenState createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _exerciseWeightController =
      TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _negativeRepsController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  double? _lastWeight;
  List<Map<String, dynamic>> _recentLogs = [];
  List<Exercise> _dailyExercises = [];
  List<Exercise> _allExercises = [];
  Exercise? _selectedExercise;

  @override
  void initState() {
    super.initState();
    _loadLastWeight();
    _loadRecentLogs();
    _loadDailyExercises();
    _loadAllExercises();
  }

  Future<void> _loadLastWeight() async {
    final lastLog = await _databaseHelper.getLastWeightLog();
    if (lastLog != null) {
      setState(() {
        _lastWeight = lastLog['weight'];
      });
    }
  }

  Future<void> _loadRecentLogs() async {
    final logs = await _databaseHelper.getRecentWeightLogs(7);
    setState(() {
      _recentLogs = logs;
    });
  }

  Future<void> _loadAllExercises() async {
    final exercises = await _databaseHelper.getAllExercises();
    setState(() {
      _allExercises = exercises.map((e) => Exercise.fromMap(e)).toList();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadDailyExercises();
    }
  }

  Future<void> _logWeight() async {
    if (_weightController.text.isNotEmpty) {
      final weight = double.parse(_weightController.text);
      await _databaseHelper.insertOrUpdateDailyLog(
        _selectedDate.toIso8601String().split('T')[0],
        weight,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Weight logged successfully')),
      );
      _weightController.clear();
      _loadLastWeight();
      _loadRecentLogs();
      _loadDailyExercises(); // Reload exercises for the selected date
    }
  }

  Future<void> _logExercise() async {
    if (_selectedExercise != null &&
        _exerciseWeightController.text.isNotEmpty &&
        _repsController.text.isNotEmpty &&
        _negativeRepsController.text.isNotEmpty) {
      try {
        final weight = double.parse(_exerciseWeightController.text);
        final reps = int.parse(_repsController.text);
        final negativeReps = int.parse(_negativeRepsController.text);

        await _databaseHelper.logExerciseProgress(
          _selectedExercise!.id!,
          _selectedDate.toIso8601String().split('T')[0],
          weight,
          reps,
          negativeReps,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exercise log updated successfully')),
        );

        _exerciseWeightController.clear();
        _repsController.clear();
        _negativeRepsController.clear();
        setState(() {
          _selectedExercise = null;
        });

        _loadDailyExercises();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging exercise: ${e.toString()}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  Future<void> _loadDailyExercises() async {
    try {
      final exercises = await _databaseHelper
          .getDailyExercises(_selectedDate.toIso8601String().split('T')[0]);
      setState(() {
        _dailyExercises = exercises.map((e) => Exercise.fromMap(e)).toList();
      });
    } catch (e) {
      print('Error loading daily exercises: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading exercises')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              _buildDateSelector(),
              SizedBox(height: 24),
              _buildWeightLoggingCard(),
              SizedBox(height: 24),
              _buildExerciseLoggingCard(),
              SizedBox(height: 24),
              Text(
                'Exercises for ${DateFormat('MMMM d, y').format(_selectedDate)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 8),
              _buildDailyExercisesCard(),
              SizedBox(height: 24),
              Text(
                'Recent Weight Logs',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 8),
              _buildRecentLogsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Date: ${DateFormat('MMMM d, y').format(_selectedDate)}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        ElevatedButton.icon(
          onPressed: () => _selectDate(context),
          icon: Icon(Icons.calendar_today),
          label: Text('Change'),
        ),
      ],
    );
  }

  Widget _buildWeightLoggingCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Log Your Weight',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.fitness_center),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _logWeight,
              child: Text('Log Weight'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseLoggingCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Log Exercise',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<Exercise>(
              value: _selectedExercise,
              items: _allExercises.map((Exercise exercise) {
                return DropdownMenuItem<Exercise>(
                  value: exercise,
                  child: Text(exercise.name),
                );
              }).toList(),
              onChanged: (Exercise? newValue) {
                setState(() {
                  _selectedExercise = newValue;
                  // Pre-fill with existing data if available
                  if (_selectedExercise != null) {
                    final existingLog = _dailyExercises.firstWhere(
                      (e) => e.id == _selectedExercise!.id,
                      orElse: () => Exercise(
                          id: null,
                          setId: 0,
                          name: '',
                          weight: 0,
                          reps: 0,
                          negativeReps: 0),
                    );
                    _exerciseWeightController.text =
                        existingLog.weight.toString();
                    _repsController.text = existingLog.reps.toString();
                    _negativeRepsController.text =
                        existingLog.negativeReps.toString();
                  }
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Exercise',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _exerciseWeightController,
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _repsController,
              decoration: InputDecoration(
                labelText: 'Reps',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _negativeRepsController,
              decoration: InputDecoration(
                labelText: 'Negative Reps',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _logExercise,
              child: Text('Log Exercise'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyExercisesCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _dailyExercises.isEmpty
            ? Text('No exercises logged for this date.')
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _dailyExercises.length,
                itemBuilder: (context, index) {
                  final exercise = _dailyExercises[index];
                  return ListTile(
                    title: Text(exercise.name),
                    subtitle: Text(
                        'Weight: ${exercise.weight}kg, Reps: ${exercise.reps}, Negative Reps: ${exercise.negativeReps}'),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildRecentLogsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_lastWeight != null)
              Text(
                'Last recorded weight: ${_lastWeight!.toStringAsFixed(1)} kg',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _recentLogs.length,
              itemBuilder: (context, index) {
                final log = _recentLogs[index];
                return ListTile(
                  title: Text(DateFormat('MMMM d, y')
                      .format(DateTime.parse(log['date']))),
                  trailing: Text('${log['weight'].toStringAsFixed(1)} kg'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
