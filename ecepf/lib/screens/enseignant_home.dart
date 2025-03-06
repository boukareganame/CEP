import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart'; // Assurez-vous d'avoir UserService
import '../services/cours_service.dart';
import 'course_card.dart';
import 'exercice_card.dart';
import 'student_card.dart';

class EnseignantHome extends StatefulWidget {
  @override
  _EnseignantHomeState createState() => _EnseignantHomeState();
}

class _EnseignantHomeState extends State<EnseignantHome> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _exercises = [];
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _courses = await UserService.getTeacherCourses();
      _exercises = await UserService.getTeacherExercises();
      //_students = await UserService.getTeacherStudents();
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addCourse() async {
  TextEditingController titreController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? enseignantId = prefs.getInt('userId');

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Ajouter un cours"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titreController, decoration: const InputDecoration(labelText: "Titre")),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: "Description")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          TextButton(
            onPressed: () async {
              if (enseignantId != null) {
                try {
                  await CoursService.addCourse(titreController.text, descriptionController.text, enseignantId);
                  _loadData();
                  Navigator.pop(context);
                } catch (e) {
                  print('Erreur lors de l\'ajout du cours: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de l\'ajout du cours: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                print("Erreur : ID de l'enseignant non trouvé dans SharedPreferences.");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Erreur : ID de l\'enseignant non trouvé. Veuillez vous reconnecter.'),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.pop(context); // Close the dialog
              }
            },
            child: const Text("Ajouter"),
          ),
        ],
      );
    },
  );
}

  void _removeCourse(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Supprimer le cours"),
          content: const Text("Êtes-vous sûr de vouloir supprimer ce cours ?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
            TextButton(
              onPressed: () async {
                try {
                  await CoursService.deleteCourse(id);
                  _loadData();
                  Navigator.pop(context);
                } catch (e) {
                  print('Erreur lors de la suppression du cours: $e');
                  // Gérez l'erreur
                }
              },
              child: const Text("Supprimer"),
            ),
          ],
        );
      },
    );
  }

void _editCourse(int index) {
  TextEditingController subjectController = TextEditingController(text: _courses[index]["subject"]);
  TextEditingController titleController = TextEditingController(text: _courses[index]["title"]);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Modifier le cours"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: subjectController, decoration: const InputDecoration(labelText: "Sujet")),
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Titre")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          TextButton(
            onPressed: () async {
              // Implémentez la logique pour mettre à jour un cours via l'API
              // ...
              _loadData();
              Navigator.pop(context);
            },
            child: const Text("Enregistrer"),
          ),
        ],
      );
    },
  );
}

  void _addExercise() {
    // Implémentez la logique pour ajouter un exercice via l'API
    // ...
    _loadData();
  }

  void _removeExercise(int index) {
    // Implémentez la logique pour supprimer un exercice via l'API
    // ...
    _loadData();
  }

  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accueil Enseignant"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.book), text: "Cours"),
            Tab(icon: Icon(Icons.assignment), text: "Exercices"),
            Tab(icon: Icon(Icons.people), text: "Élèves"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCoursesTab(),
                _buildExercisesTab(),
                _buildStudentsTab(),
              ],
            ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _addCourse,
              child: const Icon(Icons.add),
              backgroundColor: Colors.teal,
            )
          : _tabController.index == 1
              ? FloatingActionButton(
                  onPressed: _addExercise,
                  child: const Icon(Icons.add),
                  backgroundColor: Colors.teal,
                )
              : null,
    );
  }

  Widget _buildCoursesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          return CourseCard(
            course: _courses[index],
            onDelete: () => _removeCourse(index),
          );
        },
      ),
    );
  }

  Widget _buildExercisesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: _exercises.length,
        itemBuilder: (context, index) {
          return ExerciseCard(
            exercise: _exercises[index],
            onDelete: () => _removeExercise(index),
          );
        },
      ),
    );
  }

  Widget _buildStudentsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: _students.length,
        itemBuilder: (context, index) {
          return StudentCard(student: _students[index]);
        },
      ),
    );
  }
}