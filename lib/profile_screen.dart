import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  _loadProfile() async {
    try {
      var userDocument = await FirebaseFirestore.instance.collection('users').doc('userProfile').get();
      var userData = userDocument.data();
      if (userData != null) {
        setState(() {
          _nameController.text = userData['userName'];
          _ageController.text = userData['age'].toString();
          _weightController.text = userData['weight'].toString();
          _heightController.text = userData['height'].toString();
          _bodyFatController.text = userData['bodyFat'].toString();
          // Assuming 'sex' and 'fitnessGoal' are also fields to update similarly
        });
      } else {
        print("No data available");
      }
    } catch (e) {
      print("Error loading profile: $e");
    }
  }


_saveProfile() async {
  print("Saving profile with data:");
  print("Name: ${_nameController.text}");
  print("Age: ${_ageController.text}");
  print("Weight: ${_weightController.text}");
  print("Height: ${_heightController.text}");
  print("Body Fat: ${_bodyFatController.text}");

  try {
    await FirebaseFirestore.instance.collection('users').doc('userProfile').set({
      'userName': _nameController.text,
      'age': int.parse(_ageController.text),
      'weight': double.parse(_weightController.text),
      'height': double.parse(_heightController.text),
      'bodyFat': double.parse(_bodyFatController.text),
      // Include 'sex' and 'fitnessGoal' if they are being edited as well
    });
    print("Profile saved successfully");
    _loadProfile();
  } catch (e) {
    print("Error saving profile: $e");
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
            onPressed: _toggleEdit,
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
          Text('Name: ${_nameController.text}'),
          Text('Age: ${_ageController.text}'),
          Text('Weight: ${_weightController.text} kg'),
          Text('Height: ${_heightController.text} cm'),
          Text('Body Fat: ${_bodyFatController.text} %'),
          // Add other fields similarly
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          TextFormField(controller: _nameController, decoration: InputDecoration(labelText: 'Name')),
          TextFormField(controller: _ageController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Age')),
          TextFormField(controller: _weightController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Weight (kg)')),
          TextFormField(controller: _heightController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Height (cm)')),
          TextFormField(controller: _bodyFatController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Body Fat (%)')),
          // Include DropdownButtonFormField for 'sex' and 'fitnessGoal'
        ],
      ),
    );
  }
}


