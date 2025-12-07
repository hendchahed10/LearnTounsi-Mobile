import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/top_navbar.dart';
import '../widgets/Cappbar.dart';
class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final emailCtrl = TextEditingController();
  final messageCtrl = TextEditingController();

  bool loading = false;
  bool success = false;

  // ======== Formspree Request ========
  Future<void> sendMessage() async {
    setState(() => loading = true);

    final url = Uri.parse("https://formspree.io/f/xqaljdev");

    final response = await http.post(
      url,
      body: {
        "email": emailCtrl.text.trim(),
        "message": messageCtrl.text.trim(),
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        success = true;
        loading = false;
      });
    } else {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Erreur lors de l’envoi du message")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),

      body: Column(
        children: [
          const TopNavigationBar(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: success ? _buildSuccess() : _buildForm(),
            ),
          ),
        ],
      ),
    );
  }

  // ======================= SUCCESS MESSAGE =======================
  Widget _buildSuccess() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        width: 600,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              "🎉 Merci pour votre message !",
              style: TextStyle(
                fontSize: 26,
                color: Color(0xFF234138),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              "Nous vous répondrons dans les plus brefs délais.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC2A83E),
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 30),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "📚 Retour à l'accueil",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ======================= CONTACT FORM =======================
  Widget _buildForm() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "📧 Contactez-nous",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xFF234138),
              ),
            ),
            const SizedBox(height: 10),

            const Text(
              "Une question ? Un projet ? Écrivez-nous !",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),

            const SizedBox(height: 25),

            // ==== Email ====
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                labelText: "Adresse Email",
                labelStyle: const TextStyle(color: Color(0xFF234138)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 25),

            // ==== Message ====
            TextField(
              controller: messageCtrl,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: "Votre message",
                labelStyle: const TextStyle(color: Color(0xFF234138)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),

            // ==== SEND BUTTON ====
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC2A83E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: loading ? null : sendMessage,
                child: Text(
                  loading ? "Envoi en cours..." : "📨 Envoyer le message",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
