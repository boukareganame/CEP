import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> with SingleTickerProviderStateMixin {
  String username = "Admin";
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _tabController = TabController(length: 2, vsync: this);
  }

  // Charger le nom de l'admin depuis les préférences
  void _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username") ?? "Admin";
    });
  }

  // Déconnexion
  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/');
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
        title: Text("Tableau de bord Admin"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Dashboard"),
            Tab(text: "Utilisateurs"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboard(),
          _buildUsersList(),
        ],
      ),
    );
  }

  // 🏠 Tableau de bord Admin
  Widget _buildDashboard() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Bienvenue, $username!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildCard("Utilisateurs", Icons.people, Colors.blue, () {
                  _tabController.animateTo(1); // Aller à l'onglet "Utilisateurs"
                }),
                _buildCard("Statistiques", Icons.bar_chart, Colors.green, () {}),
                _buildCard("Paramètres", Icons.settings, Colors.orange, () {}),
                _buildCard("Support", Icons.help_outline, Colors.red, () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📋 Gestion des utilisateurs
  Widget _buildUsersList() {
    List<Map<String, String>> users = [
      {"nom": "Alice", "role": "Enseignant"},
      {"nom": "Bob", "role": "Parent"},
      {"nom": "Charlie", "role": "Élève"},
    ];

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 3,
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: Icon(Icons.person, color: Colors.blue),
            title: Text(users[index]["nom"]!, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Rôle : ${users[index]["role"]}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.edit, color: Colors.green), onPressed: () {}),
                IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () {}),
              ],
            ),
          ),
        );
      },
    );
  }

  // 📌 Widget pour chaque carte du tableau de bord
  Widget _buildCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
