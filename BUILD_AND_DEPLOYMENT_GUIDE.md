# Build and Deployment Guide

Complete guide for building, testing, and deploying the SignBridge Android APK.

---

## 📋 Prerequisites

### Required Software
- Flutter SDK (3.0.0 or higher)
- Android Studio or VS Code
- Android SDK (API 24+)
- Java JDK 11 or higher
- Git

### Verify Installation
```bash
# Check Flutter installation
flutter doctor -v

# Expected output:
# [✓] Flutter (Channel stable, 3.x.x)
# [✓] Android toolchain - develop for Android devices
# [✓] Android Studio
# [✓] VS Code
# [✓] Connected device
```

---

## 🔧 Project Setup

### 1. Clone and Initialize
```bash
# Clone repository
git clone <repository-url>
cd signbridge

# Get dependencies
flutter pub get

# Verify project structure
flutter analyze
```

### 2. Configure Android

#### Update `android/app/build.gradle`
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.signbridge.app"
        minSdkVersion 24
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
        
        // Prevent model compression
        aaptOptions {
            noCompress "tflite"
            noCompress "onnx"
            noCompress "bin"
        }
    }
    
    // Enable multidex for large apps
    defaultConfig {
        multiDexEnabled true
    }
    
    buildTypes {
        release {
            // Signing config (see below)
            signingConfig signingConfigs.release
            
            // Optimization
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
        
        debug {
            signingConfig signingConfigs.debug
            minifyEnabled false
            shrinkResources false
        }
    }
    
    // Split APKs by ABI for smaller downloads
    splits {
        abi {
            enable true
            reset()
            include 'armeabi-v7a', 'arm64-v8a', 'x86_64'
            universalApk true
        }
    }
}

dependencies {
    implementation 'androidx.core:core:1.10.1'
    implementation 'androidx.multidex:multidex:2.0.1'
}
```

#### Create `android/app/proguard-rules.pro`
```proguard
# Keep Cactus SDK classes
-keep class com.cactus.** { *; }

# Keep Flutter classes
-keep class io.flutter.** { *; }

# Keep model files
-keep class **.tflite { *; }
-keep class **.onnx { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable implementations
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}
```

### 3. Generate Signing Key

#### Create Release Keystore
```bash
# Generate keystore
keytool -genkey -v -keystore ~/signbridge-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias signbridge

# You'll be prompted for:
# - Keystore password (save this!)
# - Key password (save this!)
# - Your name, organization, etc.
```

#### Create `android/key.properties`
```properties
storePassword=<your-keystore-password>
keyPassword=<your-key-password>
keyAlias=signbridge
storeFile=<path-to-keystore>/signbridge-release-key.jks
```

**⚠️ IMPORTANT**: Add `key.properties` to `.gitignore`!

#### Update `android/app/build.gradle` for Signing
```gradle
// Load keystore properties
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... other config
    
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
        }
    }
}
```

---

## 🏗️ Building the APK

### Development Build (Debug)
```bash
# Build debug APK
flutter build apk --debug

# Output: build/app/outputs/flutter-apk/app-debug.apk
# Size: ~100-150MB (includes debug symbols)
```

### Production Build (Release)
```bash
# Build release APK (all ABIs)
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
# Size: ~80-120MB

# Build split APKs (recommended)
flutter build apk --release --split-per-abi

# Outputs:
# - app-armeabi-v7a-release.apk (~40MB) - 32-bit ARM
# - app-arm64-v8a-release.apk (~45MB) - 64-bit ARM (most common)
# - app-x86_64-release.apk (~50MB) - Intel/AMD
# - app-release.apk (~120MB) - Universal (all ABIs)
```

### Build with Optimization Flags
```bash
# Maximum optimization
flutter build apk --release \
  --split-per-abi \
  --obfuscate \
  --split-debug-info=build/debug-info

# Flags explained:
# --split-per-abi: Create separate APKs for each CPU architecture
# --obfuscate: Obfuscate Dart code (makes reverse engineering harder)
# --split-debug-info: Extract debug symbols (for crash reporting)
```

### Build App Bundle (for Play Store)
```bash
# Build Android App Bundle
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
# Size: ~60-80MB (Google Play optimizes downloads)
```

---

## 🧪 Testing Builds

### 1. Install on Device
```bash
# Install debug build
flutter install

