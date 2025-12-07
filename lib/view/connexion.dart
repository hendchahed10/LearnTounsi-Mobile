import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/auth_viewmodel.dart';
import 'home.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  final Widget? redirectTo;

  const LoginPage({super.key, this.redirectTo});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FDF8),

      appBar: AppBar(
        backgroundColor: const Color(0xFF234138),
        title: const Text("Connexion"),
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
                "Connexion",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF243E36),
                ),
              ),

              const SizedBox(height: 24),

              // Email
              TextField(
                controller: email,
                decoration: InputDecoration(
                  hintText: "Email",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF7CA982)),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Password
              TextField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Mot de passe",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF7CA982)),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              if (authVM.error != null)
                Text(
                  authVM.error!,
                  style: const TextStyle(color: Color(0xFFD9534F)),
                ),

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
                  await authVM.login(
                    email.text.trim(),
                    password.text.trim(),
                  );

                  if (authVM.user != null) {
                    if (widget.redirectTo != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => widget.redirectTo!,
                        ),
                      );
                    } else {
                      final futureRole= authVM.roleUtilisateur();
                      final String role = await futureRole;
                      if (role=='etudiant') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomePage(),
                          ),
                        );
                      }
                      else if (role=='admin'){
                        try {
                          print('ROLE : ${role}');
                          Navigator.pushReplacementNamed(context, '/matieres');
                        } catch (e) {print('ERREUR : $e');}
                        }
                    }
                  }
                },
                child: const Text(
                  "Se connecter",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 12),

              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegisterPage()),
                  );
                },
                child: const Text(
                  "Pas encore de compte ? S'inscrire",
                  style: TextStyle(
                    color: Color(0xFF243E36),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
