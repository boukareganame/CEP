import 'package:flutter/material.dart';

class EleveHome extends StatefulWidget {
  @override
  _EleveHomeState createState() => _EleveHomeState();
}

class _EleveHomeState extends State<EleveHome> with SingleTickerProviderStateMixin {
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
        title: Text("Accueil Élève"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Cours"),
            Tab(text: "Exercices"),
            Tab(text: "Progression"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(child: Text("Liste des cours")),
          Center(child: Text("Liste des exercices")),
          Center(child: Text("Suivi de la progression")),
        ],
      ),
    );
  }
}
