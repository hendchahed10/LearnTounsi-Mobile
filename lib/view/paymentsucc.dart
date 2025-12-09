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

  Future<void> saveAchat() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection("achat").add({
      "cours_id": coursId,
      "user_id": user.uid,
      "montant": montant,
      "statut": "payé",
      "date": Timestamp.now(),
    });


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
              onPressed: () async {
                await saveAchat();

                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text("Retour à l'accueil"),
            )
          ],
        ),
      ),
    );
  }
}
