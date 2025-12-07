import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentFormPage extends StatefulWidget {
  final String nom;
  final String email;
  final String courseName;
  final String price;

  const PaymentFormPage({
    super.key,
    required this.nom,
    required this.email,
    required this.courseName,
    required this.price,
  });

  @override
  State<PaymentFormPage> createState() => _PaymentFormPageState();
}

class _PaymentFormPageState extends State<PaymentFormPage> {
  bool sending = false;

  Future<void> sendEmail() async {
    setState(() => sending = true);

    final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");

    final response = await http.post(url,
        headers: {
          "origin": "http://localhost",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "service_id": "service_4cj6xkf",
          "template_id": "template_7qcih0v",
          "user_id": "6bOSYXQfmZKTRwLE3",
          "template_params": {
            "nom": widget.nom,
            "email": widget.email,
            "cours": widget.courseName,
            "prix": widget.price,
            "destinataire": "kalilos122@gmail.com"
          }
        }));

    setState(() => sending = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email envoyé au professeur ✔")));

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l’envoi ❌")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Achat confirmé")),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Paiement réussi 🎉",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            Text("Nom : ${widget.nom}"),
            Text("Email : ${widget.email}"),
            Text("Cours : ${widget.courseName}"),
            Text("Prix : ${widget.price} dt"),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: sending ? null : sendEmail,
              child: sending
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Envoyer au professeur"),
            ),
          ],
        ),
      ),
    );
  }
}
