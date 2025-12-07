import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class PaymentSuccessPage extends StatelessWidget {
  final String coursId;
  final String matiere;
  final int montant;
  final String pdfPayantUrl;

  const PaymentSuccessPage({
    super.key,
    required this.coursId,
    required this.matiere,
    required this.montant,
    required this.pdfPayantUrl,
  });

  // 🔥 Enregistrer l'achat + mettre à jour le cours
  Future<void> saveAchat() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 🟢 1) Enregistrer l'achat
    await FirebaseFirestore.instance.collection("achat").add({
      "cours_id": coursId,
      "user_id": user.uid,
      "montant": montant,
      "statut": "payé",
      "date": Timestamp.now(),
    });

    // 🟢 2) Trouver le cours dans Firestore par titre et MAJ payant = oui
    final snap = await FirebaseFirestore.instance
        .collection("cours")
        .where("titre", isEqualTo: coursId)
        .limit(1)
        .get();

    if (snap.docs.isNotEmpty) {
      await snap.docs.first.reference.update({"payant": "oui"});
      print("🔥 Champ 'payant' mis à jour pour le cours : $coursId");
    } else {
      print("❌ Aucun cours trouvé avec le titre : $coursId");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Paiement réussi")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 80),
            SizedBox(height: 20),
            Text(
              "Le paiement a été effectué avec succès !",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () { Navigator.popUntil(context, (route) => route.isFirst); },
              child: Text("Retour à l'accueil"),
            )
          ],
        ),
      ),
    );
  }
}
