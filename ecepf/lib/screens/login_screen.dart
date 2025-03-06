import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importez shared_preferences
import '../services/auth_service.dart';
import '../main.dart'; // Importez le fichier main.dart pour la fonction getHomePage
import 'eleve_home.dart';
import 'parent_home.dart';
import 'enseignant_home.dart';
import './admin/admin_home.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? errorMessage;
  bool isLoading = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    String email = emailController.text;
    String password = passwordController.text;

    try {
      Map<String, dynamic>? responseData = await AuthService.login(email, password);
      if (responseData != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', responseData['token']);
        await prefs.setString('role', responseData['role']);

        // Redirection basée sur le rôle
        String role = responseData['role'];
        Widget destination;
        switch (role) {
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
      } else {
        setState(() {
          errorMessage = "Email ou mot de passe incorrect.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Une erreur s'est produite lors de la connexion.";
        isLoading = false;
      });
      print("Erreur lors de la connexion: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.purple.shade600],
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Connexion",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
                          ),
                        ),
                        SizedBox(height: 20),
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
                        if (errorMessage != null)
                          Text(errorMessage!,
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            backgroundColor: Colors.purple.shade700,
                          ),
                          child: isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text("Se connecter", style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/register'),
                          child: Text("Créer un compte",
                              style: TextStyle(color: Colors.blue.shade700)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
}