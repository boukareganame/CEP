import 'package:flutter/material.dart';
import '../services/auth_service.dart';

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

  String email = emailController.text;
  String password = passwordController.text;

  bool success = await AuthService.login(email, password);
  if (success) {
    String? role = await AuthService.getUserRole();
    if (role == "eleve") {
      Navigator.pushReplacementNamed(context, '/eleveHome');
    } else if (role == "enseignant") {
      Navigator.pushReplacementNamed(context, '/enseignantHome');
    } else if (role == "parent") {
      Navigator.pushReplacementNamed(context, '/parentHome');
    } else {
      Navigator.pushReplacementNamed(context, '/adminHome');
    }
  } else {
    setState(() {
      errorMessage = "Email ou mot de passe incorrect";
    });
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

