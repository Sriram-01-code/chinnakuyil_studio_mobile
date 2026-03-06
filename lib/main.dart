import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/auth_screen.dart';
import 'screens/main_wrapper.dart';
import 'services/firebase_service.dart';
import 'services/mobile_storage_service.dart';
import 'services/app_update_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock orientation to standard Mobile Portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  // Note: For Android APK, it is highly recommended to have 
  // google-services.json in android/app/ folder.
  // Using manual options here with the correct Android App ID.
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBksk9vx1jy4IpnHbZLG5TFEsu7At_WSb0",
        authDomain: "chinnakuyil-studio.firebaseapp.com",
        projectId: "chinnakuyil-studio",
        storageBucket: "chinnakuyil-studio.firebasestorage.app",
        messagingSenderId: "1084471800255",
        appId: "1:1084471800255:android:b88a7b86664ed11f00f10a", // UPDATED: Android App ID
      ),
    );
  } catch (e) {
    debugPrint("Firebase already initialized or error: $e");
  }

  // Setup local services
  await MobileStorageService.initialize();
  await NotificationService.initialize();

  // Seed database and assets
  await FirebaseService.seedDatabase();
  await MobileStorageService.prebundleAssets();
  
  // Check for app updates
  await AppUpdateService.scheduleUpdateCheck();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..loadSession(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Chinnakuyil Studio',
        home: RootNavigator(),
      ),
    ),
  );
}

class RootNavigator extends StatelessWidget {
  const RootNavigator({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (!appState.isInitialized) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFB76E79),
                strokeWidth: 2,
              ),
            ),
          );
        }
        
        return appState.isAuthenticated ? const MainWrapper() : const AuthScreen();
      },
    );
  }
}
