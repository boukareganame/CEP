import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cours.dart';
import 'dart:io';

class CoursService {
  final String baseUrl = "http://127.0.0.1:8000/api/";

  static Future<List<dynamic>> getCours() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/cours/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load courses');
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

  static Future<void> addCourseWithFiles(
      String titre,
      String description,
      int enseignantId,
      int moduleId,
      File? videoFile,
      File? imageFile,
      File? audioFile,
      File? pdfFile,
      ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var request = http.MultipartRequest(
        'POST', Uri.parse('http://127.0.0.1:8000/api/teacher/courses/add/'));

    request.headers['Authorization'] = 'Token $token';

    request.fields['titre'] = titre;
    request.fields['description'] = description;
    request.fields['enseignant'] = enseignantId.toString();
    request.fields['module'] = moduleId.toString();

    if (videoFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'video_url', videoFile.path));
    }
    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'image_url', imageFile.path));
    }
    if (audioFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'audio_url', audioFile.path));
    }
    if (pdfFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'pdf_url', pdfFile.path));
    }

    var response = await request.send();

    if (response.statusCode != 201) {
      var responseBody = await response.stream.bytesToString();
      print("response status code: ${response.statusCode}");
      print("response body: ${responseBody}");
      throw Exception('Failed to add course with files');
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

  static Future<Map<String, dynamic>> getCourseDetails(int courseId) async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/cours/$courseId/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load course details');
    }
  }

  static Future<List<dynamic>> getModules() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/modules/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load modules');
    }
  }

  static Future<Map<String, dynamic>> getModuleDetails(int moduleId) async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/modules/$moduleId/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load module details');
    }
  }

  static Future<Map<String, dynamic>> getLessonDetails(int lessonId) async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/lecons/$lessonId/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load lesson details');
    }
  }
  static Future<Map<String, dynamic>> getQuizDetails(int quizId) async {
  final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/quiz/$quizId/'));
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load quiz details');
  }
}

static Future<Map<String, dynamic>> getQuestionDetails(int questionId) async {
  final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/questions/$questionId/'));
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load question details');
  }
}

static Future<void> uploadLesson(
      String titre,
      String description,
      int moduleId,
      File? videoFile,
      File? imageFile,
      File? audioFile,
      String? texte, // Texte de la leçon
      ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var request = http.MultipartRequest(
        'POST', Uri.parse('http://127.0.0.1:8000/api/lecons/'));

    request.headers['Authorization'] = 'Token $token';

    // Ajout des champs texte
    request.fields['titre'] = titre;
    request.fields['description'] = description;
    request.fields['module'] = moduleId.toString(); // Assurez vous que l'API attend un module ID
    if (texte != null) {
      request.fields['texte'] = texte;
    }

    // Ajout des fichiers
    if (videoFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'video_url', videoFile.path));
    }
    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'image_url', imageFile.path));
    }
    if (audioFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'audio_url', audioFile.path));
    }

    var response = await request.send();

    if (response.statusCode != 201) {
      var responseBody = await response.stream.bytesToString();
      print("response status code: ${response.statusCode}");
      print("response body: ${responseBody}");
      throw Exception('Failed to upload lesson');
    }
  }
}
