// course_list_screen.dart
import 'package:flutter/material.dart';
import 'cours_service.dart';
import 'cours_detail_screen.dart';

class CourseList extends StatefulWidget {
  @override
  _CourseListState createState() => _CourseListState();
}

class _CourseListState extends State<CourseList> {
  late Future<List<dynamic>> _courses;

  @override
  void initState() {
    super.initState();
    _courses = CoursService.getCours();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cours')),
      body: FutureBuilder<List<dynamic>>(
        future: _courses,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final course = snapshot.data![index];
                return ListTile(
                  title: Text(course['titre']),
                  subtitle: Text(course['description']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CoursDetailScreen(courseId: course['id']),
                      ),
                    );
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
