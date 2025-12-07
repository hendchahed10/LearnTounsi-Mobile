import 'package:cloud_firestore/cloud_firestore.dart';

class Matiere {
  final String id;
  String titre;
  num prix;
  String? description;
  String? category;
  String? image;

  Matiere({
    required this.id,
    required this.titre,
    required this.prix,
    this.description,
    this.category,
    this.image,
  });

  factory Matiere.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;

    return Matiere(
      id: doc.id,
      titre: data['titre'] ?? '',
      prix: data['prix'] ?? 0,
      description: data['description'],
      category: data['category'] ?? 'autre',
      image: data['image'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'titre': titre,
      'prix': prix,
      'description': description,
      'category': category,
      'image': image,
    };
  }
}
