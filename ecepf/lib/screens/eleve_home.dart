import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importez SharedPreferences
import '../../main.dart'; // Importez main.dart pour la navigation vers la page de connexion

class EleveHome extends StatefulWidget {
  @override
  _EleveHomeState createState() => _EleveHomeState();
}

class _EleveHomeState extends State<EleveHome> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Vous pouvez charger des données ici si nécessaire
  }

  @override
  void dispose() {
    // Nettoyage si nécessaire
    super.dispose();
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Widgets d'affichage
  Widget _buildCoursesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
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
        children: [
          _buildExerciseCard(
              "Mathématiques", "Exercice 1", Icons.assignment_turned_in),
          _buildExerciseCard(
              "Physique", "Exercice 2", Icons.assignment_turned_in),
          _buildExerciseCard(
              "Informatique", "Exercice 3", Icons.assignment_turned_in),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text("Progression générale",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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

  Widget _getBodyWidget() {
    switch (_selectedIndex) {
      case 0:
        return _buildCoursesTab();
      case 1:
        return _buildExercisesTab();
      case 2:
        return _buildProgressTab();
      default:
        return _buildCoursesTab(); // Par défaut
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accueil Élève"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.book),
              title: Text('Cours'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment),
              title: Text('Exercices'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.show_chart),
              title: Text('Progression'),
              selected: _selectedIndex == 2,
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Déconnexion'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _getBodyWidget(),
    );
  }
}