import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'quiz.dart';
class PageCoursPayant extends StatefulWidget {
  final String matiere;
  final String cours;
  final int prix;
  final String? pdfPayantUrl;

  const PageCoursPayant({
    super.key,
    required this.matiere,
    required this.cours,
    required this.prix,
    required this.pdfPayantUrl,
  });

  @override
  State<PageCoursPayant> createState() => _PageCoursPayantState();
}

class _PageCoursPayantState extends State<PageCoursPayant> {
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            setState(() => isLoading = false);
          },
        ),
      );

    // Charger le PDF payant Cloudinary
    if (widget.pdfPayantUrl != null && widget.pdfPayantUrl!.isNotEmpty) {
      _controller.loadRequest(Uri.parse(widget.pdfPayantUrl!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cours),
        backgroundColor: const Color(0xFF234138),
      ),

      body: Column(
        children: [
          // 👉 Affichage PDF payant
          Expanded(
            child: widget.pdfPayantUrl == null || widget.pdfPayantUrl!.isEmpty
                ? const Center(
              child: Text(
                "PDF complet introuvable",
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            )
                : Stack(
              children: [
                WebViewWidget(controller: _controller),

                if (isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFC2A83E),
                    ),
                  ),
              ],
            ),
          ),

          // 👉 Bouton Quiz
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF234138),
                padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizPage(
                      cours: widget.cours,
                      matiere: widget.matiere,
                    ),
                  ),
                );
              },
              child: const Text(
                "Commencer le quiz",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


