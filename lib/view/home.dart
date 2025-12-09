import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../viewmodel/homeVM.dart';
import 'connexion.dart';
import 'coursparMA.dart';
import '../widgets/top_navbar.dart';
import '../widgets/Cappbar.dart';
import '../services/paymee_service.dart';
import 'payment_page_matiere.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, bool> purchasedMatieres = {}; // <matiereId, true>

  /// 🔥 Vérifier si la matière est déjà achetée
  Future<void> checkIfPurchased(String matiereId, String userId) async {
    final query = await FirebaseFirestore.instance
        .collection("abonnement")
        .where("matiere_id", isEqualTo: matiereId)
        .where("user_id", isEqualTo: userId)
        .limit(1)
        .get();

    setState(() {
      purchasedMatieres[matiereId] = query.docs.isNotEmpty;
    });
  }

  /// ⭐ Paiement Paymee
  Future<void> startPayment(BuildContext context, dynamic m) async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final user = authVM.user;

    if (user == null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage()));
      return;
    }

    final safeOrderId = m.titre.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');

    final result = await PaymeeService.initiatePayment(
      amount: (m.prix as num).toDouble(),
      note: "Achat matière ${m.titre}",
      firstName: "Asma",
      lastName: "BenAhmed",
      email: user.email ?? "",
      phone: "11111111",
      orderId: safeOrderId,
    );

    if (result == null || result["status"] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur Paymee : ${result?["message"]}")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPageMatiere(
          paymentUrl: result["data"]["payment_url"],
          token: result["data"]["token"],
          matiereId: m.id,
          prix: m.prix,
          titreMatiere: m.titre,
          image: m.image,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeVM = Provider.of<HomeViewModel>(context);
    final authVM = Provider.of<AuthViewModel>(context);
    final user = authVM.user;

    if (user != null) {
      for (var m in homeVM.filteredMatieres) {
        if (!purchasedMatieres.containsKey(m.id)) {
          checkIfPurchased(m.id, user.uid);
        }
      }
    }

    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: buildDrawer(authVM, homeVM, context),
      body: Column(
        children: [
          const TopNavigationBar(),
          Expanded(
            child: homeVM.loading
                ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFC5E782)),
            )
                : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: homeVM.filteredMatieres.length,
                itemBuilder: (context, index) {
                  final m = homeVM.filteredMatieres[index];
                  return GestureDetector(
                    onTap: () {
                      if (authVM.user == null) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => LoginPage()));
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CoursParMatierePage(matiere: m.titre),
                        ),
                      );
                    },
                    child: buildMatiereCard(context, m),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDrawer(authVM, homeVM, context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A332A), Color(0xFF234138)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (authVM.user != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authVM.user!.email!,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      authVM.logout();
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => LoginPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC2A83E),
                    ),
                    child: const Text("Déconnexion"),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            const Text(
              "Catégories",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC5E782)),
            ),
            const SizedBox(height: 20),
            categoryButton(context, "Tous les cours", "all", homeVM),
            categoryButton(context, "Développement Web & Data", "developpement", homeVM),
            categoryButton(context, "Marketing & Communication", "marketing", homeVM),
            categoryButton(context, "Cybersécurité & Réseaux", "cyber", homeVM),
            categoryButton(context, "Business & Finance", "finance", homeVM),
          ],
        ),
      ),
    );
  }

  Widget categoryButton(BuildContext context, String title, String category,
      HomeViewModel vm) {
    final isActive = vm.activeCategory == category;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
          isActive ? const Color(0xFFC2A83E) : const Color(0xFF2A4D42),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
        onPressed: () {
          vm.filterMatieres(category);
          Navigator.pop(context);
        },
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMatiereCard(BuildContext context, dynamic m) {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final user = authVM.user;

    bool isPurchased = purchasedMatieres[m.id] == true;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      shadowColor: Colors.black26,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              'assets/images/${m.image}',
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.titre,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF234138),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  m.description,
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
                const SizedBox(height: 16),

                /// ⭐ Bouton ACCÉDER — inchangé
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC2A83E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (user == null) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => LoginPage()));
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CoursParMatierePage(matiere: m.titre),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    child: Text(
                      "Accéder",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPurchased ? Colors.grey : Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isPurchased
                      ? null
                      : () {
                    if (user == null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoginPage(),
                        ),
                      );
                      return;
                    }
                    startPayment(context, m);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    child: Text(
                      isPurchased
                          ? "Déjà acheté"
                          : "Acheter (${m.prix} dt)",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
