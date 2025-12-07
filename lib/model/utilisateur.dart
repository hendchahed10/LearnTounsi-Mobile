import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class Utilisateur{
  final String id; // ID du document Firestore
  String email;
  String nom;
  String prenom;
  String? dateNaissance;
  final DateTime createdAt;
  final String role;
  Utilisateur(this.id,this.email, this.nom, this.prenom, this.dateNaissance, this.createdAt, this.role);

  // Créer un Utilisateur depuis un document Firestore
  factory Utilisateur.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>; //transforme doc.data() en map

    DateTime createdAtDate;
    try {
      final dynamic ts = data['createdAt']; //final dynamic = déclaration d'une variable sans type fixe
      if (ts is Timestamp) {
        createdAtDate = ts.toDate();
      } else if (ts is String) {
        createdAtDate = DateTime.parse(ts);
      } else {
        createdAtDate = DateTime.now();
      }
    } catch (e) {
      print('❌ Erreur conversion createdAt: $e');
      createdAtDate = DateTime.now();
    }

    return Utilisateur(   doc.id, data['email'] ?? '', data['nom'], data['prenom'], data['dateNaissance'],
        createdAtDate, data['role']
    );
  }

// Convertir en Map pour envoyer à Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'nom': nom,
      'prenom': prenom,
      'dateNaissance': dateNaissance,
      'createdAt' : Timestamp.fromDate(createdAt),
      'role' : role
    };
  }
}

