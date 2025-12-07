import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ====== VIEWMODELS ETUDIANT ======
import 'package:learntounsi_mobile/viewmodel/auth_viewmodel.dart';
import 'package:learntounsi_mobile/viewmodel/homeVM.dart';
import 'package:learntounsi_mobile/viewmodel/courparM.dart';

// ====== VIEWMODELS ADMIN ======
import 'package:learntounsi_mobile/viewmodel/stats_matieres_viewmodel.dart';
import 'package:learntounsi_mobile/viewmodel/stats_cours_viewmodel.dart';

// ====== VUES ETUDIANT ======
import 'view/home.dart';

// ====== VUES ADMIN ======
import 'package:learntounsi_mobile/view/ecran_matieres.dart';
import 'package:learntounsi_mobile/view/ecran_details_matiere.dart';
import 'package:learntounsi_mobile/view/ecran_statistiques_matieres.dart';
import 'package:learntounsi_mobile/view/ecran_statistiques_cours.dart';
import 'package:learntounsi_mobile/view/ecran_liste_etudiants.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        // ETUDIANT
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => CoursParMatiereVM()),

        // ADMIN
        ChangeNotifierProvider(create: (_) => StatsMatiereViewModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LearnTounsi',

      // Page d’accueil par défaut étudiant
      home: HomePage(),

      // Routes globales
      routes: {
        '/matieres': (_) => EcranMatieres(),
        '/liste_etudiants': (_) => EcranListeEtudiants(),
        '/statistiques_matieres': (_) => EcranStatistiquesMatieres(),
      },

      // Routes qui nécessitent arguments
      onGenerateRoute: (settings) {
        if (settings.name == '/details_matiere') {
          return MaterialPageRoute(
            builder: (_) => EcranDetailsMatiere(),
            settings: settings,
          );
        }

        if (settings.name == '/statistiques_cours') {
          final matiereTitre = settings.arguments as String;

          return MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (_) => StatsCoursViewModel(matiereTitre),
              child: EcranStatistiquesCours(),
            ),
          );
        }

        return null;
      },
    );
  }
}
