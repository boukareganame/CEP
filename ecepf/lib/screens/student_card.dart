import 'package:flutter/material.dart';

class StudentCard extends StatelessWidget {
  final Map<String, dynamic> student;

  StudentCard({required this.student});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.person, color: Colors.orange),
        title: Text(student["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(student["email"]),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}