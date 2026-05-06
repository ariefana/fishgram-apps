# FishGram — Angler Social Media App 🎣

Aplikasi media sosial khusus komunitas pemancing Indonesia. Upload, pamer, dan bagikan hasil tangkapan ikanmu!

## 📱 Fitur

- **Auth Flow**: Splash → Login → Register → Onboarding → Main
- **Feed**: Timeline tangkapan dari pengguna lain (pull-to-refresh, infinite scroll)
- **Create Post**: Upload foto tangkapan dengan info jenis ikan, berat, umpan
- **Search**: Cari teman pemancing berdasarkan nama/username, filter jenis memancing
- **Notifications**: Like, komentar, follow, permintaan pertemanan
- **Profile**: Avatar, bio, statistik, riwayat tangkapan, edit profil
- **Catch Detail**: Foto fullscreen (zoomable), komentar, like/bookmark

## 🏗️ Arsitektur

```
lib/
├── main.dart           # Entry point + MultiProvider setup
├── app.dart            # Root MaterialApp with auth-state routing
├── config/             # Theme, constants
├── models/             # Data models (User, Catch, Comment, Notification)
├── providers/          # State management (ChangeNotifier + Provider)
├── services/           # API, Auth (mock), MockData, Storage
├── screens/            # All screen widgets
└── widgets/            # Reusable shared widgets
```

- **State Management**: Provider + ChangeNotifier
- **Auth**: Mock Auth Service (Firebase-ready)
- **Data**: Mock JSON files in `assets/mock/`
- **Theme**: Material 3 — Ocean Blue / Forest Green palette

## 🚀 Setup & Run

### Prerequisites
- Flutter SDK 3.11+
- Dart 3.x
- Android Studio / VS Code with Flutter extension
- Android emulator or iOS simulator

### Steps

```bash
# 1. Clone / navigate to project
cd fishgram_app

# 2. Install dependencies
flutter pub get

# 3. Run on emulator
flutter run

# 4. Run on Chrome (web)
flutter run -d chrome
```

## 🔧 Firebase Configuration (Future)

The app currently uses **mock auth** — no Firebase setup needed.

When ready for Firebase:
1. Create Firebase project at https://console.firebase.google.com
2. Add Android/iOS apps
3. Download `google-services.json` (Android) / `GoogleService-Info.plist` (iOS)
4. Add `firebase_auth` and `firebase_core` packages
5. Replace `AuthService` mock with real Firebase Auth calls

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `go_router` | Navigation (ready, currently using named routes) |
| `http` | HTTP client for API calls |
| `shared_preferences` | Local storage |
| `image_picker` | Camera & gallery photo selection |
| `cached_network_image` | Image loading with cache |
| `photo_view` | Zoomable image viewer |
| `shimmer` | Loading skeletons |
| `google_fonts` | Poppins typography |
| `intl` | Date formatting |

## 📄 License

Private project — not for public distribution.
