import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/auth_service.dart';
import 'services/mock_data_service.dart';
import 'services/storage_service.dart';
import 'providers/auth_provider.dart';
import 'providers/feed_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/search_provider.dart';
import 'providers/notification_provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,  
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
    
    // 2. Ambil Token
    String? token = await messaging.getToken();
    print("Token HP fisik: $token"); // Cek di Debug Console VS Code / Android Studio
  } else {
    print('User declined or has not accepted permission');
  }

  // Initialize services
  final authService = AuthService();
  final storageService = StorageService();
  final mockDataService = MockDataService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: authService,
            storageService: storageService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => FeedProvider(mockDataService: mockDataService),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(mockDataService: mockDataService),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchProvider(mockDataService: mockDataService),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(mockDataService: mockDataService),
        ),
      ],
      child: const FishGramApp(),
    ),
  );
}
