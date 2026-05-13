import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  AuthService({FirebaseAuth? auth, bool useFirebase = true})
      : _auth = useFirebase ? (auth ?? FirebaseAuth.instance) : null {
    _authSubscription = _auth?.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  final FirebaseAuth? _auth;
  StreamSubscription<User?>? _authSubscription;
  User? _user;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isAvailable => _auth != null;

  Future<String?> signIn(String email, String password) async {
    if (_auth == null) {
      return 'Firebase authentication belum dikonfigurasi.';
    }
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'An unexpected error occurred';
    }
  }

  Future<String?> signUp(String email, String password, String name) async {
    if (_auth == null) {
      return 'Firebase authentication belum dikonfigurasi.';
    }
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'An unexpected error occurred';
    }
  }

  Future<void> signOut() async {
    if (_auth == null) {
      return;
    }
    await _auth.signOut();
  }

  Future<String?> resetPassword(String email) async {
    if (_auth == null) {
      return 'Firebase authentication belum dikonfigurasi.';
    }
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'An unexpected error occurred';
    }
  }

  Future<String?> changePassword(String newPassword) async {
    if (_auth == null) {
      return 'Firebase authentication belum dikonfigurasi.';
    }
    try {
      await _user?.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'An unexpected error occurred';
    }
  }

  Future<String?> updateDisplayName(String name) async {
    if (_auth == null) {
      return 'Firebase authentication belum dikonfigurasi.';
    }
    try {
      await _user?.updateDisplayName(name);
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'An unexpected error occurred';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
