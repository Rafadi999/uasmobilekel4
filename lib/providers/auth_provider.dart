// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _role;
  String? get role => _role;

  /// Fungsi login utama
  Future<bool> login(String email, String password) async {
    try {
      // Login ke Firebase Authentication
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Ambil UID user
      final uid = userCredential.user!.uid;

      // Ambil data user dari Firestore (koleksi bisa disesuaikan)
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        _role = userDoc['role']; // misal: admin/guru/siswa
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuth error: ${e.message}");
      return false;
    } catch (e) {
      debugPrint("General login error: $e");
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
    _role = null;
    notifyListeners();
  }
}