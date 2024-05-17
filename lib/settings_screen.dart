import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_buddy/goal_screen.dart';
import 'package:gym_buddy/units_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'health_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _username = 'User';
  String _email = 'email@example.com';
  String _profileImageUrl = '';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('clients')
          .doc(user.uid)
          .get();
      setState(() {
        _username = userDoc.data()?['username'] ?? 'User';
        _email = userDoc.data()?['email'] ?? 'email@example.com';
        _profileImageUrl = userDoc.data()?['profileImageUrl'] ?? '';
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await _uploadProfileImage(imageFile);
    }
  }

  Future<void> _uploadProfileImage(File imageFile) async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String fileName = 'profile_${user.uid}.jpg';
      Reference storageReference =
          FirebaseStorage.instance.ref().child('profile_images/$fileName');

      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('clients')
          .doc(user.uid)
          .update({'profileImageUrl': downloadUrl});

      setState(() {
        _profileImageUrl = downloadUrl;
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToHealthDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HealthScreen()),
    );
  }

  void _navigateToGoalScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GoalScreen()),
    );
  }

  void _navigateToUnitsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UnitsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6279E4),
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // User Information Card
          Card(
            child: ListTile(
              leading: GestureDetector(
                onTap: () => _showImageSourceActionSheet(context),
                child: CircleAvatar(
                  backgroundImage: _profileImageUrl.isNotEmpty
                      ? NetworkImage(_profileImageUrl)
                      : null,
                  child: _profileImageUrl.isEmpty ? Icon(Icons.person) : null,
                ),
              ),
              title: Text(_username),
              subtitle: Text(_email),
            ),
          ),
          SizedBox(height: 16),

          // Health Details, Change Move Goal, Units of Measure
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text('Health Details'),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 14.0,
                  ),
                  onTap: _navigateToHealthDetails,
                ),
                ListTile(
                  title: Text('Change Move Goal'),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 14.0,
                  ),
                  onTap: _navigateToGoalScreen,
                ),
                ListTile(
                  title: Text('Units of Measure'),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 14.0,
                  ),
                  onTap: _navigateToUnitsScreen,
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Notifications
          Card(
            child: ListTile(
              title: Text('Notifications'),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 14.0,
              ),
              onTap: () {},
            ),
          ),
          SizedBox(height: 16),

          // Redeem Gift Card or Code, Send Gift Card by Email
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text('Redeem Gift Card or Code'),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 14.0,
                  ),
                  onTap: () {},
                ),
                ListTile(
                  title: Text('Send Gift Card by Email'),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 14.0,
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Apple Fitness Privacy
          Card(
            child: ListTile(
              title: Text('Gym Buddy Fitness Privacy'),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 14.0,
              ),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
