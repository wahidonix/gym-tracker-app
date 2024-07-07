import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  double? _height;
  double? _targetWeight;
  bool _isGainWeight = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profile = await _databaseHelper.getUserProfile();
    if (profile.isNotEmpty) {
      setState(() {
        _height = profile['height'];
        _targetWeight = profile['target_weight'];
        _isGainWeight = profile['is_gain_weight'] == 1;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: Text('Your Profile')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
                initialValue: _height?.toString() ?? '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your height';
                  }
                  return null;
                },
                onSaved: (value) => _height = double.parse(value!),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Target Weight (kg)'),
                keyboardType: TextInputType.number,
                initialValue: _targetWeight?.toString() ?? '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your target weight';
                  }
                  return null;
                },
                onSaved: (value) => _targetWeight = double.parse(value!),
              ),
              SizedBox(height: 16),
              SwitchListTile(
                title: Text('Weight Goal'),
                subtitle: Text(_isGainWeight ? 'Gain Weight' : 'Lose Weight'),
                value: _isGainWeight,
                onChanged: (value) {
                  setState(() {
                    _isGainWeight = value;
                  });
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    await _databaseHelper.updateUserProfile(
                        _height!, _targetWeight!, _isGainWeight);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Profile updated successfully')),
                    );
                  }
                },
                child: Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
