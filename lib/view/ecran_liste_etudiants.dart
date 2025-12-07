import 'package:flutter/material.dart';
import '../viewmodel/etudiants_viewmodel.dart';
import '../model/utilisateur.dart';
import 'package:learntounsi_mobile/main.dart';
import '../widgets/gardient.dart';

class EcranListeEtudiants extends StatefulWidget {
  @override
  State<EcranListeEtudiants> createState() => _EcranListeEtudiantsState();
}

class _EcranListeEtudiantsState extends State<EcranListeEtudiants> {
  late final EtudiantsViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = EtudiantsViewModel();  // ViewModel gère le stream
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();        // libère les observables
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
        body: SafeArea(
            child: ValueListenableBuilder<List<Utilisateur>>(
                valueListenable: _vm.etudiants,
                builder: (_, etudiants, __) {
                  return CustomScrollView(
                    slivers: [
                  /* ---------- Titre ---------- */
                  SliverToBoxAdapter(
                  child: Padding(
                  padding: EdgeInsets.only(
                    top: 30,
                    left: MediaQuery.of(context).size.width < 600 ? 20 : 40,
                    right: MediaQuery.of(context).size.width < 600 ? 20 : 40,
                    bottom: 20,
                  ),
                  child: LayoutBuilder(
                  builder: (context, constraints) {
                  double fontSize;
                  if (constraints.maxWidth < 400) {
                  fontSize = 28;
                  } else if (constraints.maxWidth < 600) {
                  fontSize = 36;
                  } else if (constraints.maxWidth < 900) {
                  fontSize = 44;
                  } else {
                  fontSize = 50;
                  }

                  return Text(
                  'Liste des étudiants',
                    textAlign: TextAlign.center,
                  style: TextStyle(
                  fontFamily: 'Lucida',
                  fontSize: fontSize,
                  color: Color(0xFF528859),
                  fontWeight: FontWeight.bold,
                  ),
                  );
                  },
            ),
        ),
    ),
                  SliverToBoxAdapter(child: SizedBox(height: 24)),

      /* ---------- Liste observable ---------- */

              if (etudiants.isEmpty)
                  SliverFillRemaining(
                  hasScrollBody: false,
                  child: const Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Icon(Icons.folder_open, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                  'Aucun étudiant trouvé',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  ],
                  ),
                  ),
                  )
                  else
                  SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                  (context, i) {
                  final e = etudiants[i];
                  return Center(
                      child: Card(
                        color: Colors.white.withValues(alpha: 0.7), // fond semi-transparent
                        elevation: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child:
                    ListTile(
                      leading: const Icon(Icons.person, color: Color(0xFF7ca982)),
                      title: Text('${e.nom} ${e.prenom ?? ''}'.trim(), style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF243e36))),
                      subtitle: Text(e.email,  style: TextStyle(color: Color(0xFF243e36)),),
                      onTap: () => _showDetails(e),
                    ),
                      ),
                    );
                },
                    childCount: etudiants.length,
              ),
            ),
        ),
      SliverToBoxAdapter(child: SizedBox(height: 50)),
      ],
          );
        },
      ),
    ),
              );
  }

  void _showDetails(Utilisateur e) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(e.nom+' '+ e.prenom),
        content: Text('Email : ${e.email}\n Date de naissance : ${e.dateNaissance}\n Créé le : ${e.createdAt}'),
        actions: [
          TextButton(onPressed: Navigator.of(context).pop, child: const Text('Fermer'))
        ],
      ),
    );
  }
}