# Install specific release APK
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

# Install and launch
adb install -r app-release.apk && adb shell am start -n com.signbridge.app/.MainActivity
```

### 2. Test on Emulator
```bash
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator-id>

# Run app
flutter run --release
```

### 3. Verify APK Contents
```bash
# Analyze APK size
flutter build apk --analyze-size

# Extract APK contents
unzip -l build/app/outputs/flutter-apk/app-release.apk

# Check for model files
unzip -l app-release.apk | grep -E '\.(tflite|onnx|bin)$'
```

### 4. Performance Testing
```bash
# Profile release build
flutter run --profile

# Measure startup time
adb shell am start -W com.signbridge.app/.MainActivity

# Monitor memory usage
adb shell dumpsys meminfo com.signbridge.app

# Monitor CPU usage
adb shell top | grep signbridge
```

---

## 📦 Pre-Release Checklist

### Code Quality
- [ ] All tests pass: `flutter test`
- [ ] No analyzer warnings: `flutter analyze`
- [ ] Code formatted: `flutter format .`
- [ ] No debug prints in production code
- [ ] Error handling implemented
- [ ] Logging configured correctly

### Functionality
- [ ] Sign-to-Speech works offline
- [ ] Speech-to-Sign works offline
- [ ] Camera permissions granted
- [ ] Microphone permissions granted
- [ ] Models download successfully
- [ ] Animations play smoothly
- [ ] Settings persist correctly
- [ ] App handles errors gracefully

### Performance
- [ ] Frame rate ≥ 10 FPS
- [ ] Recognition latency < 200ms
- [ ] Memory usage < 500MB
- [ ] Battery drain < 10%/hour
- [ ] APK size < 150MB
- [ ] App starts in < 3 seconds

### UI/UX
- [ ] All screens render correctly
- [ ] Buttons respond to taps
- [ ] Loading indicators show
- [ ] Error messages are clear
- [ ] Dark mode works (if implemented)
- [ ] Landscape orientation works
- [ ] Accessibility features work

### Security
- [ ] No hardcoded secrets
- [ ] API keys secured
- [ ] Keystore not in repository
- [ ] ProGuard rules configured
- [ ] Code obfuscation enabled
- [ ] Debug info extracted

---

## 🚀 Deployment Options

### Option 1: Direct Distribution (Sideloading)

**Pros**: No app store approval needed, immediate distribution  
**Cons**: Users must enable "Unknown Sources", no automatic updates

```bash
# Share APK file directly
# Users install via:
# Settings → Security → Unknown Sources → Enable
# Then open APK file to install
```

### Option 2: Google Play Store

**Pros**: Wide reach, automatic updates, trusted source  
**Cons**: Review process, developer fee ($25 one-time)

#### Steps:
1. Create Google Play Developer account
2. Create app listing
3. Upload app bundle
4. Complete store listing (screenshots, description)
5. Submit for review

```bash
# Build app bundle
flutter build appbundle --release

# Upload to Play Console
# https://play.google.com/console
```

### Option 3: Alternative App Stores

- **Amazon Appstore**: Good for Fire devices
- **Samsung Galaxy Store**: Pre-installed on Samsung devices
- **F-Droid**: Open-source app store
- **APKPure**: Popular alternative store

### Option 4: Enterprise Distribution

For internal/hackathon use:

```bash
# Host APK on web server
# Share download link
# Users download and install
```

---

## 📊 Build Optimization

### Reduce APK Size

#### 1. Remove Unused Resources
```yaml
# pubspec.yaml
flutter:
  assets:
    # Only include needed animations
    - assets/animations/letters/
    # Don't include all word animations if not needed
```

#### 2. Compress Images
```bash
# Use WebP format for images
# Optimize PNGs with pngquant
pngquant --quality=65-80 input.png -o output.png
```

#### 3. Enable R8 Optimization
```gradle
// android/app/build.gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
    }
}
```

#### 4. Use Split APKs
```bash
# Generate separate APKs for each architecture
flutter build apk --release --split-per-abi

