import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/cours.dart';

class CoursParMatiereVM extends ChangeNotifier {
  List<Cours> courses = [];
  bool loading = false;

  Future<void> loadCourses(String matiere) async {
    loading = true;
    courses = [];
    notifyListeners();

    final snapshot = await FirebaseFirestore.instance
        .collection("cours")
        .where("matiere", isEqualTo: matiere)
        .get();

    courses = snapshot.docs.map((doc) => Cours.fromFirestore(doc)).toList();

    loading = false;
    notifyListeners();
  }
}
