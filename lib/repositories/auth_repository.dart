import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseDatabase _database;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseDatabase? database,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _database = database ?? FirebaseDatabase.instance;

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String username,
    String? phone,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save additional user data to Realtime Database
      await _database.ref().child('users').child(userCredential.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'phone': phone,
        'email': email,
      });

      return userCredential;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Stream<User?> get user => _firebaseAuth.authStateChanges();

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DatabaseEvent event = await _database.ref().child('users').child(uid).once();
      return event.snapshot.value as Map<String, dynamic>?;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
