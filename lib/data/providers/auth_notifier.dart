import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/firebase_auth_service.dart';
import '../services/firebase_database_service.dart';
import '../services/firebase_storage_service.dart';

// Provide the raw services
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

final firebaseDatabaseServiceProvider = Provider<FirebaseDatabaseService>((ref) {
  return FirebaseDatabaseService();
});

final firebaseStorageServiceProvider = Provider<FirebaseStorageService>((ref) {
  return FirebaseStorageService();
});

// Stream provider for the auth state directly from Firebase
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return authService.authStateChanges;
});

class AuthNotifier extends Notifier<AsyncValue<User?>> {
  late final FirebaseAuthService _authService;

  @override
  AsyncValue<User?> build() {
    _authService = ref.watch(firebaseAuthServiceProvider);
    
    // Listen to the auth state stream and update the state
    ref.listen<AsyncValue<User?>>(authStateProvider, (previous, next) {
      state = next;
    });
    
    // Return early stream value or loading
    return ref.read(authStateProvider);
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      await _authService.signInWithGoogle();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authService.signOut();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AsyncValue<User?>>(() {
  return AuthNotifier();
});
