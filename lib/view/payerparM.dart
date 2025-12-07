import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PayerParM extends StatelessWidget {
  final String matiereId;     // 🔥 ID Firestore du document matiere
  final String matiereTitre;  // 🔥 titre de la matière
  final int prix;             // 🔥 prix numérique

  const PayerParM({
    super.key,
    required this.matiereId,
    required this.matiereTitre,
    required this.prix,
  });

  // ✅ 1) Enregistrer l'abonnement dans Firestore
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

  // ✅ 2) Mettre la matière en payant = oui
  Future<void> updateMatierePayant() async {
    final snap = await FirebaseFirestore.instance
        .collection("matiere")
        .doc(matiereId)
        .get();

    if (snap.exists) {
      await snap.reference.update({"payant": "oui"});
      print("🔥 Matière mise à jour : payant = oui");
    } else {
      print("❌ Matière non trouvée : $matiereId");
    }
  }

  // ✅ 3) Mettre tous les cours de cette matière en payant = oui
  Future<void> updateCoursDeLaMatiere() async {
    final QuerySnapshot snap = await FirebaseFirestore.instance
        .collection("cours")
        .where("matiere", isEqualTo: matiereTitre)
        .get();

    for (var doc in snap.docs) {
      await doc.reference.update({"payant": "oui"});
    }

    print("🔥 Tous les cours de la matière '$matiereTitre' sont maintenant payants !");
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

                // 🟢 1) Enregistrer l’abonnement
                await saveAbonnement();

                // 🟢 2) Mettre la matière en payant
                await updateMatierePayant();

                // 🟢 3) Mettre tous les cours de cette matière en payant
                await updateCoursDeLaMatiere();

                // 🟢 4) Retour à l’accueil
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
