import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/matiere.dart';

class HomeViewModel extends ChangeNotifier {
  List<Matiere> matieres = [];
  List<Matiere> filteredMatieres = [];
  String activeCategory = "all";
  bool loading = true;

  HomeViewModel() {
    fetchMatieres();
  }

  Future<void> fetchMatieres() async {
    loading = true;
    notifyListeners();

    try {
      final querySnapshot =
      await FirebaseFirestore.instance.collection('matiere').get();

      matieres = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Matiere(
          id: doc.id,
          titre: data['titre'] ?? '',
          description: data['description'] ?? '',
          category: data['category'] ?? 'autre',
          image: data['image'] ?? 'https://via.placeholder.com/300',
          prix: (data['prix'] ?? 0),
        );
      }).toList();

      filteredMatieres = List.from(matieres);
    } catch (e) {
      print("Erreur Firestore: $e");
    }

    loading = false;
    notifyListeners();
  }

  void filterMatieres(String category) {
    activeCategory = category;

    if (category == "all") {
      filteredMatieres = List.from(matieres);
    } else {
      filteredMatieres =
          matieres.where((m) => m.category == category).toList();
    }

    notifyListeners();
  }
}
