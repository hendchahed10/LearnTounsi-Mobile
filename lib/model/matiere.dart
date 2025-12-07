import 'package:cloud_firestore/cloud_firestore.dart';

class Matiere {
  final String id; // ID du document Firestore
  String titre;
  num prix;
  String? description;
  String? categorie;
  String? image;

  Matiere(this.id, this.titre, this.prix, this.description, this.categorie, this.image);

// Créer une Matiere depuis un document Firestore
  factory Matiere.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>; //transforme doc.data() en map
    return Matiere(
        doc.id, data['titre'] ?? '', data['prix'], data['description'], data['category'] ?? '', data['image']
    );
  }


// Convertir en Map pour envoyer à Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'titre': titre,
      'prix': prix,
      'description': description,
      'category': categorie,
      'image': image,
    };
  }
}