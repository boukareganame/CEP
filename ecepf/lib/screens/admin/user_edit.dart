import 'package:flutter/material.dart';

class UserEdit extends StatefulWidget {
  final Map<String, String> user;
  UserEdit({required this.user});

  @override
  _UserEditState createState() => _UserEditState();
}

class _UserEditState extends State<UserEdit> {
  late TextEditingController usernameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: widget.user['username']);
    emailController = TextEditingController(text: widget.user['email']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Modifier Utilisateur")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: usernameController, decoration: InputDecoration(labelText: "Nom")),
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {'username': usernameController.text, 'email': emailController.text});
              },
              child: Text("Enregistrer"),
            ),
          ],
        ),
      ),
    );
  }
}