import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/admin/admin_home.dart';
import 'screens/eleve_home.dart';
import 'screens/enseignant_home.dart';
import 'screens/parent_home.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? token = await AuthService.getToken();
  String? role = await AuthService.getRole(); // Récupérer le rôle

  Widget initialScreen;
  if (token != null && role != null) {
    switch (role) {
      case 'admin':
        initialScreen = AdminHome();
        break;
      case 'eleve':
        initialScreen = EleveHome();
        break;
      case 'enseignant':
        initialScreen = EnseignantHome();
        break;
      case 'parent':
        initialScreen = ParentHome();
        break;
      default:
        initialScreen = LoginScreen(); // Rediriger vers la connexion si le rôle est inconnu
    }
  } else {
    initialScreen = LoginScreen(); // Rediriger vers la connexion si aucun token
  }

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  MyApp({required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Éducation CM2',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: initialScreen, // Utiliser l'écran initial déterminé
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
      },
    );
  }
}