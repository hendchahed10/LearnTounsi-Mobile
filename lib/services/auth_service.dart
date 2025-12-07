import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Connexion
  Future<User?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Inscription
  Future<User?> register(String email, String password, String username) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Sauvegarder le nom de l'utilisateur dans Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'email': email,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Déconnexion
  Future<void> logout() async {
    await _auth.signOut();
  }
}
