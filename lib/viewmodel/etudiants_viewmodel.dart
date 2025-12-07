import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../model/utilisateur.dart';
import 'dart:async';

class EtudiantsViewModel with ChangeNotifier {
  /* ---------- Services ---------- */
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage  _storage = FirebaseStorage.instance;

  /* ---------- Observables ---------- */
  final ValueNotifier<List<Utilisateur>> etudiants = ValueNotifier<List<Utilisateur>>([]);
  final ValueNotifier<bool> isLoading   = ValueNotifier<bool>(true);
  final ValueNotifier<String?> error    = ValueNotifier<String?>(null);

  /* ---------- Champs ---------- */
  StreamSubscription<QuerySnapshot>? _sub;

  /* ---------- Construction ---------- */
  EtudiantsViewModel() {
    _listeEtudiants();
  }

  /* ---------- Écoute temps-réel ---------- */
  void _listeEtudiants() {
    _sub = _db
        .collection('users')
        .where('role', isEqualTo: "etudiant")
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
      etudiants.value = snap.docs.map((doc) => Utilisateur.fromFirestore(doc)).toList();
      isLoading.value = false;
      error.value = null;
      notifyListeners();
    }, onError: (e) {
      error.value = e.toString();
      isLoading.value = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    etudiants.dispose();
    isLoading.dispose();
    error.dispose();
    super.dispose();
  }
}