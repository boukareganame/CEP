import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/user_service.dart';

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> with SingleTickerProviderStateMixin {
  String username = "Admin";
  late TabController _tabController;
  List<Map<String, dynamic>> users = [];
  bool _isLoading = true; // Ajout d'une variable de chargement

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _tabController = TabController(length: 4, vsync: this);
    _loadUsers();
  }

  void _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username") ?? "Admin";
    });
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/');
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true; // Début du chargement
    });
    try {
      users = await UserService.getUsers();
    } catch (e) {
      print('Erreur lors du chargement des utilisateurs: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Fin du chargement
      });
    }
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
        title: const Text("Tableau de bord Admin"),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Dashboard"),
            Tab(text: "Utilisateurs"),
            Tab(text: "Statistiques"),
            Tab(text: "Support"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Afficher le chargement
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDashboard(),
                _buildUsersList(),
                _buildStatistics(),
                _buildSupport(),
              ],
            ),
    );
  }

  Widget _buildDashboard() {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Bienvenue, $username!", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildCard("Utilisateurs", Icons.people, Colors.blue, () {
                  _tabController.animateTo(1);
                }),
                _buildCard("Statistiques", Icons.bar_chart, Colors.green, () {
                  _tabController.animateTo(2);
                }),
                _buildCard("Support", Icons.help_outline, Colors.red, () {
                  _tabController.animateTo(3);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editUser(int index) async {
    TextEditingController emailController = TextEditingController(text: users[index]["email"]);
    String role = users[index]["role"];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modifier l'utilisateur"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              DropdownButtonFormField<String>(
                value: role,
                items: ["enseignant", "eleve", "parent", "admin"].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    role = newValue!;
                  });
                },
                decoration: const InputDecoration(labelText: "Rôle"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await UserService.updateUser(users[index]['id'], {
                    'email': emailController.text,
                    'role': role,
                  });
                  await _loadUsers();
                  Navigator.pop(context);
                } catch (e) {
                  print('Erreur lors de la mise à jour de l\'utilisateur: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur de mise à jour: $e')),
                  );
                }
              },
              child: const Text("Enregistrer"),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(int index) async {
    try {
      await UserService.deleteUser(users[index]['id']);
      await _loadUsers();
    } catch (e) {
      print('Erreur lors de la suppression de l\'utilisateur: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de suppression: $e')),
      );
    }
  }

  Widget _buildUsersList() {
    return Container(
      color: Colors.grey[200],
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: Text(users[index]["email"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Rôle : ${users[index]["role"]}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.green),
                    onPressed: () => _editUser(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteUser(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    return const Center(child: Text("Statistiques"));
  }

  Widget _buildSupport() {
    return const Center(child: Text("Support"));
  }
}
