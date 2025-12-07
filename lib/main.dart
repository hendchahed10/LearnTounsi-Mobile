import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:learntounsi_mobile/model/utilisateur.dart';
import 'package:learntounsi_mobile/view/ecran_details_matiere.dart';
import 'package:learntounsi_mobile/view/ecran_liste_etudiants.dart';
import 'package:learntounsi_mobile/view/ecran_matieres.dart';
import 'package:learntounsi_mobile/view/ecran_statistiques_matieres.dart';
import 'package:learntounsi_mobile/view/ecran_statistiques_cours.dart';
import 'package:learntounsi_mobile/viewmodel/stats_matieres_viewmodel.dart';
import 'package:learntounsi_mobile/viewmodel/stats_cours_viewmodel.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized(); // Nécessaire avant Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ChangeNotifierProvider(create: (context) => StatsMatiereViewModel(),
      child: MyApp()
  ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LearnTounsi',
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Pour la route statistiques_cours, créer un Provider spécifique
        if (settings.name == '/statistiques_cours') {
          final matiereTitre = settings.arguments as String;

          return MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (_) => StatsCoursViewModel(matiereTitre),
              child: EcranStatistiquesCours(),
            ),
            settings: settings,
          );
        }
        // Routes normales
        // Route details_matiere avec arguments
        if (settings.name == '/details_matiere') {
          // ✅ Passer les arguments via settings
          return MaterialPageRoute(
            builder: (_) => EcranDetailsMatiere(),
            settings: settings, // ← IMPORTANT: transmettre les settings
          );
        }
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => EcranMatieres());
          case '/statistiques_matieres':
            return MaterialPageRoute(builder: (_) => EcranStatistiquesMatieres());
          case '/liste_etudiants':
            return MaterialPageRoute(builder: (_) => EcranListeEtudiants());
          default:
            return MaterialPageRoute(builder: (_) => EcranMatieres());
        }
      },
    );
  }
}

class GradientScaffold extends StatelessWidget {

  final Widget body;
  const GradientScaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600; /* ~MediaQuery.of(context) : récupère les informations sur l'écran
                                                                  ~.size.width : largeur de l'écran en pixels
                                                              ~< 600 : si largeur inférieure à 600px → mobile, sinon → desktop
                                                             ~ isMobile : variable booléenne (true ou false)*/
    final user = FirebaseAuth.instance.currentUser; //utilisateur connecté
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 80,
        titleSpacing: isMobile ? 16 : 32,
        title: Container(
          alignment: Alignment.centerLeft,
          child: Text(
            "🌿 LearnTounsi",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 24 : 32,
            ),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFF7ca982), Color(0xFF243e36)],
            ),
          ),
        ),
        actions: isMobile
            ? null  //Si mobile, retourner null = pas de boutons à droite de l'AppBar ; sinon les afficher
            : [
          _buildNavButton(
            context,
            'Gestion des Matières',
                () => Navigator.pushReplacementNamed(context, '/'),
          ),
          _buildNavButton(
            context,
            'Liste des Etudiants',
                () => Navigator.pushReplacementNamed(context, '/liste_etudiants'),
          ),
        PopupMenuButton<String>(
            offset: Offset(0, 50), // Décalage vers le bas
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFF7ca982).withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 12),
                  // Nom ou "Compte"
                  Text(
                    user?.displayName ?? 'Compte',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffffffff),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_drop_down, color: Color(0xFF243e36)),
                ],
              ),
            ),
            itemBuilder: (context) => [
            // En-tête du menu avec infos
            PopupMenuItem<String>(
            enabled: false, // Non cliquable
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  SizedBox(height: 12),
                  // Nom
                  Text(
                    user?.displayName ?? 'Admin',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF243e36),
                    ),
                  ),
                  SizedBox(height: 4),
                  // Email
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 12),
                  Divider(thickness: 1),
                ],
              ),
            ),
            ),
              // Option : Déconnexion
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 12),
                    TextButton( onPressed: () => _showLogoutDialog(context),
                      child: Text('Se déconnecter',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    ),
                  ],
                ),
              ),
            ],
        ),
        ],
      ),
      drawer: isMobile
          ? Drawer(       //Si mobile : affiche un Drawer (menu coulissant)
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF7ca982), Color(0xFF243e36)],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(  // En-tête du menu défilant
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Text(
                  '🌿 LearnTounsi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildDrawerItem(context, Icons.account_circle, '${user?.email ?? ''}\n ${user?.displayName}' , (){}),
              _buildDrawerItem(
                context,
                Icons.school,
                'Gestion des Matières',
                    () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
              _buildDrawerItem(
                context,
                Icons.people,
                'Liste des Etudiants',
                    () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/liste_etudiants');
                },
              ),
              TextButton(onPressed: () => _showLogoutDialog(context),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                        width: double.infinity,
                        child: ElevatedButton.icon(
                            onPressed: () { _showLogoutDialog(context);},
                          icon: Icon(Icons.logout, color: Color(0xFF243e36)),
                          label: Text(
                            'Se déconnecter',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF243e36),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xffc6d6af),  // Couleur dorée/beige
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                        ),
                    )
                  )
            ],
          ),
        ),
      )
          : null,
      body: Container(
        width: double.infinity, //pour occuper 100% de la longueur du Container
        height: double.infinity, //pour occuper 100% de la largeur du Container
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0EEC6), Color(0xFFf8f5f0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: body,
        ),
      ),
    );
  }

  // Dialog de confirmation de déconnexion
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('Déconnexion'),
        content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context); // Fermer le dialog
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text('Déconnecter'),
          ),
        ],
      ),
    );
  }
}

//Widget pour la navbar version desktop
  Widget _buildNavButton(BuildContext context, String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered)) {
              return Color(0x33c2a83e);
            }
            return Colors.transparent;
          },
        ),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
      child: Text(text, style: TextStyle(fontSize: 15)),
    );
  }

// Widget pour les items du drawer (mobile)
  Widget _buildDrawerItem(BuildContext context, IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: onTap,
    );
  }
