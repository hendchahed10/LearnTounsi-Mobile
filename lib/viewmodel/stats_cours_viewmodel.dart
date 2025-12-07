import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class StatsCoursViewModel extends ChangeNotifier {
  /* ---------- Services ---------- */
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /* ---------- Observables ---------- */
  final ValueNotifier<Map<String, Map<String, dynamic>>> StatsCours =
  ValueNotifier<Map<String, Map<String, dynamic>>>({});

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);
  final ValueNotifier<String?> error = ValueNotifier<String?>(null);

  /* ---------- Subscriptions ---------- */ //les streamsubsciprions servent à arrêter l'écoute lorsque le viewmdoel est détruit
  StreamSubscription<QuerySnapshot>? _achatsSub;
  StreamSubscription<QuerySnapshot>? _consultationsSub;
  StreamSubscription<QuerySnapshot>? _coursTerminesSub;
  StreamSubscription<QuerySnapshot>? _coursSub;

  // Cache des noms de matières
  final Map<String, String> _coursNoms = {};

  /* ---------- Champs ---------- */
  String matiereTitre;

  /* ---------- Construction ---------- */
  StatsCoursViewModel(this.matiereTitre) {
    _init();
  }

  /* ---------- Initialisation ---------- */
  void _init() {
    print('🔄 Initialisation StatsViewModel...');

    // D'abord charger les noms des cours
    _chargerCours();

    // Puis charger les statistiques
    _ecouterAchats();
    _ecouterConsultations();
    _ecouterCoursTermines();
  }

  /* ---------- Charger les noms des cours pour une matiere donnée ---------- */
  void _chargerCours() {
       _coursSub = _db.collection('cours')
        .where('matiere', isEqualTo: matiereTitre)
        .snapshots()
        .listen((snap) {
        for (var doc in snap.docs) {
          _coursNoms[doc.id] = doc.data()['titre'] ?? 'Cours ${doc.id}';
        }
        print('${_coursNoms.length} cours chargés (STATS)');
        notifyListeners();
      },
      onError: (e) {
        print('❌ Erreur chargement cours: $e');
      },
    );
  }

  /* ---------- Écouter les achats ---------- */
  void _ecouterAchats() {
    _achatsSub = _db.collection('achat').
    where('matiere', isEqualTo: matiereTitre).
    snapshots().listen(
          (snapshot) {
        print('${snapshot.docs.length} achats trouvés');

        // Compter par cours
        final Map<String, int> achatsParCours = {};
        try {
          for (var doc in snapshot.docs) {
            final coursId = doc.data()['cours_id'] as String?;
            if (coursId != null) {
              achatsParCours[coursId] = (achatsParCours[coursId] ?? 0) + 1;
            }
          }
        }catch(e) {print(('ERREUR : $e'));};

        // Mettre à jour la map
        final newMap = Map<String, Map<String, dynamic>>.from(StatsCours.value); //la méthode .from crée une copie de la map ; ".value" transforme paiementsParMatiere d'un ValueNotifier à une map

        for (var entry in achatsParCours.entries) {
          final coursId = entry.key;
          newMap[coursId] = {
            'id': coursId,
            'titre': _coursNoms[coursId] ?? 'Cours $coursId',
            'abonnes': entry.value,
            'consultes': newMap[coursId]?['consultes'] ?? 0,
            'termines': newMap[coursId]?['termines'] ?? 0,
          };
        }

        StatsCours.value = newMap;
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

  /* ---------- Écouter les consultations ---------- */
  void _ecouterConsultations() {
    _consultationsSub = _db.collection('consultation').
        where('matiere', isEqualTo: matiereTitre).
          snapshots().listen(
          (snapshot) {
        print('${snapshot.docs.length} consultations trouvées');
        final Map<String, int> consultationsParCours= {};
        for (var doc in snapshot.docs) {
          final coursId = doc.data()['cours_id'] as String?;
          if (coursId != null) {
            consultationsParCours[coursId] = (consultationsParCours[coursId] ?? 0) + 1;
          }
        }

        final newMap = Map<String, Map<String, dynamic>>.from(StatsCours.value);

        for (var entry in consultationsParCours.entries) {
          final coursId = entry.key;
            newMap[coursId] = {
              'id': coursId,
              'titre': _coursNoms[coursId] ?? 'Cours $coursId',
              'abonnes': newMap[coursId]?['abonnes'] ?? 0,
              'consultes': entry.value,
              'termines': newMap[coursId]?['termines'] ?? 0,
            };
          }

        StatsCours.value = newMap;
        notifyListeners();
      },
      onError: (e) {
        print('❌ Erreur consultations: $e');
      },
    );
  }

  /* ---------- Écouter les cours terminés ---------- */
  void _ecouterCoursTermines() {
    _coursTerminesSub = _db.collection('cours_termines').
    where('matiere', isEqualTo: matiereTitre).
    snapshots().
    listen(
          (snapshot) {
        print('${snapshot.docs.length} cours terminés trouvés');

        final Map<String, int> terminesParCours = {};
        for (var doc in snapshot.docs) {
          final coursId = doc.data()['cours_id'] as String?;
          if (coursId != null) {
            terminesParCours[coursId] = (terminesParCours[coursId] ?? 0) + 1;
          }
        }

        final newMap = Map<String, Map<String, dynamic>>.from(StatsCours.value);

        for (var entry in terminesParCours.entries) {
          final coursId = entry.key;
            newMap[coursId] = {
              'id': coursId,
              'titre': _coursNoms[coursId] ?? 'Cours $coursId',
              'abonnes': newMap[coursId]?['abonnes'] ?? 0,
              'consultes': newMap[coursId]?['consultes'] ?? 0,
              'termines': entry.value,
            };
          }

        StatsCours.value = newMap;
        notifyListeners();
      },
      onError: (e) {
        print('❌ Erreur cours terminés: $e');
      },
    );
  }
/* ---------- Dispose ---------- */
  @override
  void dispose() {
    print('🗑️ StatsViewModel disposed');
    _achatsSub?.cancel();
    _coursSub?.cancel();
    _consultationsSub?.cancel();
    _coursTerminesSub?.cancel();
    StatsCours.dispose();
    isLoading.dispose();
    error.dispose();
    super.dispose();
  }

}