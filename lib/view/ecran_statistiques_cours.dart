import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/stats_cours_viewmodel.dart';
import 'package:learntounsi_mobile/main.dart';

class EcranStatistiquesCours extends StatelessWidget { //dans cette view on a opté pour Provider au lieu de Setstate car on a plusieurs widgets dans l’écran qui doivent rebuild ensemble à partir d’une même source de données → impossible avec un seul setState.

  @override
  Widget build(BuildContext context) {
    final matiereTitre = ModalRoute.of(context)!.settings.arguments as String;
    return ChangeNotifierProvider(
      create: (_) => StatsCoursViewModel(matiereTitre),
      child: _buildContent(context, matiereTitre),
    );
  }

  Widget _buildContent(BuildContext context, String matiereTitre) {
    final vm = Provider.of<StatsCoursViewModel>(context);
    return GradientScaffold(
        body: SafeArea(
            child: ValueListenableBuilder<Map<String, Map<String, dynamic>>>(
                valueListenable: vm.StatsCours,
                builder: (_, map, __) {
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
                  'Matière ${matiereTitre} : Statistiques des cours ',
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


                  /* ---------- Liste des cours ---------- */
                  if (map.isEmpty)
                  SliverFillRemaining(
                  hasScrollBody: false,
                  child: const Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Icon(Icons.folder_open, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                  'Aucune donnée disponible',
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
                            final entry = map.entries.elementAt(i);
                            final data = entry.value;
                            return _coursCard(
                              data['titre'] ?? 'Cours ${entry.key}',
                              data['abonnes'] ?? 0,
                              data['consultes'] ?? 0,
                              data['termines'] ?? 0,
                            );
                          },
                          childCount: map.length,
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

/* ---------- Widget carte par cours ---------- */
  Widget _coursCard(String matiereTitre, int abonnes, int consultes, int termines) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre du cours
            Row(
              children: [
                Icon(Icons.school, color: Color(0xFF7ca982), size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    matiereTitre,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF243e36),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Barre abonnés
            _buildStatBar(
              label: '$abonnes achats',
              color: Color(0xFFc8d5b9),
            ),

            SizedBox(height: 12),

            // Barre consultés
            _buildStatBar(
              label: '$consultes utilisateurs ont consulté ce cours',
              color: Color(0xFFe8e8e8),
            ),

            SizedBox(height: 12),

            // Barre terminés
            _buildStatBar(
              label: '$termines utilisateurs ont terminé ce cours',
              color: Color(0xFF7ca982),
            ),
          ],
        ),
      ),
    );
  }

  /* ---------- Barre de statistique ---------- */
  Widget _buildStatBar({required String label, required Color color}) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF243e36),
        ),
      ),
    );
  }

}
