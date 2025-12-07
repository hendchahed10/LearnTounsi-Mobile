import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/courparM.dart';
import 'connexion.dart';
import 'page_cours.dart';

class CoursParMatierePage extends StatefulWidget {
  final String matiere;

  CoursParMatierePage({required this.matiere});

  @override
  State<CoursParMatierePage> createState() => _CoursParMatierePageState();
}

class _CoursParMatierePageState extends State<CoursParMatierePage> {
  @override
  void initState() {
    super.initState();

    // 💥 Toujours recharger les cours quand on ouvre la page
    Future.microtask(() {
      Provider.of<CoursParMatiereVM>(context, listen: false)
          .loadCourses(widget.matiere);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CoursParMatiereVM>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Cours : ${widget.matiere}"),
        backgroundColor: const Color(0xFF234138),
      ),

      body: vm.loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC5E782)))
          : vm.courses.isEmpty
          ? const Center(
        child: Text("📚 Aucun cours trouvé",
            style: TextStyle(fontSize: 18, color: Colors.grey)),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vm.courses.length,
        itemBuilder: (ctx, i) {
          final c = vm.courses[i];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 6,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    "assets/images/${c.image}",
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.titre,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF234138),
                        ),
                      ),

                      const SizedBox(height: 8),
                      Text(c.description,
                          style: TextStyle(fontSize: 15, color: Colors.grey[700])),

                      const SizedBox(height: 16),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC2A83E),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PageCours(
                                matiere: widget.matiere,
                                cours: c.titre,
                              ),
                            ),
                          );
                        },
                        child: const Text("Commencer",
                            style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
