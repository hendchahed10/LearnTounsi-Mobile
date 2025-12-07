import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'paymentsucc.dart';

class PaymentPage extends StatefulWidget {
  final String paymentUrl;
  final String token;
  final String courseId;
  final int price;

  // ➕ CHAMPS SUPPLÉMENTAIRES
  final String description;
  final String image;

  const PaymentPage({
    super.key,
    required this.paymentUrl,
    required this.token,
    required this.courseId,
    required this.price,
    required this.description,
    required this.image,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    print("🚀 Paymee URL chargée : ${widget.paymentUrl}");

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final url = request.url;

            print("🌐 Navigation : $url");

            // 🎉 Paiement réussi
            if (url.contains("payment_token") && url.contains("transaction")) {
              print("🎉 Paiement détecté comme RÉUSSI !");

              savePaymentStatus("PAID");
              sendPaymentEmail();

              // 🔥 Aller vers PaymentSuccessPage AVEC les données nécessaires
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentSuccessPage(
                    coursId: widget.courseId,
                    matiere: widget.description,
                    montant: widget.price ?? 0,
                    pdfPayantUrl: widget.image,
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
        .collection("users")
        .doc(user.uid)
        .collection("achats")
        .doc(widget.courseId)
        .set({
      "courseId": widget.courseId,
      "titre": widget.courseId,
      "description": widget.description,
      "image": widget.image,
      "price": widget.price?? 0,
      "email": user.email,
      "userId": user.uid,
      "status": status,
      "date": Timestamp.now(),
    });

    print("📌 Paiement enregistré Firestore : $status");
  }

  // 💌 ENVOI EMAIL AU PROFESSEUR
  Future<void> sendPaymentEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");

    await http.post(
      url,
      headers: {
        "origin": "http://localhost",
        "Content-Type": "application/json",
      },
      body: json.encode({
        "service_id": "service_4cj6xkf",
        "template_id": "template_7qcih0v",
        "user_id": "6bOSYXQfmZKTRwLE3",
        "template_params": {
          "nom": user.displayName ?? "Utilisateur",
          "email": user.email,
          "cours": widget.courseId,
          "prix": widget.price,
          "description": widget.description,
          "destinataire": "kalilos122@gmail.com",
        }
      }),
    );

    print("📧 Email envoyé au professeur !");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paiement Paymee")),
      body: WebViewWidget(controller: controller),
    );
  }
}
