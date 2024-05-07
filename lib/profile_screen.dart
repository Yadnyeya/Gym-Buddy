import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _bodyFatController = TextEditingController();
  bool _isEditing = false;
  String _sex = 'Male';
  String _fitnessGoal = 'Maintain';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('userName') ?? '';
      _ageController.text = (prefs.getInt('age') ?? 0).toString();
      _weightController.text = (prefs.getDouble('weight') ?? 0.0).toString();
      _heightController.text = (prefs.getDouble('height') ?? 0.0).toString();
      _bodyFatController.text = (prefs.getDouble('bodyFat') ?? 0.0).toString();
      _sex = prefs.getString('sex') ?? 'Male';
      _fitnessGoal = prefs.getString('fitnessGoal') ?? 'Maintain';
    });
  }

  _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text);
      await prefs.setInt('age', int.tryParse(_ageController.text) ?? 0);
      await prefs.setDouble('weight', double.tryParse(_weightController.text) ?? 0.0);
      await prefs.setDouble('height', double.tryParse(_heightController.text) ?? 0.0);
      await prefs.setDouble('bodyFat', double.tryParse(_bodyFatController.text) ?? 0.0);
      await prefs.setString('sex', _sex);
      await prefs.setString('fitnessGoal', _fitnessGoal);
      _loadProfile();
      setState(() {
        _isEditing = false;  // Switch back to view mode after saving
      });
    }
  }

  _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                _toggleEdit();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _isEditing ? _buildEditForm() : _buildProfileView(),
      ),
    );
  }

  Widget _buildProfileView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileDetail('Name: ${_nameController.text}', Icons.account_circle_outlined),
          _buildProfileDetail('Age: ${_ageController.text}', Icons.calendar_today),
          _buildProfileDetail('Weight: ${_weightController.text} kg', Icons.monitor_weight),
          _buildProfileDetail('Height: ${_heightController.text} cm', Icons.height),
          _buildProfileDetail('Body Fat: ${_bodyFatController.text} %', Icons.fitness_center),
          _buildProfileDetail('Sex: $_sex', Icons.transgender),
          _buildProfileDetail('Fitness Goal: $_fitnessGoal', Icons.flag),
        ],
      ),
    );
  }

  Widget _buildProfileDetail(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          SizedBox(width: 10),
          Text(text, style: TextStyle(color: Colors.white, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          TextFormField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Age'),
          ),
          TextFormField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Weight (kg)'),
          ),
          TextFormField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Height (cm)'),
          ),
          TextFormField(
            controller: _bodyFatController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Body Fat (%)'),
          ),
          DropdownButtonFormField(
            value: _sex,
            items: ['Male', 'Female', 'Other'].map((String value) {
              return DropdownMenuItem(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _sex = newValue!;
              });
            },
            decoration: InputDecoration(labelText: 'Sex'),
          ),
          DropdownButtonFormField(
            value: _fitnessGoal,
            items: ['Maintain', 'Lose Weight', 'Gain Muscle'].map((String value) {
              return DropdownMenuItem(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _fitnessGoal = newValue!;
              });
            },
            decoration: InputDecoration(labelText: 'Fitness Goal'),
          ),
        ],
      ),
    );
  }
}