# Result: 3 APKs ~40-50MB each instead of 1 APK ~120MB
```

### Improve Build Speed

```bash
# Use cached builds
flutter build apk --release --no-pub

# Parallel builds
flutter build apk --release -j 8

# Skip unnecessary steps
flutter build apk --release --no-tree-shake-icons
```

---

## 🐛 Troubleshooting

### Build Fails

#### "Execution failed for task ':app:lintVitalRelease'"
```bash
# Disable lint checks
# android/app/build.gradle
android {
    lintOptions {
        checkReleaseBuilds false
        abortOnError false
    }
}
```

#### "Out of memory" during build
```bash
# Increase Gradle memory
# android/gradle.properties
org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m
```

#### "Unsupported class file major version"
```bash
# Update Java version
# Ensure using JDK 11 or higher
java -version
```

### Installation Fails

#### "App not installed"
```bash
# Uninstall old version first
adb uninstall com.signbridge.app

# Then install new version
adb install app-release.apk
```

#### "INSTALL_FAILED_INSUFFICIENT_STORAGE"
```bash
# Clear device storage
# Or use split APKs (smaller size)
```

### Runtime Issues

#### "Models not found"
```bash
# Verify models are in APK
unzip -l app-release.apk | grep -E '\.(tflite|onnx)$'

# Check asset paths in code
# Ensure paths match actual file locations
```

#### "Camera permission denied"
```bash
# Grant permissions manually
adb shell pm grant com.signbridge.app android.permission.CAMERA
adb shell pm grant com.signbridge.app android.permission.RECORD_AUDIO
```

---

## 📱 Device Testing Matrix

Test on various devices to ensure compatibility:

| Device Type | Android Version | Screen Size | Notes |
|-------------|----------------|-------------|-------|
| Pixel 6 | Android 13 | 6.4" | Reference device |
| Samsung S21 | Android 12 | 6.2" | Popular flagship |
| OnePlus 9 | Android 11 | 6.55" | High refresh rate |
| Xiaomi Redmi | Android 10 | 6.5" | Budget device |
| Tablet | Android 11 | 10.1" | Large screen |

---

## 🎯 Release Workflow

### Version Management
```yaml
# pubspec.yaml
version: 1.0.0+1
# Format: major.minor.patch+buildNumber
```

### Git Tagging
```bash
# Tag release
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

### Changelog
```markdown
# CHANGELOG.md

## [1.0.0] - 2024-01-15

### Added
- Sign-to-Speech translation
- Speech-to-Sign translation
- Offline AI models
- 36 ASL signs (A-Z, 0-9)
- 200+ word animations

### Fixed
- Camera permission handling
- Memory leaks in frame processing

### Changed
- Improved recognition accuracy
- Optimized battery usage
```

---

## 📈 Post-Release

### Monitor Crashes
```bash
# Use Firebase Crashlytics
dependencies:
  firebase_crashlytics: ^latest

# Or extract crash logs
adb logcat | grep signbridge
```

### Collect Feedback
- User reviews
- Analytics data
- Performance metrics
- Bug reports

### Plan Updates
- Fix critical bugs
- Add requested features
- Improve performance
- Update models

---

## 🔐 Security Best Practices

1. **Never commit**:
   - `key.properties`
   - Keystore files (`.jks`)
   - API keys
   - Passwords

2. **Use environment variables**:
   ```bash
   export SIGNBRIDGE_KEYSTORE_PASSWORD=xxx
   ```

3. **Enable ProGuard**:
   - Obfuscates code
   - Removes unused code
   - Makes reverse engineering harder

4. **Validate inputs**:
   - Check file paths
   - Validate user input
   - Sanitize data

---

## 📞 Support Resources

- Flutter Documentation: https://flutter.dev/docs
- Android Developer Guide: https://developer.android.com
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter
- Flutter Community: https://flutter.dev/community

---

**Build Status**: Ready for production  
**Estimated Build Time**: 5-10 minutes  
**APK Size**: 40-120MB (depending on configuration)