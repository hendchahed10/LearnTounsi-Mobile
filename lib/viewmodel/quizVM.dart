import 'dart:convert';
import 'package:flutter/services.dart';

class QuizViewModel {
  List<dynamic> questions = [];
  int index = 0;
  List<int?> answers = [];
  bool finished = false;

  Future<void> loadQuiz(String matiere, String cours) async {
    // Charger le fichier JSON
    final data = await rootBundle.loadString('assets/data/allquiz.json');
    final jsonData = jsonDecode(data);

    // Récupérer les questions
    final quiz = jsonData[matiere]?[cours];

    if (quiz == null) {
      questions = [];
      return;
    }

    questions = quiz;
    answers = List<int?>.filled(questions.length, null);
  }

  void selectAnswer(int qIndex, int optionIndex) {
    answers[qIndex] = optionIndex;
  }

  void next() {
    if (index < questions.length - 1) index++;
  }

  void prev() {
    if (index > 0) index--;
  }

  void finish() {
    finished = true;
  }

  int get score {
    int s = 0;
    for (int i = 0; i < questions.length; i++) {
      if (answers[i] == questions[i]["correct"]) s++;
    }
    return s;
  }
}
