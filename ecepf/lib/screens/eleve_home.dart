import 'package:flutter/material.dart';

class EleveHome extends StatefulWidget {
  @override
  _EleveHomeState createState() => _EleveHomeState();
}

class _EleveHomeState extends State<EleveHome> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accueil Élève"),
        backgroundColor: Colors.indigo,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.book), text: "Cours"),
            Tab(icon: Icon(Icons.assignment), text: "Exercices"),
            Tab(icon: Icon(Icons.show_chart), text: "Progression"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCoursesTab(),
          _buildExercisesTab(),
          _buildProgressTab(),
        ],
      ),
    );
  }

  Widget _buildCoursesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [ // Suppression du const ici
          _buildCourseCard("Mathématiques", "Algèbre linéaire", Icons.calculate),
          _buildCourseCard("Physique", "Mécanique quantique", Icons.lightbulb),
          _buildCourseCard("Informatique", "Structures de données", Icons.code),
        ],
      ),
    );
  }

  Widget _buildExercisesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [ // Suppression du const ici
          _buildExerciseCard("Mathématiques", "Exercice 1", Icons.assignment_turned_in),
          _buildExerciseCard("Physique", "Exercice 2", Icons.assignment_turned_in),
          _buildExerciseCard("Informatique", "Exercice 3", Icons.assignment_turned_in),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [ // Suppression du const ici
          const Text("Progression générale", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const LinearProgressIndicator(value: 0.7),
          const SizedBox(height: 20),
          const Text("Cours complétés: 70%"),
        ],
      ),
    );
  }

  Widget _buildCourseCard(String subject, String title, IconData icon) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.indigo),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subject),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildExerciseCard(String subject, String title, IconData icon) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subject),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}