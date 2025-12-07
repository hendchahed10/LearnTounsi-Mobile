import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../widgets/top_navbar.dart';
import 'page_cours.dart';
import '../viewmodel/auth_viewmodel.dart';
import 'connexion.dart';
import '../widgets/Cappbar.dart';

class FormationsPage extends StatelessWidget {
  const FormationsPage({super.key});

  // ⭐ Enregistrer seulement la première consultation
  Future<void> saveConsultation({
    required String userId,
    required String coursId,
    required String titre,
    required String matiere,
  }) async {
    final ref = FirebaseFirestore.instance.collection("consultation");

    final snap = await ref
        .where("user_id", isEqualTo: userId)
        .where("cours_id", isEqualTo: coursId)
        .get();

    if (snap.docs.isNotEmpty) {
      print("Consultation déjà existante pour $coursId");
      return;
    }

    await ref.add({
      "user_id": userId,
      "cours_id": coursId,
      "titre": titre,
      "matiere": matiere,
      "date": Timestamp.now(),
    });

    print("Première consultation enregistrée → $titre");
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final user = authVM.user;

    return Scaffold(
      appBar: const CustomAppBar(),

      body: Column(
        children: [
          const TopNavigationBar(),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("cours")
                  .orderBy("titre")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF234138)),
                  );
                }

                final coursList = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: coursList.length,
                  itemBuilder: (context, index) {
                    final c = coursList[index];
                    final data = c.data() as Map<String, dynamic>;

                    final String coursId = c.id;
                    final String titre = data["titre"] ?? "Sans titre";
                    final String description = data["description"] ?? "";
                    final String matiere = data["matiere"] ?? "";
                    final String image = data["image"] ?? "";

                    // ⭐ payant → bool propre
                    final bool payant =
                        data["payant"].toString() == "oui" ||
                            data["payant"].toString() == "true" ||
                            data["payant"] == true;

                    // ❌ MASQUER LE COURS PAYANT
                    if (payant) {
                      return const SizedBox.shrink();
                    }

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          // IMAGE
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                            child: Image.asset(
                              "assets/images/$image",
                              width: 110,
                              height: 110,
                              fit: BoxFit.cover,
                            ),
                          ),

                          // TITRE + DESCRIPTION
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    titre,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF234138),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Column(
                            children: [
                              // ------------------ ACCÉDER ------------------
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFC2A83E),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  // 🔒 Utilisateur non connecté
                                  if (authVM.user == null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => LoginPage(
                                          redirectTo: PageCours(
                                            matiere: matiere,
                                            cours: titre,
                                          ),
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  // 🟢 ENREGISTRER consultation
                                  await saveConsultation(
                                    userId: authVM.user!.uid,
                                    coursId: coursId,
                                    titre: titre,
                                    matiere: matiere,
                                  );

                                  // 🟢 Ouvrir le cours
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PageCours(
                                        matiere: matiere,
                                        cours: titre,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Accéder",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(width: 12),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
