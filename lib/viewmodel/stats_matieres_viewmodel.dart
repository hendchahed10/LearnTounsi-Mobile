import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class StatsMatiereViewModel extends ChangeNotifier {
  /* ---------- Services ---------- */
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /* ---------- Observables ---------- */
  final ValueNotifier<Map<String, Map<String, dynamic>>> paiementsParMatiere =
  ValueNotifier<Map<String, Map<String, dynamic>>>({});

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);
  final ValueNotifier<String?> error = ValueNotifier<String?>(null);

  /* ---------- Subscriptions ---------- */ //les streamsubsciprions servent à arrêter l'écoute lorsque le viewmdoel est détruit
  StreamSubscription<QuerySnapshot>? _abonnementsSub;
  StreamSubscription<QuerySnapshot>? _matieresSub;

  // Cache des noms de matières
  final Map<String, String> _matieresNoms = {};

  /* ---------- Construction ---------- */
  StatsMatiereViewModel() {
    _init();
  }

  /* ---------- Initialisation ---------- */
  void _init() {
    print('🔄 Initialisation StatsViewModel...');

    // D'abord charger les noms des matières
    _chargerMatieres();

    // Puis charger les statistiques
    _ecouterAbonnements();
  }

  /* ---------- Charger les noms des matières ---------- */
  void _chargerMatieres() {
    _matieresSub = _db.collection('matiere').snapshots().listen(
          (snapshot) {
        for (var doc in snapshot.docs) {
          _matieresNoms[doc.id] = doc.data()['titre'] ?? 'Matière ${doc.id}';
        }
        print('${_matieresNoms.length} matières chargées');
        notifyListeners();
      },
      onError: (e) {
        print('❌ Erreur chargement matières: $e');
      },
    );
  }

  /* ---------- Écouter les abonnements ---------- */
  void _ecouterAbonnements() {
    _abonnementsSub = _db.collection('abonnement').snapshots().listen(
          (snapshot) {
        print('${snapshot.docs.length} abonnements trouvés');

        // Compter par matière
        final Map<String, int> abonnesParMatiere = {};
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final ref = data['matiere_id'];
          final String? matiereId = (ref is DocumentReference) ? ref.id : ref as String?;
          if (matiereId != null) {
            abonnesParMatiere[matiereId] = (abonnesParMatiere[matiereId] ?? 0) + 1;
          }
        }

        // Mettre à jour la map
        _updatePaiementsParMatiere(abonnesParMatiere);

        isLoading.value = false;
        notifyListeners();
      },
      onError: (e) {
        print('❌ Erreur abonnements: $e');
        error.value = e.toString();
        isLoading.value = false;
        notifyListeners();
      },
    );
  }


  /* ---------- Mise à jour des maps ---------- */
  void _updatePaiementsParMatiere(Map<String, int> abonnes) {
    final newMap = Map<String, Map<String, dynamic>>.from(paiementsParMatiere.value); //la méthode .from crée une copie de la map ; ".value" transforme paiementsParMatiere d'un ValueNotifier à une map

    for (var entry in abonnes.entries) {
      final matiereId = entry.key;
      newMap[matiereId] = {
        'id': matiereId,
        'titre': _matieresNoms[matiereId] ?? 'Matière $matiereId',
        'abonnes': entry.value,
        'consultes': newMap[matiereId]?['consultes'] ?? 0,
        'termines': newMap[matiereId]?['termines'] ?? 0,
      };
    }

    paiementsParMatiere.value = newMap;
  }

  /* ---------- Dispose ---------- */
  @override
  void dispose() {
    print('🗑️ StatsViewModel disposed');
    _abonnementsSub?.cancel();
    _matieresSub?.cancel();
    paiementsParMatiere.dispose();
    isLoading.dispose();
    error.dispose();
    super.dispose();
  }
}