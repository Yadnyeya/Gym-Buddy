import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UnitsScreen extends StatefulWidget {
  @override
  _UnitsScreenState createState() => _UnitsScreenState();
}

class _UnitsScreenState extends State<UnitsScreen> {
  String _selectedEnergyUnit = 'Kilocalories';
  String _selectedPoolLengthUnit = 'Metres';
  String _selectedCyclingUnit = 'Kilometres';
  String _selectedWalkingRunningUnit = 'Kilometres';

  @override
  void initState() {
    super.initState();
    _fetchUnits();
  }

  void _fetchUnits() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('clients')
          .doc(user.uid)
          .get();
      setState(() {
        _selectedEnergyUnit = userDoc.data()?['energy_unit'] ?? 'Kilocalories';
        _selectedPoolLengthUnit =
            userDoc.data()?['pool_length_unit'] ?? 'Metres';
        _selectedCyclingUnit = userDoc.data()?['cycling_unit'] ?? 'Kilometres';
        _selectedWalkingRunningUnit =
            userDoc.data()?['walking_running_unit'] ?? 'Kilometres';
      });
    }
  }

  void _updateUnit(String unitType, String unitValue) async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('clients')
          .doc(user.uid)
          .update({
        unitType: unitValue,
      });
    }
  }

  Widget _buildUnitOption(String title, String currentUnit, String unitType) {
    return ListTile(
      title: Text(title, style: TextStyle(color: Colors.white)),
      trailing: currentUnit == title
          ? Icon(Icons.check, color: Color(0xFF6279E4))
          : null,
      onTap: () {
        setState(() {
          switch (unitType) {
            case 'energy_unit':
              _selectedEnergyUnit = title;
              break;
            case 'pool_length_unit':
              _selectedPoolLengthUnit = title;
              break;
            case 'cycling_unit':
              _selectedCyclingUnit = title;
              break;
            case 'walking_running_unit':
              _selectedWalkingRunningUnit = title;
              break;
          }
          _updateUnit(unitType, title);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6279E4),
        title: Text('Units of Measure'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection('ENERGY UNITS', [
            _buildUnitOption('Calories', _selectedEnergyUnit, 'energy_unit'),
            _buildUnitOption(
                'Kilocalories', _selectedEnergyUnit, 'energy_unit'),
            _buildUnitOption('Kilojoules', _selectedEnergyUnit, 'energy_unit'),
          ]),
          _buildSection('POOL LENGTH UNITS', [
            _buildUnitOption(
                'Yards', _selectedPoolLengthUnit, 'pool_length_unit'),
            _buildUnitOption(
                'Metres', _selectedPoolLengthUnit, 'pool_length_unit'),
          ]),
          _buildSection('CYCLING WORKOUTS', [
            _buildUnitOption('Miles', _selectedCyclingUnit, 'cycling_unit'),
            _buildUnitOption(
                'Kilometres', _selectedCyclingUnit, 'cycling_unit'),
          ]),
          _buildSection('WALKING AND RUNNING WORKOUTS', [
            _buildUnitOption(
                'Miles', _selectedWalkingRunningUnit, 'walking_running_unit'),
            _buildUnitOption('Kilometres', _selectedWalkingRunningUnit,
                'walking_running_unit'),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            title,
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          color: const Color.fromARGB(255, 12, 12, 12),
          child: Column(
            children: options,
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
