import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/auth_viewmodel.dart';
import 'home.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final username = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FDF8),

      appBar: AppBar(
        backgroundColor: const Color(0xFF234138),
        title: const Text("Inscription"),
      ),

      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.only(top: 40),

          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE0EEC6), Color(0xFFC5E782)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 4),
              )
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Créer un compte",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF243E36),
                ),
              ),

              const SizedBox(height: 24),

              TextField(
                controller: username,
                decoration: InputDecoration(
                  hintText: "Nom d'utilisateur",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF7CA982)),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: email,
                decoration: InputDecoration(
                  hintText: "Email",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade600),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Mot de passe",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade600),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              if (authVM.error != null)
                Text(authVM.error!, style: const TextStyle(color: Colors.red)),

              const SizedBox(height: 14),

              authVM.loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC2A83E),
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  await authVM.register(
                    email.text.trim(),
                    password.text.trim(),
                    username.text.trim(),
                  );

                  if (authVM.user != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomePage(),
                      ),
                    );
                  }
                },
                child: const Text(
                  "S'inscrire",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
