import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../viewmodel/quizVM.dart';
import 'home.dart';
class QuizPage extends StatefulWidget {
  final String matiere;
  final String cours;

  const QuizPage({
    required this.matiere,
    required this.cours,
    super.key,
  });

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late QuizViewModel vm;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    vm = QuizViewModel();       // 🔥 Réinitialiser le ViewModel à chaque ouverture
    loadQuiz();
  }

  Future<void> loadQuiz() async {
    await vm.loadQuiz(widget.matiere, widget.cours);
    setState(() => loading = false);
  }

  // ⭐⭐⭐ ENREGISTRER SCORE DANS FIRESTORE
  Future<void> saveQuizScore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc =
      await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

      final userName = userDoc.data()?["prenom"] ?? "Utilisateur";

      await FirebaseFirestore.instance.collection("quiz").add({
        "email": user.email,
        "nomutilisateur": userName,
        "scores": "${vm.score} / ${vm.questions.length}",
        "matiere": widget.matiere,
        "titre": widget.cours,
        "date": Timestamp.now(),
        "user_id": user.uid,
      });

      print("🎉 Score enregistré !");
    } catch (e) {
      print("❌ Erreur Firestore : $e");
    }
  }

  // ⭐⭐⭐ ENREGISTRER COURS TERMINÉ
  Future<void> saveCoursTermine() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final String coursId =
    "${widget.matiere}_${widget.cours}".replaceAll(" ", "_");

    final ref = FirebaseFirestore.instance.collection("cours_termines");

    final snap = await ref
        .where("user_id", isEqualTo: user.uid)
        .where("cours_id", isEqualTo: coursId)
        .get();

    if (snap.docs.isNotEmpty) return;

    await ref.add({
      "user_id": user.uid,
      "cours_id": coursId,
      "titre": widget.cours,
      "matiere": widget.matiere,
      "date": Timestamp.now(),
    });

    print("📌 Cours terminé ajouté !");
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFC2A83E)),
        ),
      );
    }

    if (vm.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Quiz"),
          backgroundColor: Color(0xFF234138),
        ),
        body: Center(
          child: Text(
            "Aucun quiz disponible pour ce cours.",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    final question = vm.questions[vm.index];

    // ⭐⭐⭐ PAGE RÉSULTAT ⭐⭐⭐
    if (vm.finished) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Résultat"),
          backgroundColor: Color(0xFF234138),
        ),
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(30),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF234138), Color(0xFFC5E782)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Score : ${vm.score} / ${vm.questions.length}",
                style: const TextStyle(
                    fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC2A83E),
                  padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 26),
                ),
                onPressed: () async {
                  await saveQuizScore();     // sauvegarde score
                  await saveCoursTermine();  // sauvegarde cours terminé

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                        (route) => false,   // supprime toute la stack
                  );
                  // 🔥 Retour à l'accueil
                },
                child: const Text(
                  "Retour à l'accueil",
                  style: TextStyle(
                      fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ⭐⭐⭐ PAGE QUIZ ⭐⭐⭐
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.cours} — Question ${vm.index + 1}/${vm.questions.length}"),
        backgroundColor: Color(0xFF234138),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF234138), Color(0xFFC5E782), Color(0xFFD9C46F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // QUESTION
            Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                question["question"],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // OPTIONS
            Expanded(
              child: ListView.builder(
                itemCount: question["options"].length,
                itemBuilder: (context, i) {
                  final selected = vm.answers[vm.index] == i;

                  return GestureDetector(
                    onTap: () {
                      setState(() => vm.selectAnswer(vm.index, i));
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 14),
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: selected ? Color(0xFFC2A83E) : Colors.white,
                      ),
                      child: Text(
                        question["options"][i],
                        style: TextStyle(
                            fontSize: 16,
                            color: selected ? Colors.white : Colors.black),
                      ),
                    ),
                  );
                },
              ),
            ),

            // NAVIGATION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: vm.index == 0 ? null : () {
                    setState(vm.prev);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  child: Text("Précédent", style: TextStyle(color: Color(0xFF234138))),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      vm.index < vm.questions.length - 1
                          ? vm.next()
                          : vm.finish();  // 🔥 ici, maintenant ça fonctionne
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFC2A83E)),
                  child: Text(
                    vm.index < vm.questions.length - 1 ? "Suivant" : "Terminer",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
