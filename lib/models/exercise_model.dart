class ExerciseSet {
  final int? id;
  final String name;
  final String date;
  final List<Exercise> exercises;

  ExerciseSet({
    this.id,
    required this.name,
    required this.date,
    required this.exercises,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date,
    };
  }

  factory ExerciseSet.fromMap(Map<String, dynamic> map) {
    return ExerciseSet(
      id: map['id'],
      name: map['name'],
      date: map['date'],
      exercises: [],
    );
  }
}

class Exercise {
  final int? id;
  final int setId;
  final String name;
  final double weight;
  final int reps;
  final int negativeReps;

  Exercise({
    this.id,
    required this.setId,
    required this.name,
    required this.weight,
    required this.reps,
    required this.negativeReps,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as int?,
      setId: map['set_id'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      reps: map['reps'] as int? ?? 0,
      negativeReps: map['negative_reps'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'set_id': setId,
      'name': name,
      'weight': weight,
      'reps': reps,
      'negative_reps': negativeReps,
    };
  }
}
