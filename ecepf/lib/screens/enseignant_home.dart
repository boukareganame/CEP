import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';
import '../services/cours_service.dart';
import 'course_card.dart';
import 'exercice_card.dart';
import 'student_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class EnseignantHome extends StatefulWidget {
  @override
  _EnseignantHomeState createState() => _EnseignantHomeState();
}

class _EnseignantHomeState extends State<EnseignantHome> {
  // Variables
  List<dynamic> _courses =[];
  List<dynamic> _exercices =[];
  List<dynamic> _students =[];
  List<Map<String, dynamic>> _modules =[];
  TextEditingController _titreController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _exerciseTitleController = TextEditingController();
  TextEditingController _exerciseDescriptionController =
      TextEditingController();
  int? _selectedModuleId;
  File? _videoFile;
  File? _imageFile;
  File? _audioFile;
  File? _pdfFile;
  final ImagePicker _picker = ImagePicker();

  int _selectedIndex = 0; // Pour la navigation

  // Fonctions d'initialisation
  @override
  void initState() {
    super.initState();
    _loadData();
    _loadModules();
  }

  Future<void> _loadData() async {
    try {
      _courses = await CoursService.getCours();
      _exercices = await UserService.getTeacherExercises();
      _students = await UserService.getTeacherStudents();
      setState(() {});
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
    }
  }

  Future<void> _loadModules() async {
    try {
      List<dynamic> modulesDynamic = await CoursService.getModules();
      _modules = modulesDynamic.cast<Map<String, dynamic>>().toList();
    } catch (e) {
      print('Erreur lors du chargement des modules: $e');
    }
  }

  // Fonctions de gestion des cours
  Future<void> _addCourse() async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text("Ajouter un cours"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titreController,
                      decoration: const InputDecoration(labelText: "Titre"),
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: "Description"),
                    ),
                    DropdownButtonFormField<int>(
                      value: _selectedModuleId,
                      items: _modules.map((module) {
                        return DropdownMenuItem<int>(
                          value: module['id'],
                          child: Text(module['titre']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedModuleId = value;
                        });
                      },
                      decoration: const InputDecoration(labelText: "Module"),
                    ),
                    ElevatedButton(
                      onPressed: () => _pickFile(), // Utilisation de _pickFile
                      child: Text('Charger un fichier'),
                    ),
                    // ... (aperçu ou indicateur du fichier sélectionné)
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Annuler"),
                ),
                TextButton(
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    int? enseignantId = prefs.getInt('userId');
                    if (enseignantId != null && _selectedModuleId != null) {
                      try {
                        await CoursService.addCourseWithFiles(
                          _titreController.text,
                          _descriptionController.text,
                          enseignantId,
                          _selectedModuleId!,
                          _videoFile,
                          _imageFile,
                          _audioFile,
                          _pdfFile,
                        );
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
                      print("Erreur : ID de l'enseignant ou module non trouvé.");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                              'Erreur : ID de l\'enseignant ou module non trouvé.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Ajouter"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      PlatformFile file = result.files.first;
      String extension = file.extension?.toLowerCase() ?? '';

      setState(() {
        if (extension == 'mp4' || extension == 'avi' || extension == 'mov') {
          _videoFile = File(file.path!);
        } else if (extension == 'jpg' || extension == 'jpeg' || extension == 'png') {
          _imageFile = File(file.path!);
        } else if (extension == 'mp3' || extension == 'wav') {
          _audioFile = File(file.path!);
        } else if (extension == 'pdf') {
          _pdfFile = File(file.path!);
        } else {
          // Gérer les autres types de fichiers ou afficher un message d'erreur
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Type de fichier non pris en charge.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }

  Future<void> _deleteCourse(int courseId) async {
    try {
      await CoursService.deleteCourse(courseId);
      _loadData();
    } catch (e) {
      print('Erreur lors de la suppression du cours: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression du cours: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteExercise(int exerciseId) async {
    try {
      await UserService.deleteExercise(exerciseId);
      _loadData(); // Recharger les données après la suppression
    } catch (e) {
      print('Erreur lors de la suppression de l\'exercice: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression de l\'exercice: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token'); // Supprimer le token
    Navigator.pushReplacementNamed(
        context, '/login'); // Rediriger vers la page de connexion
  }

  // Fonctions de gestion des exercices
  Future<void> _addExercise() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ajouter un exercice"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _exerciseTitleController,
                  decoration: const InputDecoration(labelText: "Titre"),
                ),
                TextField(
                  controller: _exerciseDescriptionController,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () async {
                // Logique pour ajouter l'exercice (appeler le service, etc.)
                // ...
                Navigator.pop(context);
                _loadData(); // Recharger les données
              },
              child: const Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }

  // Widgets d'affichage
  Widget _buildCourseList() {
    return ListView.builder(
      itemCount: _courses.length,
      itemBuilder: (context, index) {
        return CourseCard(
          course: _courses[index],
          onDelete: () => _deleteCourse(_courses[index]['id']),
        );
      },
    );
  }

  Widget _buildExerciseList() {
    return ListView.builder(
      itemCount: _exercices.length,
      itemBuilder: (context, index) {
        return ExerciceCard(
          exercice: _exercices[index],
          onDelete: () => _deleteExercise(_exercices[index]['id']),
        );
      },
    );
  }

  Widget _buildStudentList() {
    return ListView.builder(
      itemCount: _students.length,
      itemBuilder: (context, index) {
        return StudentCard(student: _students[index]);
      },
    );
  }

  // Construction de l'interface
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord de l\'enseignant'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.class_),
              title: Text('Cours'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context); // Ferme le drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment),
              title: Text('Exercices'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Élèves'),
              selected: _selectedIndex == 2,
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Déconnexion'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _getBodyWidget(),
      floatingActionButton: _getFAB(),
    );
  }

  Widget _getBodyWidget() {
    switch (_selectedIndex) {
      case 0:
        return _buildCourseList();
      case 1:
        return _buildExerciseList();
      case 2:
        return _buildStudentList();
      default:
        return _buildCourseList(); // Par défaut, afficher les cours
    }
  }

  Widget? _getFAB() {
    if (_selectedIndex == 1) {
      return FloatingActionButton(
        onPressed: _addExercise,
        child: const Icon(Icons.add),
      );
    }
    return FloatingActionButton(
      onPressed: _addCourse,
      child: const Icon(Icons.add),
    );
  }
}