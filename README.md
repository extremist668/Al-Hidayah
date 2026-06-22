# Al-Hidayah Islamic Android Application (Flutter & Supabase)

A production-grade, highly scalable, offline-first, multilingual Islamic companion application built with Flutter, Riverpod, Hive local storage, and Supabase database authentication and real-time syncing.

---

## 🛠️ Tech Stack & Architecture

- **Frontend:** Flutter (Latest Stable SDK) & Dart
- **State Management:** Riverpod (Notifier/StateNotifier pattern)
- **Local Cache (Offline-first):** Hive & Hive Flutter (encrypted secure store support)
- **Backend Service:** Supabase (Auth, PostgreSQL DB, Row Level Security)
- **Location & Sensors:** Geolocator (GPS location detection), Flutter Compass (Offline Qibla calculations)
- **Notifications & Background Alarms:** Flutter Local Notifications & Workmanager
- **CI/CD Automation:** GitHub Actions (APK / AAB Auto-Release Build Pipeline)

---

## 📂 Project Structure

```bash
lib/
├── config/              # Safe application credentials, constants, and API configurations
├── core/                # Core theme palettes, global styling, database initialization, and shared styles
├── localization/        # Multi-language engines, RTL switches, and dynamic translation loaders
├── services/            # Base APIs, GPS/geolocator hooks, and notification handlers
├── models/              # Clean data mapping models
└── features/            # Feature-first modular components (Authentication, Prayer Tracker, Quran, Ramadan, Zakat)
    ├── auth/            # Sign in / Signup screen & Supabase session hooks
    ├── dashboard/       # Primary summary metric widgets & beautiful Islamic landing interface
    ├── prayer_times/    # Real-time calculation calendars & Aladhan API sync
    ├── prayer_tracker/  # Completion logs, streak computations, and qaza counts
    ├── qibla/           # Sensor calibration, direction math, & compass layout
    ├── quran/           # Reading logger, bookmark systems, & progression metrics
    ├── ramadan/         # 30-Day fasting diaries, charity trackers, and specific duas
    ├── zakat/           # Input panels, gold/silver nisab thresholds, & logs history
    └── settings/        # Language pickers, light/dark modes, and profiles config
```

---

## 🚀 Setup Instructions

### 1. Database Setup (Supabase)
To run the authenticated syncing feature, copy and run the complete SQL Script located in `supabase/schema.sql` into your Supabase Dashboard SQL Editor. It automates:
- Profile generation triggers upon sign-up.
- Secure Row Level Security (RLS) policies for each table.
- Composite index optimization for ultra-fast sync lookups.

### 2. Configure Credentials
Open `lib/config/app_config.dart` and insert your Supabase project credentials:
```dart
static const String supabaseUrl = 'https://your-supabase-url.supabase.co';
static const String supabaseAnonKey = 'your-supabase-anon-key-here';
```

### 3. Localization Assets
Add JSON localization files to your assets folder:
- `assets/locales/en.json`
- `assets/locales/ur.json`
- `assets/locales/ar.json`

*(These translations are already pre-generated and available in the repository!)*

### 4. Background Azan Sounds Configuration
To play custom background notifications for Azan, place your desired audio file (e.g. `azan_sound.mp3` or `.wav`) inside the Android platform folder:
`android/app/src/main/res/raw/azan_sound.mp3`

---

## 🔨 Running the Application

Fetch dependencies:
```bash
flutter pub get
```

Run compilation tools:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Start testing & running:
```bash
flutter run
```

---

## 📦 Building Production APK & AAB

The workspace includes custom GitHub Actions pipeline files (`.github/workflows/flutter_ci_cd.yml`) that automatically perform:
- Code health linting and analyzing (`flutter analyze`).
- Dynamic unit testing executions.
- Auto-compiles individual ABIs of **Release APK** and **Release Android App Bundle (AAB)** and uploads them directly to your repository's actions runner.
