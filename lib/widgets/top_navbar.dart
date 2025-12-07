import 'package:flutter/material.dart';
import '../../view/home.dart';
import '../../view/formations.dart';
import '../../view/apropos.dart';
import '../../view/contact.dart';

class TopNavigationBar extends StatelessWidget {
  const TopNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: const Color(0xFF1E3A32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          navItem(context, "Accueil", const HomePage()),
          navItem(context, "Formations", const FormationsPage()),
          navItem(context, "À propos", const AboutPage()),
          navItem(context, "Contact", const ContactPage()),
        ],
      ),
    );
  }

  Widget navItem(BuildContext context, String text, Widget page) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }
}
