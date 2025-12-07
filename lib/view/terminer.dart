import 'package:flutter/material.dart';
import 'quiz.dart';

class TerminerPage extends StatelessWidget {
  final String matiere;
  final String cours;

  const TerminerPage({required this.matiere, required this.cours});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Préparation du Quiz")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Tu es prêt pour l'évaluation !"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizPage(
                      matiere: matiere,
                      cours: cours,
                    ),
                  ),
                );
              },
              child: Text("Commencer le Quiz"),
            )
          ],
        ),
      ),
    );
  }
}
