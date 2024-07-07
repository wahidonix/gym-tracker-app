import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import 'package:intl/intl.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();

  double _height = 0;
  double _targetWeight = 0;
  bool _isGainWeight = false;
  DateTime? _startDate;
  int _daysTracking = 0;
  double _totalWeightChange = 0;

  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final profile = await _databaseHelper.getUserProfile();
    final logs = await _databaseHelper.getDailyLogs();
    if (profile.isNotEmpty) {
      setState(() {
        _height = profile['height'];
        _targetWeight = profile['target_weight'];
        _isGainWeight = profile['is_gain_weight'] == 1;
        _heightController.text = _height.toString();
        _targetWeightController.text = _targetWeight.toString();
      });
    }
    if (logs.isNotEmpty) {
      final firstLog = logs.first;
      final lastLog = logs.last;
      final firstDate = DateTime.parse(firstLog['date']);
      setState(() {
        _startDate = firstDate;
        _daysTracking = DateTime.now().difference(firstDate).inDays;
        _totalWeightChange = lastLog['weight'] - firstLog['weight'];
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _databaseHelper.updateUserProfile(
          _height, _targetWeight, _isGainWeight);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileSummaryCard(),
            SizedBox(height: 20),
            _buildEditProfileCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSummaryCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildInfoRow('Height', '$_height cm'),
            _buildInfoRow('Target Weight', '$_targetWeight kg'),
            _buildInfoRow(
                'Goal', _isGainWeight ? 'Gain Weight' : 'Lose Weight'),
            if (_startDate != null) ...[
              _buildInfoRow('Tracking Since',
                  DateFormat('MMMM d, y').format(_startDate!)),
              _buildInfoRow('Days Tracking', '$_daysTracking days'),
              _buildInfoRow('Total Weight Change',
                  '${_totalWeightChange.toStringAsFixed(1)} kg'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          Text(value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEditProfileCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(
                  labelText: 'Height (cm)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.number,
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
                controller: _targetWeightController,
                decoration: InputDecoration(
                  labelText: 'Target Weight (kg)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.number,
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
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  child: Text(
                    'Update Profile',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
