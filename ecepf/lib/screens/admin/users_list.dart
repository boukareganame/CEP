import 'package:flutter/material.dart';

class UsersList extends StatefulWidget {
  @override
  _UsersListState createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, String>> users = [
    {"name": "Alice", "role": "Enseignant"},
    {"name": "Bob", "role": "Élève"},
    {"name": "Charlie", "role": "Parent"},
    {"name": "David", "role": "Admin"},
  ];
  List<Map<String, String>> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    filteredUsers = users;
  }

  void filterUsers(String query) {
    setState(() {
      filteredUsers = users
          .where((user) => user["name"]!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gestion des Utilisateurs")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Rechercher un utilisateur",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: filterUsers,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredUsers[index]["name"]!),
                  subtitle: Text("Rôle: ${filteredUsers[index]["role"]!}"),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'Modifier') {
                        // Logique pour modifier
                      } else if (value == 'Supprimer') {
                        setState(() {
                          users.remove(filteredUsers[index]);
                          filterUsers(searchController.text);
                        });
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'Modifier', child: Text('Modifier')),
                      PopupMenuItem(value: 'Supprimer', child: Text('Supprimer')),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
