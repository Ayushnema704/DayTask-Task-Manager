import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todoapp/features/auth/data/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:todoapp/config/auth_config.dart';

class AuthService {
  final SupabaseClient supabaseClient;

  AuthService(this.supabaseClient);

  Future<UserModel?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        return UserModel(
          id: response.user!.id,
          email: response.user!.email!,
        );
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        return UserModel(
          id: response.user!.id,
          email: response.user!.email!,
        );
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: AuthConfig.redirectUrl,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  UserModel? get currentUser {
    final user = supabaseClient.auth.currentUser;
    if (user != null) {
      return UserModel(
        id: user.id,
        email: user.email!,
      );
    }
    return null;
  }
} 