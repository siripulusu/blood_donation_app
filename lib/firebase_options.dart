
import 'package:firebase_core/firebase_core.dart';
// Remove the import of 'firebase_options.dart' to avoid self-import error

// Add the DefaultFirebaseOptions class definition here or import it from the correct file if it exists elsewhere

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Replace the following with your actual Firebase configuration
    return const FirebaseOptions(
      apiKey: 'YOUR_API_KEY',
      appId: 'YOUR_APP_ID',
      messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
      projectId: 'YOUR_PROJECT_ID',
    );
  }
}

class FirebaseInitializer {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}