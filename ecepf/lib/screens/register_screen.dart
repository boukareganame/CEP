import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'admin/admin_home.dart';
import 'eleve_home.dart';
import 'enseignant_home.dart';
import 'parent_home.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  String? selectedRole;
  String? errorMessage;
  bool isLoading = false;
  bool isRegistered = false;

  void _register() async {
    if (!_formKey.currentState!.validate() || selectedRole == null) return;

    setState(() => isLoading = true);
    String email = emailController.text;
    String password = passwordController.text;
    String name = nameController.text;

    bool success = await AuthService.register(name, email, password, selectedRole!);

    setState(() {
      isLoading = false;
      if (success) {
        isRegistered = true;
      } else {
        errorMessage = "Échec de l'inscription. Veuillez réessayer.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: isRegistered
                        ? _showWelcomeBadge() // Affiche le badge si inscrit
                        : _registerForm(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Formulaire d'inscription
  Widget _registerForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Inscription",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
        SizedBox(height: 20),
        TextFormField(
          controller: nameController,
          decoration: _inputDecoration("Nom", Icons.person),
          validator: (value) =>
              value!.isEmpty ? "Veuillez entrer votre nom" : null,
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: emailController,
          decoration: _inputDecoration("Email", Icons.email),
          validator: (value) =>
              value!.isEmpty ? "Veuillez entrer un email" : null,
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: passwordController,
          obscureText: true,
          decoration: _inputDecoration("Mot de passe", Icons.lock),
          validator: (value) =>
              value!.length < 6 ? "Mot de passe trop court" : null,
        ),
        SizedBox(height: 15),
        DropdownButtonFormField<String>(
          value: selectedRole,
          decoration: _inputDecoration("Rôle", Icons.school),
          items: ["eleve", "enseignant", "parent"].map((role) {
            return DropdownMenuItem(value: role, child: Text(role));
          }).toList(),
          onChanged: (value) => setState(() => selectedRole = value),
          validator: (value) =>
              value == null ? "Veuillez sélectionner un rôle" : null,
        ),
        SizedBox(height: 15),
        if (errorMessage != null)
          Text(errorMessage!,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        SizedBox(height: 15),
        ElevatedButton(
          onPressed: isLoading ? null : _register,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            backgroundColor: Colors.blue.shade700,
          ),
          child: isLoading
              ? CircularProgressIndicator(color: Colors.white)
              : Text("S'inscrire", style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
        SizedBox(height: 10),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/login'),
          child: Text("Déjà inscrit ? Connexion",
              style: TextStyle(color: Colors.green.shade700)),
        ),
      ],
    );
  }
  
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.purple.shade700),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  // Badge de bienvenue
  Widget _showWelcomeBadge() {
    return Column(
      children: [
        Icon(Icons.verified, color: Colors.green, size: 80),
        SizedBox(height: 15),
        Text(
          "Bienvenue, $selectedRole ! 🎉",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Votre compte a été créé avec succès.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Redirection basée sur le rôle
            Widget destination;
            switch (selectedRole) {
              case 'admin':
                destination = AdminHome();
                break;
              case 'eleve':
                destination = EleveHome();
                break;
              case 'enseignant':
                destination = EnseignantHome();
                break;
              case 'parent':
                destination = ParentHome();
                break;
              default:
                destination = LoginScreen(); // Rôle inconnu, retour à la connexion
            }

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => destination,
              ),
            );
          },
          child: Text("Continuer"),
        ),
      ],
    );
  }

}
