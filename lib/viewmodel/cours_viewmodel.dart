import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../model/cours.dart';

class CoursViewModel with ChangeNotifier {
  /* ---------- Services ---------- */
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage  _storage = FirebaseStorage.instance;

  /* ---------- Observables ---------- */
  final ValueNotifier<List<Cours>> cours = ValueNotifier<List<Cours>>([]);
  final ValueNotifier<bool> isLoading   = ValueNotifier<bool>(true);
  final ValueNotifier<String?> error    = ValueNotifier<String?>(null);

  /* ---------- Champs ---------- */
  late final String _matiereTitre;
  StreamSubscription<QuerySnapshot>? _sub;

  /* ---------- Construction ---------- */
  CoursViewModel({required String matiereTitre}) {
    this._matiereTitre = matiereTitre;
    _listeCours();
  }

  
  
  /* ---------- Écoute temps-réel ---------- */
  void _listeCours() {
    // Test 1 : Vérifier si Firestore est initialisé
    try {
      print('✅ Firestore accessible');
    } catch (e) {
      print('❌ Firestore NON accessible: $e');
    }

    // Test 2 : Lancer le stream
    _sub = _db
        .collection('cours')
        .where('matiere', isEqualTo: _matiereTitre)
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
      cours.value = snap.docs.map((doc) => Cours.fromFirestore(doc)).toList();
      print('✅ cours convertis: ${cours.value.length}');
      } catch (e) {
        print('❌ Erreur conversion: $e');
      }
      isLoading.value = false;
      error.value = null;
      notifyListeners();
    },onError: (e) {
      print('═══════════════════════════════════════');
      print('❌ ERREUR STREAM FIRESTORE');
      print('Type: ${e.runtimeType}');
      print('Message: $e');
      print('═══════════════════════════════════════');

      isLoading.value = false;
      notifyListeners();
    });
  }

  /* ---------- CRUD ---------- */
  Future<void> addCours({
    required String titre,
    required double prix,
    String? description,
    required String matiere,
    required String pdf_gratuit,
    required String pdf_payant,
    String? image

  }) async {
    try {
      await _db.collection('cours').add({
        'titre': titre,
        'prix': prix,
        'description': description,
        'matiere': matiere,
        'pdf_gratuit': pdf_gratuit,
        'pdf_payant': pdf_payant,
        'image': image
      });


    } catch (e) {
      error.value = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _envoyerNotifications(String matiereId, String titreCours) async {
    // Récupérer les étudiants abonnés
    final abonnes = await _db
        .collection('abonnements')
        .where('matiere_id', isEqualTo: matiereId)
        .get();

    }



  Future<void> updateCours({
    required String id,
    required String titre,
    required double prix,
    String? description,
    required String matiere,
    required String pdf_gratuit,
    required String pdf_payant,
    String? image,

  }) async {
    try {
      await _db.collection('cours').doc(id).update({
        'titre': titre,
        'prix': prix,
        'description': description,
        'matiere': matiere,
        'pdf_gratuit': pdf_gratuit,
        'pdf_payant': pdf_payant,
        'image': image,

      });
    } catch (e) {
      error.value = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteCours(Cours c) async {
    try {
      /*if (c.pdf_gratuit.isNotEmpty) {
        await _storage.refFromURL(c.pdf_gratuit).delete();
      }
      if (c.pdf_payant.isNotEmpty) {
        await _storage.refFromURL(c.pdf_payant).delete();
      }*/
      await _db.collection('cours').doc(c.id).delete();
    } catch (e) {
      error.value = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /* ---------- PDF ---------- */
  Future<void> uploadPdf({
    required Cours cours,
    required bool gratuit,
    required File file,
  }) async {
    final fileName = gratuit ? 'pdf_gratuit' : 'pdf_payant';
    final ref = _storage.ref('cours/${cours.id}/$fileName');

    final snapshot = await ref.putFile(file);
    final url = await snapshot.ref.getDownloadURL();

    final key = gratuit ? 'pdf_gratuit' : 'pdf_payant';
    await _db.collection('courses').doc(cours.id).update({key: url});
  }

  Future<void> deletePdf({
    required Cours cours,
    required bool gratuit,
  }) async {
    final key = gratuit ? 'pdf_gratuit' : 'pdf_payant';
    final String? url = gratuit ? cours.pdf_gratuit : cours.pdf_payant;
    //if (url.isEmpty) return;

    //await _storage.refFromURL(url).delete();
    await _db.collection('cours').doc(cours.id).update({key: ''});
  }

  @override
  void dispose() {
    _sub?.cancel();
    cours.dispose();
    isLoading.dispose();
    error.dispose();
    super.dispose();
  }
}