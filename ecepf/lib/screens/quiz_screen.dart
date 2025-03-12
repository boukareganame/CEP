// quiz_screen.dart (suite)
import 'package:flutter/material.dart';
import 'course_service.dart';

class QuizScreen extends StatefulWidget {
  final int quizId;

  QuizScreen({required this.quizId});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<Map<String, dynamic>> _quiz;
  Map<int, String> _selectedAnswers = {};
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _quiz = CourseService.getQuizDetails(widget.quizId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _quiz,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final quiz = snapshot.data!;
            final questions = quiz['questions'];
            return Column(
              children: [
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / questions.length,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          questions[_currentQuestionIndex]['texte'],
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        RadioListTile<String>(
                          title: Text(questions[_currentQuestionIndex]['reponse_1']),
                          value: questions[_currentQuestionIndex]['reponse_1'],
                          groupValue: _selectedAnswers[questions[_currentQuestionIndex]['id']],
                          onChanged: (value) {
                            setState(() {
                              _selectedAnswers[questions[_currentQuestionIndex]['id']] = value!;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: Text(questions[_currentQuestionIndex]['reponse_2']),
                          value: questions[_currentQuestionIndex]['reponse_2'],
                          groupValue: _selectedAnswers[questions[_currentQuestionIndex]['id']],
                          onChanged: (value) {
                            setState(() {
                              _selectedAnswers[questions[_currentQuestionIndex]['id']] = value!;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: Text(questions[_currentQuestionIndex]['reponse_3']),
                          value: questions[_currentQuestionIndex]['reponse_3'],
                          groupValue: _selectedAnswers[questions[_currentQuestionIndex]['id']],
                          onChanged: (value) {
                            setState(() {
                              _selectedAnswers[questions[_currentQuestionIndex]['id']] = value!;
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (_currentQuestionIndex > 0)
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _currentQuestionIndex--;
                                  });
                                },
                                child: Text('Précédent'),
                              ),
                            if (_currentQuestionIndex < questions.length - 1)
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _currentQuestionIndex++;
                                  });
                                },
                                child: Text('Suivant'),
                              ),
                            if (_currentQuestionIndex == questions.length - 1)
                              ElevatedButton(
                                onPressed: () {
                                  _checkAnswers(quiz);
                                },
                                child: Text('Soumettre'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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

  void _checkAnswers(Map<String, dynamic> quiz) {
    int score = 0;
    for (var question in quiz['questions']) {
      if (_selectedAnswers[question['id']] == question['reponse_correcte']) {
        score++;
      }
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Résultats du Quiz'),
        content: Text('Votre score est de $score/${quiz['questions'].length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}