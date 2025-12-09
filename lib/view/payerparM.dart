import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PayerParM extends StatelessWidget {
  final String matiereId;     // ID Firestore de la matière
  final String matiereTitre;  // Titre de la matière
  final int prix;             // Prix d'achat

  const PayerParM({
    super.key,
    required this.matiereId,
    required this.matiereTitre,
    required this.prix,
  });

  Future<void> saveAbonnement() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection("abonnement").add({
      "user_id": user.uid,
      "matiere_id": matiereId,
      "montant": prix,
      "date": Timestamp.now(),
    });

    print("🎉 Abonnement enregistré !");
  }

  Future<void> saveCoursAchetes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final QuerySnapshot snap = await FirebaseFirestore.instance
        .collection("cours")
        .where("matiere", isEqualTo: matiereTitre)
        .get();

    for (var doc in snap.docs) {
      await FirebaseFirestore.instance.collection("achat").add({
        "user_id": user.uid,
        "cours_id": doc.id,
        "date": Timestamp.now(),
        "montant": prix,
        "statut": "payé",
      });
    }

    print("🛒 Tous les cours de la matière '$matiereTitre' ont été ajoutés à 'achat'.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paiement réussi")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text(
              "Matière achetée avec succès !",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                await saveAbonnement();

                await saveCoursAchetes();


                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text("Retour à l'accueil"),
            ),
          ],
        ),
      ),
    );
  }
}
