// lib/view_model/matieres_viewmodel.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../model/matiere.dart';
import 'dart:async';

class MatieresViewModel with ChangeNotifier {
  /* ---------- Services ---------- */
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /* ---------- Observables ---------- */
  final ValueNotifier<List<Matiere>> matieres = ValueNotifier<List<Matiere>>([]);
  final ValueNotifier<bool> isLoading   = ValueNotifier<bool>(true);
  final ValueNotifier<String?> error    = ValueNotifier<String?>(null);

  /* ---------- Stream ---------- */
  StreamSubscription<QuerySnapshot>? _sub; //permet d’arrêter l’écoute temps-réel de Firestore quand on n’en a plus besoin (sinon le flux continue même quand on quitte l’écran → fuite mémoire).

  /* ---------- Construction ---------- */
  MatieresViewModel() {
    _listeMatieres();
  }

  /* ---------- Écoute temps-réel ---------- */
  void _listeMatieres() {
    print('═══════════════════════════════════════');
    print('📡 DÉBUT _listeMatieres()');
    print('📱 Collection: matiere');
    print('🔧 Firestore instance: ${_db.hashCode}');
    print('═══════════════════════════════════════');

    // Test 1 : Vérifier si Firestore est initialisé
    try {
      print('✅ Firestore accessible');
    } catch (e) {
      print('❌ Firestore NON accessible: $e');
    }

    // Test 2 : Lancer le stream
    _sub = _db
        .collection('matiere')
        .orderBy('titre')
        .snapshots()
        .listen((snap) {
      print('═══════════════════════════════════════');
      print('✅ STREAM REÇU !');
      print('📊 Nombre de documents: ${snap.docs.length}');

      if (snap.docs.isEmpty) {
        print('⚠️  COLLECTION VIDE !');
      } else {
        print('📝 Documents:');
        for (var doc in snap.docs) {
          print('   - ${doc.id}: ${doc.data()}');
        }
      }
      print('═══════════════════════════════════════');

      try {
        matieres.value = snap.docs.map((doc) => Matiere.fromFirestore(doc)).toList();
        print('✅ Matières converties: ${matieres.value.length}');
      } catch (e) {
        print('❌ Erreur conversion: $e');
      }

      isLoading.value = false;
      print('✅ isLoading mis à false');

      error.value = null;
      notifyListeners();
    },
      onError: (e) {
        print('═══════════════════════════════════════');
        print('❌ ERREUR STREAM FIRESTORE');
        print('Type: ${e.runtimeType}');
        print('Message: $e');
        print('═══════════════════════════════════════');

        error.value = e.toString();
        isLoading.value = false;
        notifyListeners();
      },
      onDone: () {
        print('🏁 Stream fermé');
      },
      cancelOnError: false,
    );

    print('📡 Stream configuré, en attente de données...');
  }

  /* ---------- CRUD ---------- */
  Future<void> addMatiere({
    required String titre,
    required String description,
    required num prix,
    required String category,
    required String image
  }) async {
    try {
      await _db.collection('matiere').add({
        'titre': titre,
        'description': description,
        'prix': prix,
        'category': category,
        'image' : image,
      });
      // le stream mettra à jour la liste automatiquement
    } catch (e) {
      error.value = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateMatiere({
    required String id,
    required String titre,
    required String description,
    required num prix,
    required String category,
    required String image,
  }) async {
    try {
      await _db.collection('matiere').doc(id).update({
        'titre': titre,
        'description': description,
        'prix': prix,
        'category': category,
        'image' : image,
      });
    } catch (e) {
      error.value = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteMatiere(String id) async {
    try {
      // suppression des sous-collections si besoin (Cloud Function ou batch)
      await _db.collection('matiere').doc(id).delete();
    } catch (e) {
      error.value = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /* ---------- Libération ---------- */
  @override
  void dispose() {
    _sub?.cancel();
    matieres.dispose();
    isLoading.dispose();
    error.dispose();
    super.dispose();
  }
}