import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthConfig {
  static const String _scheme = 'io.supabase.fluttertodo';
  
  static String get redirectUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/auth/callback';
    } else if (Platform.isAndroid) {
      return '$_scheme://login-callback';
    } else {
      return '$_scheme://login-callback';
    }
  }

  static String get siteUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    return 'io.supabase.fluttertodo://login-callback';
  }
} 