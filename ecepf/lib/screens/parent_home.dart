import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importez shared_preferences
import '../../main.dart'; // Importez main.dart pour la navigation vers la page de connexion

class ParentHome extends StatefulWidget {
  @override
  _ParentHomeState createState() => _ParentHomeState();
}

class _ParentHomeState extends State<ParentHome> {
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

  // Fonction de déconnexion
  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Supprimez le token
    await prefs.remove('role'); // supprimez le role.
    Navigator.pushReplacementNamed(context, '/login'); // Redirigez vers la page de connexion
  }

  // Widgets d'affichage
  Widget _buildElevesTab() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(child: Text("Liste d'élèves")),
    );
  }

  Widget _buildProgressionTab() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(child: Text("Suivi de la progression")),
    );
  }

  Widget _getBodyWidget() {
    switch (_selectedIndex) {
      case 0:
        return _buildElevesTab();
      case 1:
        return _buildProgressionTab();
      default:
        return _buildElevesTab(); // Par défaut
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accueil Parent"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
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
              leading: Icon(Icons.people),
              title: Text('Élèves'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.show_chart),
              title: Text('Progression'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
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