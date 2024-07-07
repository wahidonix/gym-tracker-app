import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import 'package:intl/intl.dart';

class DailyLogScreen extends StatefulWidget {
  const DailyLogScreen({Key? key}) : super(key: key);

  @override
  _DailyLogScreenState createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  double _weight = 0;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daily Log')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  return null;
                },
                onSaved: (value) => _weight = double.parse(value!),
              ),
              ListTile(
                title: Text('Date'),
                subtitle: Text(DateFormat('MMMM d, y').format(_selectedDate)),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
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
                  }
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    await _databaseHelper.insertOrUpdateDailyLog(
                        _selectedDate.toLocal().toString().split(' ')[0],
                        _weight);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Daily log updated successfully')),
                    );
                    // Clear the form
                    _formKey.currentState!.reset();
                    setState(() {
                      _selectedDate = DateTime.now();
                    });
                  }
                },
                child: Text('Save Log'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
