import 'package:flutter/material.dart';

class ExerciseCard extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final VoidCallback onDelete;

  ExerciseCard({required this.exercise, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.assignment, color: Colors.blue),
        title: Text(exercise["title"], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(exercise["subject"]),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
