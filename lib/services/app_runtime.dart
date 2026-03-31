import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppRuntime {
  static bool firebaseEnabled = false;
  static String geminiApiKey = '';

  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get firebaseAuthDomain =>
      dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';
  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseStorageBucket =>
      dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
  static String get firebaseMessagingSenderId =>
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  static String get firebaseAppId => dotenv.env['FIREBASE_APP_ID'] ?? '';
  static String get firebaseMeasurementId =>
      dotenv.env['FIREBASE_MEASUREMENT_ID'] ?? '';

  static String get googleCloudProjectId =>
      dotenv.env['GOOGLE_CLOUD_PROJECT_ID'] ?? '';
  static String get googleOauthWebClientId =>
      dotenv.env['GOOGLE_OAUTH_WEB_CLIENT_ID'] ?? '';
  static String get googleOauthAndroidClientId =>
      dotenv.env['GOOGLE_OAUTH_ANDROID_CLIENT_ID'] ?? '';
  static String get googleOauthIosClientId =>
      dotenv.env['GOOGLE_OAUTH_IOS_CLIENT_ID'] ?? '';

  static bool get aiEnabled => geminiApiKey.isNotEmpty;

  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // .env is optional in local/dev if values are passed differently.
    }

    const dartDefineGeminiKey = String.fromEnvironment('GEMINI_API_KEY');
    geminiApiKey = (dotenv.env['GEMINI_API_KEY'] ?? dartDefineGeminiKey).trim();

    try {
      await Firebase.initializeApp();
      firebaseEnabled = true;
    } catch (_) {
      firebaseEnabled = false;
    }
  }
}
