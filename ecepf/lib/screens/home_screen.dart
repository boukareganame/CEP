import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../widgets/category_card.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Category>> futureCategories;
  Map<String, dynamic>? userProfile;

  @override
  void initState() {
    super.initState();
    futureCategories = ApiService.fetchCategories();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    var profile = await AuthService.getUserProfile();
    setState(() {
      userProfile = profile;
    });
  }

  void logout(BuildContext context) async {
    await AuthService.logout();
    Navigator.pushReplacementNamed(context, '/');
  }

  String _getBadgeText(String role) {
    switch (role) {
      case 'eleve':
        return "🎓 Élève";
      case 'enseignant':
        return "👨‍🏫 Enseignant";
      case 'parent':
        return "👨‍👩‍👦 Parent";
      case 'admin':
        return "⚙️ Admin";
      default:
        return "👤 Utilisateur";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil'),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: () => logout(context)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userProfile != null) ...[
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("👤 ${userProfile!['username']}", style: TextStyle(fontSize: 20)),
                    Text("📧 ${userProfile!['email']}", style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getBadgeText(userProfile!['role']),
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              if (userProfile!['role'] == 'admin')
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/gestion_utilisateurs');
                    },
                    child: Text("Gérer les utilisateurs"),
                  ),
                ),
              SizedBox(height: 20),
            ] else ...[
              Center(child: CircularProgressIndicator()),
              SizedBox(height: 20),
            ],
            Text(
              'Pour chaque élève, chaque classe. Des résultats réels.',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  CategoryCard(title: 'Maths', icon: Icons.calculate, route: '/maths'),
                  CategoryCard(title: 'Informatique', icon: Icons.computer, route: '/informatique'),
                  CategoryCard(title: 'Arts', icon: Icons.palette, route: '/arts'),
                  CategoryCard(title: 'Ressources pédagogiques', icon: Icons.menu_book, route: '/ressources'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
