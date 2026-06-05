import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleSignInInitialized = false;
  // Web OAuth client from android/app/google-services.json.
  static const String _googleServerClientId =
      '342102069999-3bgjnskup05qasc4liemq1eknh4o6bc7.apps.googleusercontent.com';

  Future<UserCredential> signUp(String email, String password, String username) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'unknown',
        message: 'User creation failed.',
      );
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      try {
        await user.delete();
      } catch (_) {
        // If rollback fails, we still want the original profile-save error to surface.
      }
      rethrow;
    }

    return credential;
  }

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      await _ensureGoogleSignInInitialized();

      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'unknown',
          message: 'Google sign-in failed.',
        );
      }

      try {
        await _upsertGoogleProfile(
          user: user,
          displayName: googleUser.displayName,
          email: googleUser.email,
          photoUrl: googleUser.photoUrl,
        );
      } catch (_) {
        await _auth.signOut();
        await _googleSignIn.signOut();
        rethrow;
      }

      return userCredential;
    } on GoogleSignInException catch (error) {
      final message = _googleSignInErrorMessage(error);
      debugPrint('Google sign-in error: $error');
      throw FirebaseAuthException(
        code: error.code == GoogleSignInExceptionCode.canceled
            ? 'sign_in_canceled'
            : error.code == GoogleSignInExceptionCode.clientConfigurationError
                ? 'sign_in_config_error'
                : 'sign_in_failed',
        message: message,
      );
    } catch (error, stackTrace) {
      debugPrint('Unexpected Google sign-in failure: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw FirebaseAuthException(
        code: 'sign_in_failed',
        message: 'Google sign-in failed: $error',
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;

    await _googleSignIn.initialize(
      serverClientId: defaultTargetPlatform == TargetPlatform.android
          ? _googleServerClientId
          : null,
    );
    _googleSignInInitialized = true;
  }

  String _googleSignInErrorMessage(GoogleSignInException error) {
    switch (error.code) {
      case GoogleSignInExceptionCode.canceled:
        return error.description ?? 'Google sign-in was cancelled.';
      case GoogleSignInExceptionCode.clientConfigurationError:
        return error.description ??
            'Google sign-in is not fully configured for Android. '
            'Check that the app has the correct Firebase Android config, '
            'that Google sign-in is enabled in Firebase Authentication, '
            'and that the Android SHA-1/SHA-256 fingerprints are registered.';
      case GoogleSignInExceptionCode.providerConfigurationError:
        return error.description ??
            'Google sign-in provider configuration is invalid. '
            'Check the Firebase and Google Cloud setup for this app.';
      case GoogleSignInExceptionCode.uiUnavailable:
        return error.description ??
            'Google sign-in could not open its sign-in UI.';
      case GoogleSignInExceptionCode.interrupted:
        return error.description ??
            'Google sign-in was interrupted before it could finish.';
      case GoogleSignInExceptionCode.userMismatch:
        return error.description ??
            'The signed-in Google account does not match the current user.';
      case GoogleSignInExceptionCode.unknownError:
        return error.description ?? 'Google sign-in failed.';
    }
  }

  Future<void> _upsertGoogleProfile({
    required User user,
    required String email,
    String? displayName,
    String? photoUrl,
  }) async {
    final trimmedDisplayName = displayName?.trim();
    final username = trimmedDisplayName != null && trimmedDisplayName.isNotEmpty
        ? trimmedDisplayName
        : _emailPrefix(email);

    final profile = <String, dynamic>{
      'uid': user.uid,
      'email': email,
      'username': username,
      'provider': 'google',
      'lastLoginAt': FieldValue.serverTimestamp(),
    };

    if (photoUrl != null && photoUrl.isNotEmpty) {
      profile['photoURL'] = photoUrl;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(profile, SetOptions(merge: true));
  }

  String _emailPrefix(String email) {
    final prefix = email.split('@').first.trim();
    return prefix.isEmpty ? 'Guest' : prefix;
  }
}
