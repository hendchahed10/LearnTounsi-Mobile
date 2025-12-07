import 'package:flutter/material.dart';
import '../widgets/top_navbar.dart';
import '../widgets/Cappbar.dart';
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),

      body: Column(
        children: [
          const TopNavigationBar(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 30),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== TITLE =====
                      const Text(
                        "À propos de LearnTounsi",
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF234138)),
                      ),
                      const SizedBox(height: 12),

                      const Text(
                        "Découvrez notre plateforme éducative innovante...",
                        style:
                        TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                      const SizedBox(height: 40),

                      // ============ SECTION MISSION ============
                      buildSection(
                        title: "Notre Mission",
                        content:
                        "LearnTounsi est une plateforme éducative multi-plateforme (web + mobile)...",
                      ),

                      // ============ SECTION FONCTIONNALITÉS ============
                      const SizedBox(height: 20),
                      const Text(
                        "Fonctionnalités Principales",
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF234138)),
                      ),
                      const SizedBox(height: 20),

                      buildGrid([
                        buildFeature("📚", "Catalogue de cours complet"),
                        buildFeature("🎓", "Apprentissage progressif"),
                        buildFeature("📱", "Multi-plateforme"),
                        buildFeature("🏆", "Certification"),
                      ]),

                      const SizedBox(height: 30),

                      // ============ TECHNOLOGIES ============
                      const Text(
                        "Technologies Utilisées",
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF234138)),
                      ),
                      const SizedBox(height: 20),

                      buildGrid([
                        buildTech("⚛️", "React.js"),
                        buildTech("📱", "Flutter"),
                        buildTech("🔥", "Firebase"),
                        buildTech("💳", "Paymee Sandbox"),
                      ]),

                      const SizedBox(height: 30),

                      // ============ ÉQUIPE ============
                      const Text(
                        "Notre Équipe",
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF234138)),
                      ),
                      const SizedBox(height: 20),

                      buildGrid([
                        buildMember("👨‍💻", "Khalil Mekni", "Développeur Full-Stack"),
                        buildMember("👩‍🏫", "Fatma ben Saad", "Pédagogie"),
                        buildMember("🎨", "Hend Chahed", "Designer UX/UI"),
                      ]),

                      const SizedBox(height: 40),

                      Center(
                        child: Text(
                          "© 2025 LearnTounsi - Tous droits réservés",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ======== WIDGETS RÉUTILISABLES ========

  Widget buildSection({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 20, offset: Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF234138))),
          const SizedBox(height: 14),
          Text(
            content,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget buildGrid(List<Widget> children) {
    return LayoutBuilder(builder: (context, size) {
      return GridView.count(
        crossAxisCount: size.maxWidth > 800 ? 2 : 1,
        shrinkWrap: true,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        physics: const NeverScrollableScrollPhysics(),
        children: children,
      );
    });
  }

  Widget buildFeature(String icon, String title) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: const Color(0xFFF8F5F0),
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 38)),
          const SizedBox(height: 10),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget buildTech(String icon, String name) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: const Color(0xFFE0EEC6),
          borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 30)),
          const SizedBox(height: 8),
          Text(name,
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget buildMember(String avatar, String name, String role) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 15, offset: Offset(0, 6))
        ],
      ),
      child: Column(
        children: [
          Text(avatar, style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 10),
          Text(name,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          Text(role, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
