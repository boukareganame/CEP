import 'package:flutter/material.dart';
import '../services/cours_service.dart';
import '../models/cours.dart';

class CoursList extends StatefulWidget {
  @override
  _CoursListState createState() => _CoursListState();
}

class _CoursListState extends State<CoursList> {
  late Future<List<Cours>> _cours;

  @override
  void initState() {
    super.initState();
    _cours = CoursService().getCours();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Liste des Cours")),
      body: FutureBuilder<List<Cours>>(
        future: _cours,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text("Aucun cours disponible"));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Cours cours = snapshot.data![index];
              return ListTile(
                title: Text(cours.titre),
                subtitle: Text(cours.description),
              );
            },
          );
        },
      ),
    );
  }
}
