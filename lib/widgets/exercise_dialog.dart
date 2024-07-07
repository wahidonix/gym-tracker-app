import 'package:flutter/material.dart';
import 'package:gym_tracker/models/exercise_model.dart';

class ExerciseDialog extends StatefulWidget {
  final Exercise? exercise;

  ExerciseDialog({this.exercise});

  @override
  _ExerciseDialogState createState() => _ExerciseDialogState();
}

class _ExerciseDialogState extends State<ExerciseDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  late TextEditingController _negativeRepsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise?.name ?? '');
    _weightController =
        TextEditingController(text: widget.exercise?.weight.toString() ?? '');
    _repsController =
        TextEditingController(text: widget.exercise?.reps.toString() ?? '');
    _negativeRepsController = TextEditingController(
        text: widget.exercise?.negativeReps.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    _negativeRepsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.exercise == null ? 'Add Exercise' : 'Edit Exercise'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Exercise Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an exercise name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a weight';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _repsController,
                decoration: InputDecoration(labelText: 'Reps'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of reps';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _negativeRepsController,
                decoration: InputDecoration(labelText: 'Negative Reps'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of negative reps';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text('Save'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final exercise = Exercise(
                id: widget.exercise?.id,
                setId: widget.exercise?.setId ??
                    0, // You might need to adjust this
                name: _nameController.text,
                weight: double.parse(_weightController.text),
                reps: int.parse(_repsController.text),
                negativeReps: int.parse(_negativeRepsController.text),
              );
              Navigator.of(context).pop(exercise);
            }
          },
        ),
      ],
    );
  }
}
