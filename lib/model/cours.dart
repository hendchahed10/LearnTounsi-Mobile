import 'package:cloud_firestore/cloud_firestore.dart';

class Cours {
  final String id; // ID du document Firestore
  String titre;
  num prix;
  String description;
  final String? pdf_gratuit;  // lien vers le PDF gratuit
  final String? pdf_payant;   // lien vers le PDF payant
  final String matiere; // référence à la matière parente
  String? image;

  Cours(
    this.id,
    this.titre,
    this.prix,
    this.matiere,
    this.description,
    this.pdf_gratuit,
    this.pdf_payant,
      this.image
  );

// Créer un Cours depuis un document Firestore
  factory Cours.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>; //transforme doc.data() en map
    return Cours( doc.id, data['titre'] ?? '', data['prix'], data['matiere'], data['description'], data['pdf_gratuit'], data['pdf_payant'],
      data['image']
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'titre': titre,
      'prix': prix,
      'matiere': matiere,
      'description': description,
      'pdf_gratuit': pdf_gratuit,
      'pdf_payant': pdf_payant,
      'image': image,
    };
  }
}