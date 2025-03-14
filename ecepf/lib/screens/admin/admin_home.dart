import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/user_service.dart';
import '../../services/module_service.dart';
import '../../models/module.dart';

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final String baseUrl = "http://127.0.0.1:8000/api";
  String username = "Admin";
  List<Map<String, dynamic>> users = [];
  bool _isLoading = true;
  int _selectedIndex = 0;
  List<Module> _modules = [];
  List<dynamic> cours = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadUsers();
    _loadModules();
    _loadCours(null);
  }

  void _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("email") ?? "Admin";
    });
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
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
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCours(int? moduleId) async {
    setState(() {
      _isLoading = true;
    });
    String url = '$baseUrl/cours/';
    if (moduleId != null) {
      url += '?module=$moduleId';
    }
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      print('Le token est bien recupéré: $token');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          },
      );
      if (response.statusCode == 200) {
        setState(() {
          cours = json.decode(response.body);
        });
      } else {
        // Gestion de l'erreur spécifique pour les cours
        print('Erreur lors du chargement des cours: ${response.statusCode} - ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement des cours: ${response.statusCode}')),
        );
        throw Exception('Erreur lors du chargement des cours: ${response.statusCode}');
      }
    } catch (e) {
      // Gestion de l'erreur générale
      print('Erreur lors du chargement des cours: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement des cours: $e')),
      );
      throw Exception('Erreur lors du chargement des cours: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _editUser(int index) async {
    TextEditingController emailController =
        TextEditingController(text: users[index]["email"]);
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

  void _addModule() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter un module'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await ModuleService.addModule(
                    titleController.text,
                    descriptionController.text,
                  );
                  _loadModules();
                  Navigator.pop(context);
                } catch (e) {
                  print('Erreur lors de l\'ajout du module: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur d\'ajout: $e')),
                  );
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadModules() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _modules = await ModuleService.getModules();
    } catch (e) {
      print('Erreur lors du chargement des modules: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildDashboard() {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Bienvenue, $username!",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildCard("Utilisateurs", Icons.people, Colors.blue, () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                }),
                _buildCard("Statistiques", Icons.bar_chart, Colors.green, () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                }),
                _buildCard("Support", Icons.help_outline, Colors.red, () {
                  setState(() {
                    _selectedIndex = 3;
                  });
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    List<Map<String, dynamic>> filteredUsers = users.where((user) =>
        user['email'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
        user['role'].toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Rechercher un utilisateur',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: Text(filteredUsers[index]["email"]!,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Rôle : ${filteredUsers[index]["role"]}"),
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
        ),
      ],
    );
  }

  Widget _buildCoursFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () => _loadCours(null),
            child: const Text('Tout'),
          ),
          const SizedBox(width: 8),
          ..._modules.map((module) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ElevatedButton(
                onPressed: () => _loadCours(module.id),
                child: Text(module.title),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCoursList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildCoursFilterBar(),
        Expanded(
          child: ListView.builder(
            itemCount: cours.length,
            itemBuilder: (context, index) {
              final course = cours[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const Icon(Icons.book, color: Colors.blue),
                  title: Text(course['titre'] ?? 'Titre inconnu',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(course['description'] ?? 'Description inconnue'),
                  // Ajoutez ici d'autres informations sur le cours
                ),
              );
            },
          ),
        ),
      ],
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
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _getBodyWidget() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildUsersList();
      case 2:
        return _buildStatistics();
      case 3:
        return _buildSupport();
      case 4:
        return _buildModulesList();
      case 5:
        return _buildCoursList();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildModulesList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: Colors.grey[300],
      child: ListView.builder(
        itemCount: _modules.length,
        itemBuilder: (context, index) {
          Module module = _modules[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: const Icon(Icons.folder, color: Colors.orange),
              title: Text(module.title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(module.description),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.green),
                    onPressed: () {
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tableau de bord Admin"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepOrange,
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
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Utilisateurs'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.bar_chart),
              title: Text('Statistiques'),
              selected: _selectedIndex == 2,
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('Support'),
              selected: _selectedIndex == 3,
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.class_),
              title: Text('Modules'),
              selected: _selectedIndex == 4,
              onTap: () {
                setState(() {
                  _selectedIndex = 4;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.book),
              title: Text('Cours'),
              selected: _selectedIndex == 5,
              onTap: () {
                setState(() {
                  _selectedIndex = 5;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsScreen()),
                );
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
      floatingActionButton: _selectedIndex == 4
          ? FloatingActionButton(
            onPressed: () {
              _addModule();
            },
            child: const Icon(Icons.add),
          )
          : null,
    );
  }
}