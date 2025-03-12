import 'package:flutter/material.dart';

class ExerciceCard extends StatelessWidget {
  final Map<String, dynamic> exercice;
  final VoidCallback onDelete;

  ExerciceCard({required this.exercice, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.assignment, color: Colors.blue),
        title: Text(exercice["title"], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(exercice["subject"]),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
