import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cours.dart';

class CoursService {
  final String baseUrl = "http://127.0.0.1:8000/api/";

  Future<List<Cours>> getCours() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((e) => Cours.fromJson(e)).toList();
    } else {
      throw Exception("Erreur lors du chargement des cours");
    }
  }

  static Future<void> addCourse(String titre, String description, int enseignantId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/teacher/courses/add/'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'titre': titre, 'description': description, 'enseignant': enseignantId}), // Modification ici
    );

    if (response.statusCode != 201) {
      print("response status code: ${response.statusCode}");
      print("response body: ${response.body}");
      throw Exception('Failed to add course');
    }
  }


  static Future<void> deleteCourse(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.delete(
      Uri.parse('http://127.0.0.1:8000/api/teacher/courses/$id/delete/'),
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete course');
    }
  }
}
