import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class HealthScreen extends StatefulWidget {
  @override
  _HealthScreenState createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  String _birthdate = '';
  String _sex = '';
  String _height = '';
  String _weight = '';
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _fetchHealthDetails();
  }

  void _fetchHealthDetails() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('clients')
          .doc(user.uid)
          .get();
      setState(() {
        _birthdate = userDoc.data()?['birthdate'] ?? '';
        _sex = userDoc.data()?['sex'] ?? '';
        _height = userDoc.data()?['height'] ?? '';
        _weight = userDoc.data()?['weight'] ?? '';
      });
    }
  }

  void _updateHealthDetails(String field, String value) async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _isUpdating = true;
      });
      await FirebaseFirestore.instance
          .collection('clients')
          .doc(user.uid)
          .update({
        field: value,
      });
      setState(() {
        _isUpdating = false;
        if (field == 'birthdate') _birthdate = value;
        if (field == 'sex') _sex = value;
        if (field == 'height') _height = value;
        if (field == 'weight') _weight = value;
      });
    }
  }

  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          child: Column(
            children: [
              Text('Select Birthdate', style: TextStyle(fontSize: 18)),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: DateTime.now(),
                  onDateTimeChanged: (DateTime newDateTime) {
                    _updateHealthDetails('birthdate',
                        '${newDateTime.month}/${newDateTime.day}/${newDateTime.year}');
                  },
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Done',
                    style: TextStyle(fontSize: 18, color: Colors.blue)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSexPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          child: Column(
            children: [
              Text('Select Sex', style: TextStyle(fontSize: 18)),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32,
                  onSelectedItemChanged: (int index) {
                    List<String> options = [
                      'Not set',
                      'Male',
                      'Female',
                      'Other'
                    ];
                    _updateHealthDetails('sex', options[index]);
                  },
                  children: [
                    Text('Not set'),
                    Text('Male'),
                    Text('Female'),
                    Text('Other'),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Done',
                    style: TextStyle(fontSize: 18, color: Colors.blue)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHeightPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        int selectedFeet = 0;
        int selectedInches = 0;

        return Container(
          height: 250,
          child: Column(
            children: [
              Text('Select Height', style: TextStyle(fontSize: 18)),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 32,
                        onSelectedItemChanged: (int index) {
                          selectedFeet = index + 1;
                        },
                        children:
                            List.generate(8, (index) => Text('${index + 1}\'')),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 32,
                        onSelectedItemChanged: (int index) {
                          selectedInches = index;
                        },
                        children: List.generate(12, (index) => Text('$index"')),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _height = '$selectedFeet\' $selectedInches"';
                    _updateHealthDetails('height', _height);
                  });
                  Navigator.pop(context);
                },
                child: Text('Done',
                    style: TextStyle(fontSize: 18, color: Colors.blue)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWeightPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          child: Column(
            children: [
              Text('Select Weight', style: TextStyle(fontSize: 18)),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32,
                  onSelectedItemChanged: (int index) {
                    int weight = index + 100;
                    _updateHealthDetails('weight', '$weight lbs');
                  },
                  children:
                      List.generate(201, (index) => Text('${index + 100} lbs')),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Done',
                    style: TextStyle(fontSize: 18, color: Colors.blue)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6279E4),
        title: Text('Health Details'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(32.0),
            children: [
              Text(
                'Personalize Fitness and Health',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'This info ensures fitness and health data are as accurate as possible. These details are not shared with anyone.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: Text('Birthdate'),
                      trailing:
                          Text(_birthdate.isEmpty ? 'Not set' : _birthdate),
                      onTap: _showDatePicker,
                    ),
                    ListTile(
                      title: Text('Sex'),
                      trailing: Text(_sex.isEmpty ? 'Not set' : _sex),
                      onTap: _showSexPicker,
                    ),
                    ListTile(
                      title: Text('Height'),
                      trailing: Text(_height.isEmpty ? 'Not set' : _height),
                      onTap: _showHeightPicker,
                    ),
                    ListTile(
                      title: Text('Weight'),
                      trailing: Text(_weight.isEmpty ? 'Not set' : _weight),
                      onTap: _showWeightPicker,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 100),
              SizedBox(
                width: double.infinity, // Make the button take full width
                height: 60, // Set the height of the button
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Details updated successfully'),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Set the border radius
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isUpdating)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
