import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learntounsi_mobile/model/utilisateur.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? user;
  bool loading = false;
  String? error;

  // Connexion
  Future<void> login(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      user = await _authService.login(email, password);
      error = null;
    } catch (e) {
      user = null;
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  //récupérer le rôle de l'utilisateur à la connexion

  Future<String> roleUtilisateur () async{
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: user?.email)
          .get();
      final List<Utilisateur> utilisateur = snapshot.docs.map((doc) =>
          Utilisateur.fromFirestore(doc)).toList();
      notifyListeners();
      print('UTILISATEUR : $utilisateur');
      print('ROLE : ${utilisateur[0].role}');
      notifyListeners();
      return (utilisateur[0].role);
    }catch(e) {print("ERREUR ROLE : $e");}
    return '';
  }

  // Inscription
  Future<void> register(String email, String password, String username) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      user = await _authService.register(email, password, username);
      error = null;
    } catch (e) {
      error = e.toString();
      user = null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Déconnexion
  Future<void> logout() async {
    loading = true;
    notifyListeners();

    try {
      await _authService.logout();
      user = null;
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
