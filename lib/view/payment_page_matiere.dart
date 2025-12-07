import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'payerparM.dart';

class PaymentPageMatiere extends StatefulWidget {
  final String paymentUrl;
  final String token;
  final String matiereId;     // ID Firestore de la matière
  final int prix;             // montant payé
  final String titreMatiere;  // titre
  final String image;         // image (inutile mais conservé pour compatibilité)

  const PaymentPageMatiere({
    super.key,
    required this.paymentUrl,
    required this.token,
    required this.matiereId,
    required this.prix,
    required this.titreMatiere,
    required this.image,
  });

  @override
  State<PaymentPageMatiere> createState() => _PaymentPageMatiereState();
}

class _PaymentPageMatiereState extends State<PaymentPageMatiere> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final url = request.url;
            print("🌐 Navigation : $url");

            // 🎉 Paiement réussi
            if (url.contains("payment_token") && url.contains("transaction")) {
              print("🎉 Paiement matière détecté comme RÉUSSI !");

              savePaymentStatus("PAID");
              sendPaymentEmail();

              // 🔥 Redirection vers PayerParM
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PayerParM(
                    matiereId: widget.matiereId,
                    matiereTitre: widget.titreMatiere,
                    prix: widget.prix,
                  ),
                ),
              );

              return NavigationDecision.prevent;
            }

            // ❌ Paiement annulé
            if (url.contains("paymee-cancel")) {
              savePaymentStatus("CANCELLED");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Paiement annulé ❌")),
              );
              Navigator.pop(context);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  // 📌 Enregistrer le paiement dans Firestore
  Future<void> savePaymentStatus(String status) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("abonnement")
        .add({
      "matiere_id": widget.matiereId,
      "user_id": user.uid,
      "montant": widget.prix,
      "statut": status,
      "date": Timestamp.now(),
    });

    print("📌 Paiement MATIÈRE enregistré Firestore : $status");
  }

  // 💌 Envoi email
  Future<void> sendPaymentEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");

    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "service_id": "service_4cj6xkf",
        "template_id": "template_7qcih0v",
        "user_id": "6bOSYXQfmZKTRwLE3",
        "template_params": {
          "nom": user.displayName ?? "Utilisateur",
          "email": user.email,
          "cours": widget.titreMatiere,
          "prix": widget.prix.toString(),
          "description": "Achat matière : ${widget.titreMatiere}",
          "destinataire": "kalilos122@gmail.com",
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paiement Paymee")),
      body: WebViewWidget(controller: controller),
    );
  }
}
