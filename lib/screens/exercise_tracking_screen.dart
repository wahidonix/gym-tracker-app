import 'package:flutter/material.dart';
import 'package:gym_tracker/models/exercise_model.dart';
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
    final exerciseName = await _showAddExerciseDialog();
    if (exerciseName != null) {
      await _databaseHelper.insertExercise(set.id!, exerciseName);
      _loadExerciseSets();
    }
  }

  Future<String?> _showAddExerciseDialog() async {
    String? name;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Exercise'),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(hintText: "Enter exercise name"),
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

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final ExerciseSet item = _exerciseSets.removeAt(oldIndex);
      _exerciseSets.insert(newIndex, item);
    });
    _databaseHelper.updateExerciseSetOrder(_exerciseSets);
  }

  Future<void> _deleteExerciseSet(ExerciseSet set) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Exercise Set'),
        content: Text(
            'Are you sure you want to delete "${set.name}" and all its exercises? This action cannot be undone.'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _databaseHelper.deleteExerciseSet(set.id!);
    }

    // Always reload the exercise sets, whether deletion was confirmed or not
    _loadExerciseSets();
  }

  Future<void> _renameExerciseSet(ExerciseSet set) async {
    final newName = await _showRenameDialog(set.name);
    if (newName != null && newName != set.name) {
      await _databaseHelper.renameExerciseSet(set.id!, newName);
      _loadExerciseSets();
    }
  }

  Future<String?> _showRenameDialog(String currentName) async {
    String? newName = currentName;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rename Exercise Set'),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(hintText: "Enter new name"),
          onChanged: (value) {
            newName = value;
          },
          controller: TextEditingController(text: currentName),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Rename'),
            onPressed: () => Navigator.of(context).pop(newName),
          ),
        ],
      ),
    );
    return newName != currentName ? newName : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: ReorderableListView.builder(
              itemCount: _exerciseSets.length,
              itemBuilder: (context, index) {
                final set = _exerciseSets[index];
                return Dismissible(
                  key: Key(set.id.toString()),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    await _deleteExerciseSet(set);
                    return false; // Always return false to prevent automatic dismissal
                  },
                  child: ListTile(
                    title: Text(set.name),
                    subtitle: Text(DateFormat('MMMM d, y')
                        .format(DateTime.parse(set.date))),
                    onTap: () => _showExerciseListDialog(set),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _renameExerciseSet(set),
                        ),
                        Icon(Icons.drag_handle),
                      ],
                    ),
                  ),
                );
              },
              onReorder: _onReorder,
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
