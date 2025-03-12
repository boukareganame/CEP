// upload_lesson_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart'; // Import file_picker
import '../services/cours_service.dart';

class UploadLessonScreen extends StatefulWidget {
  @override
  _UploadLessonScreenState createState() => _UploadLessonScreenState();
}

class _UploadLessonScreenState extends State<UploadLessonScreen> {
  File? _videoFile;
  File? _imageFile;
  File? _audioFile;
  final ImagePicker _picker = ImagePicker();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _moduleIdController = TextEditingController();
  final _texteController = TextEditingController();

  Future<void> _pickFile(ImageSource source, String type) async {
    if (type == 'video') {
      final XFile? pickedFile = await _picker.pickVideo(source: source);
      if (pickedFile != null) {
        setState(() {
          _videoFile = File(pickedFile.path);
        });
      }
    } else if (type == 'image') {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } else if (type == 'audio') {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _audioFile = File(result.files.single.path!);
        });
      }
    }
}

  Future<void> _uploadLesson() async {
    try {
      await CoursService.uploadLesson(
        _titreController.text,
        _descriptionController.text,
        int.parse(_moduleIdController.text),
        _videoFile,
        _imageFile,
        _audioFile,
        _texteController.text,
      );
      print('Lesson uploaded successfully!');
      Navigator.pop(context);
    } catch (e) {
      print('Failed to upload lesson: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement de la leçon: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Charger une Leçon')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(controller: _titreController, decoration: InputDecoration(labelText: 'Titre')),
            TextField(controller: _descriptionController, decoration: InputDecoration(labelText: 'Description')),
            TextField(controller: _moduleIdController, decoration: InputDecoration(labelText: 'Module ID')),
            TextField(controller: _texteController, decoration: InputDecoration(labelText: 'Texte')),
            ElevatedButton(onPressed: () => _pickFile(ImageSource.gallery, 'video'), child: Text('Sélectionner une Vidéo')),
            ElevatedButton(onPressed: () => _pickFile(ImageSource.gallery, 'image'), child: Text('Sélectionner une Image')),
            ElevatedButton(onPressed: () => _pickFile(ImageSource.gallery, 'audio'), child: Text('Sélectionner un Audio')),
            ElevatedButton(onPressed: _uploadLesson, child: Text('Charger la Leçon')),
          ],
        ),
      ),
    );
  }
}