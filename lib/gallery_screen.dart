import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);

        // Upload to Firebase
        await uploadFile(imageFile);

        // Add to the list of images to display
        setState(() {
          _images.add(imageFile);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> uploadFile(File image) async {
    String fileName = Path.basename(image.path);
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('images/${DateTime.now().millisecondsSinceEpoch}_$fileName');

    try {
      await storageReference.putFile(image);
      print('File Uploaded');
    } catch (e) {
      print('Error occurred while uploading to Firebase: $e');
    }
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemCount: _images.length,
      itemBuilder: (BuildContext context, int index) {
        return Image.file(_images[index], fit: BoxFit.cover);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery Screen'),
      ),
      body: _images.isEmpty ? Center(child: Text("No images selected")) : _buildImageGrid(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () => _pickImage(ImageSource.camera),
            tooltip: 'Take a Picture',
            child: Icon(Icons.camera_alt),
          ),
          SizedBox(height: 20),
          FloatingActionButton(
            onPressed: () => _pickImage(ImageSource.gallery),
            tooltip: 'Pick Image from Gallery',
            child: Icon(Icons.photo_library),
          ),
        ],
      ),
    );
  }
}
