import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/paymee_service.dart';
import 'payment_page.dart';
import 'page_cours_payant.dart';

class PageCours extends StatefulWidget {
  final String matiere;
  final String cours;

  const PageCours({
    super.key,
    required this.matiere,
    required this.cours,
  });

  @override
  State<PageCours> createState() => _PageCoursState();
}

class _PageCoursState extends State<PageCours> {
  String? previewUrl;
  String? pdfPayantUrl;
  int prix = 0;
  bool isPayant = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadCourse();
  }

  Future<void> loadCourse() async {
    final snap = await FirebaseFirestore.instance
        .collection("cours")
        .where("titre", isEqualTo: widget.cours)
        .where("matiere", isEqualTo: widget.matiere)       // 🔥 assurance de trouver le bon cours
        .limit(1)
        .get();

    if (snap.docs.isEmpty) {
      setState(() => loading = false);
      return;
    }

    final doc = snap.docs.first;
    final data = doc.data() as Map<String, dynamic>;

    final payantValue = data["payant"].toString().trim().toLowerCase();
    isPayant = payantValue == "oui" || payantValue == "true";

    prix = data["prix"] is int
        ? data["prix"]
        : int.tryParse(data["prix"].toString()) ?? 0;

    previewUrl = data["pdf_gratuit"];
    pdfPayantUrl = data["pdf_payant"];

    setState(() => loading = false);
  }

  Future<void> startPayment() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez vous connecter.")),
      );
      return;
    }

    final safeOrderId =
    widget.cours.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');

    final result = await PaymeeService.initiatePayment(
      amount: prix.toDouble(),
      note: "Achat PDF ${widget.cours}",
      firstName: "Asma",
      lastName: "BenAhmed",
      email: user.email ?? "",
      phone: "11111111",
      orderId: safeOrderId,
    );

    if (result == null || result["status"] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur Paymee : ${result?["message"]}")),
      );
      return;
    }

    final paymentUrl = result["data"]["payment_url"];
    final token = result["data"]["token"];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          paymentUrl: paymentUrl,
          token: token,
          courseId: widget.cours,
          price: prix,
          description: "PDF complet : ${widget.cours}",
          image: "pdf.png",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cours),
        backgroundColor: const Color(0xFF234138),
      ),
      body: Column(
        children: [
          Expanded(
            child: previewUrl == null
                ? const Center(child: Text("PDF gratuit non disponible"))
                : WebViewWidget(
              controller: WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..loadRequest(Uri.parse(previewUrl!)),
            ),
          ),

          // 🔥 SI payant = non → bouton acheter
          if (!isPayant)
            Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC2A83E),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: startPayment,
                child: Text(
                  "Acheter le PDF complet – $prix dt",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),

          // 🔥 SI payant = oui → bouton accéder
          if (isPayant)
            Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PageCoursPayant(
                        matiere: widget.matiere,
                        cours: widget.cours,
                        prix: prix,
                        pdfPayantUrl: pdfPayantUrl,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Accéder au PDF complet",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
