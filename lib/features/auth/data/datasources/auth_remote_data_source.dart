import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<UserModel?> get authStateChanges;
  Future<UserModel> loginWithEmail({required String email, required String password});
  Future<UserModel> registerWithEmail({required String name, required String email, required String password});
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({required this.firebaseAuth, required this.firestore});

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) {
        return null;
      }
      
      // Fetch user data from Firestore
      try {
        final userDoc = await firestore.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          throw AuthException(code: 'user-not-found', message: 'User profile not found');
        }
        
        final userData = userDoc.data()!;
        return UserModel.fromFirestore(userData, user.uid);
      } catch (e) {
        // Fallback to Firebase user data if Firestore fails
        return UserModel.fromFirebase(user);
      }
    });
  }

  @override
  Future<UserModel> loginWithEmail({required String email, required String password}) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user document to check approval status
      final userDoc = await firestore.collection('users').doc(credential.user!.uid).get();
      if (!userDoc.exists) {
        throw AuthException(code: 'user-not-found', message: 'User profile not found');
      }

      final userData = userDoc.data()!;
      final status = userData['status'] as String? ?? 'approved';
      
      if (status != 'approved') {
        await firebaseAuth.signOut();
        throw UserUnapprovedException();
      }

      return UserModel.fromFirestore(userData, credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(code: e.code, message: e.message ?? 'Unknown Firebase Error');
    }
  }

  @override
  Future<UserModel> registerWithEmail({required String name, required String email, required String password}) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user!.updateDisplayName(name);

      // Create user document in Firestore
      final userModel = UserModel(
        id: credential.user!.uid,
        email: email,
        name: name,
        role: 'user',
        status: 'approved',
        createdAt: DateTime.now().toIso8601String(),
      );

      await firestore.collection('users').doc(credential.user!.uid).set(userModel.toFirestore());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(code: e.code, message: e.message ?? 'Unknown Firebase Error');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(code: e.code, message: e.message ?? 'Unknown Firebase Error');
    }
  }
}
