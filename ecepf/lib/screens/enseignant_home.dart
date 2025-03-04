import 'package:flutter/material.dart';

class EnseignantHome extends StatefulWidget {
  @override
  _EnseignantHomeState createState() => _EnseignantHomeState();
}

class _EnseignantHomeState extends State<EnseignantHome> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: Text("Accueil Enseignant"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Cours"),
            Tab(text: "Élèves"),
            Tab(text: "Progression"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(child: Text("Gérer les cours")),
          Center(child: Text("Liste des élèves")),
          Center(child: Text("Suivi de la progression")),
        ],
      ),
    );
  }
}
