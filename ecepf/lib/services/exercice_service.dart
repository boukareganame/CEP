static Future<void> addExercise(String subject, String title) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.post(
      Uri.parse('${baseUrl}teacher/exercises/add/'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'subject': subject, 'title': title}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add exercise');
    }
  }

  static Future<void> deleteExercise(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.delete(
      Uri.parse('${baseUrl}teacher/exercises/$id/delete/'),
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete exercise');
    }
  }
}