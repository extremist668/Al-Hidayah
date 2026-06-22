# Complete Android Publishing & Production Setup Guide: Al-Hidayah

This comprehensive guide takes you step-by-step from local development configuration to a successful live release on the **Google Play Store**.

---

## Part 1: Production Settings & Configuration

Before generating release builds, several crucial configurations must be completed to ensure native Android systems handle notifications, localization, and background services perfectly.

### 1. Rebranding & Package Name Customization
By default, the package name is typically `com.example.islamic_app`. For production, you must use a unique reverse-domain identifier (e.g., `com.yourdomain.alhidayah`).

#### Option A: Automated (Recommended)
Add `change_app_package_name` to your `pubspec.yaml` dev dependencies:
```yaml
dev_dependencies:
  change_app_package_name: ^1.1.0
```
Then run:
```bash
flutter pub get
flutter pub run change_app_package_name:main com.yourcompany.alhidayah
```

#### Option B: Manual File Updates
If you prefer updating manually, modify:
1. `android/app/build.gradle`: Change `namespace` and `applicationId`.
2. `android/app/src/main/AndroidManifest.xml`: Update the package attribute in `<manifest>` (and check package paths in Kotlin/Java main activities).

---

### 2. Native App Icons (`flutter_launcher_icons`)
To replace the default Flutter logo with a beautiful, themed App Icon:

1. Place your high-resolution icon (`app_icon.png`, min 1024x1024) inside `assets/images/`.
2. Add configuration to `pubspec.yaml`:
   ```yaml
   flutter_launcher_icons:
     android: "launcher_icon"
     image_path: "assets/images/app_icon.png"
     adaptive_icon_background: "#0F5132" # Primary Emerald Green
     adaptive_icon_foreground: "assets/images/app_icon.png"
   ```
3. Run the generator command:
   ```bash
   flutter pub run flutter_launcher_icons:main
   ```

---

### 3. Native Android Permissions (`AndroidManifest.xml`)
Islamic apps require special permissions to trigger exact Azan alarms, run background sync jobs via Workmanager, and query location sensors even when the screen is locked.

Add the following permissions inside your `<manifest>` tags in `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/xml/android">
    
    <!-- GPS & Location Access -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <!-- Precise Notification Timing (Critical for Android 13/14+) -->
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.USE_EXACT_ALARM" />
    
    <!-- Re-register Alarms after device reboot -->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    
    <!-- Internet & Network State -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    
    <application
        android:label="Al-Hidayah"
        android:icon="@mipmap/launcher_icon">
        
        <!-- Broadcast receiver to re-schedule Azan alarms on system boot up -->
        <receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>
        
    </application>
</manifest>
```

---

### 4. Custom Azan Audio Configuration
To trigger custom sounds for prayer times instead of the device's default beep:
1. Create a folder: `android/app/src/main/res/raw/`.
2. Place your high-quality, lightweight MP3 file inside and name it **exactly** `azan_sound.mp3` (use only lowercase letters and underscores).
3. `flutter_local_notifications` will automatically detect this sound resources channel.

---

### 5. Supabase Production Auth & RLS Settings
Before going live, secure your Supabase dashboard configuration:

1. **Email Auth Confirmations:** If you want users to register and verify, leave email confirmations on. If you want instant signups, turn off *Confirm email* under **Auth > Provider Settings > Email**.
2. **Setup Redirect URLs:** Add your custom Android scheme (e.g. `alhidayah://login-callback`) in **Auth > URL Configuration** to enable deep linking if Google Login or Magic Links are implemented.
3. **Database RLS Verification:** Ensure your `profiles`, `prayer_logs`, and other tables have **Row Level Security** active so that authenticated users can only write/read their *own* rows.

---

## Part 2: Android App Signing & Key Generation

Google Play requires all uploaded apps to be cryptographically signed with a secure, private keystore.

### Step 1: Generate the Keystore File
Open your terminal inside your computer and execute the native Java Keytool command:

#### On Windows (PowerShell/Command Prompt):
```powershell
keytool -genkey -v -keystore c:\Users\YOUR_USERNAME\upload-keystore.jks -storetype PKCS12 -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

#### On macOS / Linux:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -storetype PKCS12 -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

> ⚠️ **IMPORTANT WARNING:** Save your generated keystore (`.jks`) file in a safe, offline location. If you lose this key, you will never be able to update your app on the Play Store again.

---

### Step 2: Create `key.properties` for Security
To prevent pushing your password keys to GitHub, create a secret local file inside the `android/` directory of your project named `key.properties`.

Add the following variables to `android/key.properties`:
```properties
storePassword=your_keystore_password_here
keyPassword=your_key_password_here
keyAlias=upload
storeFile=/Users/YOUR_USERNAME/upload-keystore.jks
```
*(Make sure to append `key.properties` to your project's root `.gitignore` file to avoid security leaks).*

---

### Step 3: Update `android/app/build.gradle` to Sign Your Builds
Open `android/app/build.gradle` and modify it to read your keystore properties dynamically:

```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true      # Shrinks code for optimized app size
            shrinkResources true   # Cleans up unused assets
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

---

## Part 3: Compiling the Release App Bundle

Run the following commands to generate a lightweight, production-ready release file:

```bash
# 1. Clean build cache
flutter clean

# 2. Re-fetch clean dependencies
flutter pub get

# 3. Generate Android App Bundle (AAB is required for Play Store uploads)
flutter build appbundle --release
```

Your compiled bundle will be outputted to:
`build/app/outputs/bundle/release/app-release.aab`

---

## Part 4: Google Play Store Console Steps

Now that you have your secure `.aab` file, complete the setup steps inside your [Google Play Console](https://play.google.com/console/):

### Step 1: Create a New App
1. Log in to your Play Console account.
2. Click **Create app**.
3. Fill out basic details:
   - **App Name:** Al-Hidayah
   - **Default Language:** English (or Urdu/Arabic depending on target region)
   - **App Type:** App
   - **Free or Paid:** Free

### Step 2: Fill Out App Declarations & Policies
Google enforces strict checks on permissions. Fill out the following questionnaires:
- **Location Policy:** Declare that your app only accesses location in the **foreground** (while active) to calculate the Qibla bearing and local prayer times. (This avoids extensive background tracking reviews!).
- **Exact Alarm Declaration:** Since Al-Hidayah triggers alarms at scheduled prayer times (Azans), declare that your app belongs to the **Alarm/Clock** category using the `USE_EXACT_ALARM` permission to notify users of critical spiritual actions.
- **Data Safety:** Inform Google that user credentials and tracking logs are transmitted securely to Supabase over HTTPS, and that no profile info is sold to third parties.

### Step 3: Set Up Closed Testing (Crucial for New Personal Accounts)
*Google has updated its developer policy: New personal accounts must recruit at least **20 testers** to perform closed testing for a minimum of **14 consecutive days** before production applications can be released.*

1. Navigate to **Testing > Closed testing**.
2. Create a track and add a list of email addresses of your 20 testers.
3. Upload your `.aab` file to this track.
4. Once completed and verified for 14 days, the "Apply for Production" button will unlock!

### Step 4: Promote to Production & Go Live!
1. Go to **Release > Production**.
2. Click **Create new release**.
3. Import the release from your successful Closed Testing track.
4. Input details: **Release Name** (e.g., `1.0.0`) and **Release Notes** (e.g., *"Initial production release of Al-Hidayah with prayer tracking and Qibla finder"*).
5. Click **Save**, then **Review release**, and select **Start roll-out to Production**!
