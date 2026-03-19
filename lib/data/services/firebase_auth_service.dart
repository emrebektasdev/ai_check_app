import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Initialize with serverClientId (mandatory for Android in 7.0+ for Firebase)
      await _googleSignIn.initialize(
        serverClientId: '934618507565-aloadi5tok04qkmn57l999t8cmls7bu8.apps.googleusercontent.com',
      );

      // Trigger the authentication flow
      final googleUser = await _googleSignIn.authenticate();

      // Obtain the auth details
      // In 7.0, authentication appears to be a direct getter in some contexts 
      // but let's see what the analyzer says after this change.
      final googleAuth = googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        // accessToken is now obtained via authorizationClient if needed, 
        // but idToken is usually sufficient for Firebase Identity.
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  Future<void> signOut() async {
    // In 7.0, signOut() still exists on the instance
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
