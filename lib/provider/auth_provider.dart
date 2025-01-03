import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _fireAuth = FirebaseAuth.instance; // Firebase Auth instance
final _firestore = FirebaseFirestore.instance; // Firestore instance

class AuthProfider extends ChangeNotifier {
  final form = GlobalKey<FormState>();

  // Form data
  var isLogin = true;
  var enteredName = '';
  var enteredOrigin = '';
  var enteredEmail = '';
  var enteredPassword = '';
  var enteredAge = '';
  var enteredSchool = '';
  var imageUrl = '';

  /// Submit the form
  Future<void> submit(BuildContext context) async {
    // Validate form
    final _isValid = form.currentState?.validate() ?? false;

    if (!_isValid) {
      return;
    }

    form.currentState?.save();

    try {
      if (isLogin) {
        // Login flow
        await _fireAuth.signInWithEmailAndPassword(
          email: enteredEmail,
          password: enteredPassword,
        );

        _showSnackBar(context, "Login berhasil, restart aplikasi (masih perbaikan)", true); // Menampilkan SnackBar hijau
      } else {
        // Register flow
        UserCredential userCredential =
            await _fireAuth.createUserWithEmailAndPassword(
          email: enteredEmail,
          password: enteredPassword,
        );

        // Save user data to Firestore
        await _firestore.collection('users').doc(userCredential.user?.uid).set({
          'name': enteredName,
          'origin': enteredOrigin,
          'email': enteredEmail,
          'age': enteredAge,
          'school': enteredSchool,
          'imageUrl': imageUrl,
          'createdAt': Timestamp.now(), // Add timestamp
        });

        _showSnackBar(context, "Registrasi berhasil, restart aplikasi (perbaikan)", true); // Menampilkan SnackBar hijau
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        _showSnackBar(context, _handleAuthException(e), false); // Menampilkan SnackBar merah untuk error
      } else {
        _showSnackBar(context, "Terjadi kesalahan, silakan coba lagi.", false); // Menampilkan SnackBar merah
      }
    }

    notifyListeners();
  }

  /// Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return "Email tidak terdaftar.";
      case 'wrong-password':
        return "Password salah.";
      case 'email-already-in-use':
        return "Email sudah terdaftar.";
      case 'weak-password':
        return "Password terlalu lemah.";
      case 'invalid-email':
        return "Format email tidak valid.";
      default:
        return "Terjadi kesalahan, silakan coba lagi.";
    }
  }

  /// Show a SnackBar for feedback
  void _showSnackBar(BuildContext context, String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white), // Teks berwarna putih
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.red, // Warna background hijau jika sukses, merah jika gagal
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
