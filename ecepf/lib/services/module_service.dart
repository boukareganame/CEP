import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/module.dart';

class ModuleService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/';

  static Future<List<Module>> getModules() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/modules'));
    if (response.statusCode == 200) {
      List<dynamic> modulesJson = json.decode(response.body);
      return modulesJson.map((json) => Module.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des modules');
    }
  }

  static Future<Module> addModule(String title, String description) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/modulescreate/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'titre': title,
        'description': description,
      }),
    );
    if (response.statusCode == 201) {
      return Module.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erreur lors de l\'ajout du module');
    }
  }
}