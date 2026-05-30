import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<UserModel?> get authStateChanges;
  Future<UserModel> loginWithEmail({required String email, required String password});
  Future<UserModel> registerWithEmail({required String name, required String email, required String password});
  Future<void> sendPasswordResetEmail({required String email});
  Future<void> logout();
  Future<void> deleteAccount({required String password});
  Future<void> sendEmailVerification();
  Future<bool> checkEmailVerified();
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

      try {
        final userDoc = await firestore.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          throw AuthException(code: 'user-not-found', message: 'User profile not found');
        }

        final userData = userDoc.data();
        if (userData == null) {
          throw AuthException(code: 'user-not-found', message: 'User profile data is empty');
        }
        return UserModel.fromFirestore(userData, user.uid);
      } catch (e) {
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

      final user = credential.user;
      if (user == null) {
        throw AuthException(code: 'login-failed', message: 'Login failed. Please try again.');
      }

      final userDoc = await firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        throw AuthException(code: 'user-not-found', message: 'User profile not found');
      }

      final userData = userDoc.data();
      if (userData == null) {
        throw AuthException(code: 'user-not-found', message: 'User profile data is empty');
      }

      final status = userData['status'] as String? ?? 'approved';

      if (status != 'approved') {
        await firebaseAuth.signOut();
        throw UserUnapprovedException();
      }

      return UserModel.fromFirestore(userData, user.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(code: e.code, message: e.message ?? 'Authentication failed. Please try again.');
    }
  }

  @override
  Future<UserModel> registerWithEmail({required String name, required String email, required String password}) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw AuthException(code: 'registration-failed', message: 'Registration failed. Please try again.');
      }

      await user.updateDisplayName(name);

      // Role MUST be 'user' -- enforced by Firestore security rules
      // to prevent privilege escalation to 'admin'
      final userModel = UserModel(
        id: user.uid,
        email: email,
        name: name,
        role: 'user',
        status: 'approved',
        createdAt: DateTime.now().toIso8601String(),
      );

      await firestore.collection('users').doc(user.uid).set(userModel.toFirestore());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(code: e.code, message: e.message ?? 'Registration failed. Please try again.');
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(code: e.code, message: e.message ?? 'Failed to send reset email.');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(code: e.code, message: e.message ?? 'Logout failed. Please try again.');
    }
  }

  @override
  Future<void> deleteAccount({required String password}) async {
    final user = firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw AuthException(code: 'no-user', message: 'No user is currently signed in.');
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      final uid = user.uid;

      // Delete Firestore data BEFORE deleting auth user
      await firestore.collection('users').doc(uid).delete().catchError((_) {});
      await firestore.collection('carts').doc(uid).delete().catchError((_) {});

      final orders = await firestore
          .collection('orders')
          .where('userId', isEqualTo: uid)
          .get();
      for (final doc in orders.docs) {
        await doc.reference.delete().catchError((_) {});
      }

      final notifications = await firestore
          .collection('notifications')
          .where('userId', isEqualTo: uid)
          .get();
      for (final doc in notifications.docs) {
        await doc.reference.delete().catchError((_) {});
      }

      await user.delete();
      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(code: e.code, message: e.message ?? 'Failed to delete account.');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw AuthException(code: 'no-user', message: 'No user is currently signed in.');
    }
    await user.sendEmailVerification();
  }

  @override
  Future<bool> checkEmailVerified() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return false;
    await user.reload();
    return firebaseAuth.currentUser?.emailVerified ?? false;
  }
}
