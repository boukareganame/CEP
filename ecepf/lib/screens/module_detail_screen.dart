// module_detail_screen.dart
import 'package:flutter/material.dart';
import 'cours_service.dart';
import 'lesson_detail_screen.dart';

class ModuleDetailScreen extends StatefulWidget {
  final int moduleId;

  ModuleDetailScreen({required this.moduleId});

  @override
  _ModuleDetailScreenState createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleDetailScreen> {
  late Future<Map<String, dynamic>> _module;

  @override
  void initState() {
    super.initState();
    _module = CourseService.getModuleDetails(widget.moduleId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Détails du module')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _module,
        builder: (context, snapshot) {
          // ... (affichage des détails du module et des leçons) ...
        },
      ),
    );
  }
}