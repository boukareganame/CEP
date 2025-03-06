import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importez shared_preferences

class ParentHome extends StatefulWidget {
  @override
  _ParentHomeState createState() => _ParentHomeState();
}

class _ParentHomeState extends State<ParentHome> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Fonction de déconnexion
  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Supprimez le token
    await prefs.remove('role'); //supprimez le role.
    Navigator.pushReplacementNamed(context, '/login'); // Redirigez vers la page de connexion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accueil Parent"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context), // Appelez la fonction de déconnexion
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Elèves"),
            Tab(text: "Progression"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Center(child: Text("Liste d'élèves")),
          Center(child: Text("Suivi de la progression")),
        ],
      ),
    );
  }
}
