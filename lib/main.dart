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

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
