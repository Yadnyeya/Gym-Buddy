import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gym_buddy/main.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();

  Future<void> _register() async {
  if (_formKey.currentState!.validate()) {
    try {
      // Create the user with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(), password: _passwordController.text.trim());
      User? user = userCredential.user;
      if (user != null) {
        // Set the username as a custom claim or use a cloud function to store in Firestore
        await user.updateDisplayName(_usernameController.text.trim());
        user.reload();
        Fluttertoast.showToast(msg: "Registration Successful");

        // Navigate to HomePage and select the WorkoutScreen tab
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(initialTab: NavigationTab.workout))
        );
      }
    } catch (e) {
      print(e); // Print error message
      Fluttertoast.showToast(msg: "Failed to register: ${e.toString()}");
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: "Username"),
              validator: (value) => value!.isEmpty ? "Please enter a username" : null,
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
              validator: (value) => value!.isEmpty ? "Please enter an email" : null,
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
              validator: (value) => value!.length < 6 ? "Password must be at least 6 characters" : null,
            ),
            ElevatedButton(
              onPressed: _register,
              child: Text("Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}
