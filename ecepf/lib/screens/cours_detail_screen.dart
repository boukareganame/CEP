// course_detail_screen.dart
import 'package:flutter/material.dart';
import 'cours_service.dart';
import 'module_detail_screen.dart';

class CoursDetailScreen extends StatefulWidget {
  final int courseId;

  CoursDetailScreen({required this.courseId});

  @override
  _CoursDetailScreenState createState() => _CoursDetailScreenState();
}

class _CoursDetailScreenState extends State<CoursDetailScreen> {
  late Future<Map<String, dynamic>> _course;

  @override
  void initState() {
    super.initState();
    _course = CoursService.getCourseDetails(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Détails du cours')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _course,
        builder: (context, snapshot) {
          // ... (affichage des détails du cours et des modules) ...
        },
      ),
    );
  }
}
