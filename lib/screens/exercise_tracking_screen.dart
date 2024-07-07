import 'package:flutter/material.dart';
import 'package:gym_tracker/models/exercise_model.dart';
import 'package:gym_tracker/widgets/exercise_dialog.dart';
import '../helpers/database_helper.dart';
import 'exercise_detail_screen.dart';
import 'package:intl/intl.dart';

class ExerciseTrackingScreen extends StatefulWidget {
  @override
  _ExerciseTrackingScreenState createState() => _ExerciseTrackingScreenState();
}

class _ExerciseTrackingScreenState extends State<ExerciseTrackingScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<ExerciseSet> _exerciseSets = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExerciseSets();
  }

  Future<void> _loadExerciseSets() async {
    final sets = await _databaseHelper.getExerciseSets();
    setState(() {
      _exerciseSets = sets.map((set) => ExerciseSet.fromMap(set)).toList();
    });
  }

  void _filterExerciseSets(String query) {
    // Implement exercise set filtering logic here
  }

  Future<void> _addExerciseSet() async {
    final name = await _showAddExerciseSetDialog();
    if (name != null) {
      final date = DateTime.now().toIso8601String();
      await _databaseHelper.insertExerciseSet(name, date);
      _loadExerciseSets();
    }
  }

  Future<String?> _showAddExerciseSetDialog() async {
    String? name;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Exercise Set'),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(hintText: "Enter set name"),
          onChanged: (value) {
            name = value;
          },
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Add'),
            onPressed: () => Navigator.of(context).pop(name),
          ),
        ],
      ),
    );
    return name;
  }

  Future<void> _showExerciseListDialog(ExerciseSet set) async {
    final exercises = await _databaseHelper.getExercisesForSet(set.id!);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(set.name),
        content: SizedBox(
          width: double.maxFinite,
          child: exercises.isEmpty
              ? Text('No exercises in this set.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = Exercise.fromMap(exercises[index]);
                    return ListTile(
                      title: Text(exercise.name),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ExerciseDetailScreen(exercise: exercise),
                          ),
                        ).then((_) => _loadExerciseSets());
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            child: Text('Add Exercise'),
            onPressed: () {
              Navigator.of(context).pop();
              _addExercise(set);
            },
          ),
          TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _addExercise(ExerciseSet set) async {
    final exercise = await showDialog<Exercise>(
      context: context,
      builder: (context) => ExerciseDialog(),
    );

    if (exercise != null) {
      await _databaseHelper.insertExercise(
        set.id!,
        exercise.name,
        exercise.weight,
        exercise.reps,
        exercise.negativeReps,
      );
      _loadExerciseSets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercise Tracking'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Exercise Sets',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: _filterExerciseSets,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _exerciseSets.length,
              itemBuilder: (context, index) {
                final set = _exerciseSets[index];
                return ListTile(
                  title: Text(set.name),
                  subtitle: Text(
                      DateFormat('MMMM d, y').format(DateTime.parse(set.date))),
                  onTap: () => _showExerciseListDialog(set),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExerciseSet,
        child: Icon(Icons.add),
      ),
    );
  }
}
