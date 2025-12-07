import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../view/profile.dart';
import '../view/connexion.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final isLoggedIn = authVM.user != null;

    return AppBar(
      elevation: 4,
      backgroundColor: const Color(0xFF234138),

      title: const Text(
        "LearnTounsi",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      actions: [
        // ---------------------------
        // 🔐 UTILISATEUR CONNECTÉ
        // ---------------------------
        if (isLoggedIn) ...[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                authVM.user!.email!,
                style: const TextStyle(
                  color: Color(0xFFC5E782),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            tooltip: "Profil",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
        ],

        // ---------------------------
        // 🚪 UTILISATEUR NON CONNECTÉ
        // ---------------------------
        if (!isLoggedIn)
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.login, color: Colors.white),
            label: const Text(
              "Se connecter",
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            },
          ),

        // ---------------------------
        // MENU / DRAWER
        // ---------------------------
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ],
    );
  }
}
