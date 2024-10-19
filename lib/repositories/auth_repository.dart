import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String username,
    String? phone,
  }) async {
    try {
      log('Attempting to create user with email: $email');
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      log('User created successfully with UID: ${userCredential.user!.uid}');

      // Save additional user data to Firestore
      log('Attempting to save user data to Firestore');
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'phone': phone,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      log('User data saved successfully to Firestore');

      return userCredential;
    } catch (e) {
      log('Error during sign up: $e');
      throw Exception(e.toString());
    }
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      log('Attempting to sign in user with email: $email');
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      log('User signed in successfully with UID: ${userCredential.user!.uid}');
      return userCredential;
    } catch (e) {
      log('Error during sign in: $e');
      throw Exception(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      log('Attempting to sign out user');
      await _firebaseAuth.signOut();
      log('User signed out successfully');
    } catch (e) {
      log('Error during sign out: $e');
      throw Exception(e.toString());
    }
  }

  Stream<User?> get user => _firebaseAuth.authStateChanges();

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      log('Attempting to get user data for UID: $uid');
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      log('User data retrieved successfully');
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      log('Error getting user data: $e');
      throw Exception(e.toString());
    }
  }
}
