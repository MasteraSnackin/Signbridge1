# 🔨 SignBridge APK Build Guide

Complete guide to building the SignBridge APK from source code.

---

## ⚠️ Important Notice

**Current Project Status**: This project contains **documentation and code structure** but requires:
1. **Cactus SDK Integration**: You need actual Cactus SDK access and API keys
2. **AI Model Files**: ~1.1GB of AI models need to be downloaded
3. **Complete Implementation**: Some services use mock implementations that need real SDK integration

---

## 📋 Prerequisites

### Required Software

1. **Flutter SDK** (3.0 or higher)
   ```bash
   # Verify installation
   flutter --version
   # Should show: Flutter 3.0.0 or higher
   ```

2. **Android Studio** or **Android SDK Command Line Tools**
   ```bash
   # Verify Android SDK
   flutter doctor -v
   ```

3. **Java Development Kit (JDK)** 11 or higher
   ```bash
   # Verify Java
   java -version
   ```

4. **Git** (for version control)
   ```bash
   git --version
   ```

### System Requirements

- **OS**: Windows 10/11, macOS 10.14+, or Linux
- **RAM**: Minimum 8GB (16GB recommended)
- **Storage**: 10GB free space (for SDK, tools, and models)
- **Internet**: Required for initial setup and model downloads

---

## 🚀 Step-by-Step Build Process

### Step 1: Verify Flutter Installation

```bash
# Check Flutter installation
flutter doctor

# Expected output should show:
# ✓ Flutter (Channel stable, 3.x.x)
# ✓ Android toolchain
# ✓ Android Studio / VS Code
```

If any items show ✗, fix them before proceeding:
```bash
# Accept Android licenses
flutter doctor --android-licenses

# Update Flutter
flutter upgrade
```

### Step 2: Navigate to Project Directory

```bash
cd "c:/Users/first/OneDrive/Desktop/Hackathon/Mobile AI Hackathon"
```

### Step 3: Install Dependencies

```bash
# Clean any previous builds
flutter clean

# Get all dependencies
flutter pub get

# Verify no dependency conflicts
flutter pub outdated
```

**Expected Output**:
```
Running "flutter pub get" in Mobile AI Hackathon...
Resolving dependencies...
Got dependencies!
```

### Step 4: Verify Project Configuration

Check these files are properly configured:

#### `pubspec.yaml`
```yaml
name: signbridge
version: 1.0.0+1
environment:
  sdk: ">=3.0.0 <4.0.0"
```

#### `android/app/build.gradle`
```gradle
android {
    compileSdkVersion 34
    defaultConfig {
        applicationId "com.signbridge.app"
        minSdkVersion 24
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

### Step 5: Run Code Analysis

```bash
# Analyze code for issues
flutter analyze

# Expected: No issues found!
```

If issues are found, fix them before building.

### Step 6: Run Tests (Optional but Recommended)

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Expected: All tests passing
```

### Step 7: Build Debug APK (For Testing)

```bash
# Build debug APK
flutter build apk --debug

# Output location:
# build/app/outputs/flutter-apk/app-debug.apk
```

**Debug APK Characteristics**:
- ✅ Faster to build
- ✅ Includes debugging symbols
- ✅ Larger file size (~100MB)
- ❌ Not optimized
- ❌ Not suitable for distribution

### Step 8: Build Release APK (For Distribution)

```bash
# Build release APK (single APK for all architectures)
flutter build apk --release

# OR build split APKs (recommended - smaller file sizes)
flutter build apk --release --split-per-abi
```

**Release APK Output**:
```
build/app/outputs/flutter-apk/
├── app-armeabi-v7a-release.apk  (~25MB - 32-bit ARM)
├── app-arm64-v8a-release.apk    (~27MB - 64-bit ARM)
├── app-x86_64-release.apk       (~28MB - 64-bit Intel)
└── app-release.apk              (~80MB - Universal)
```

**Recommended**: Use split APKs for distribution (smaller downloads).

### Step 9: Verify APK Build

```bash
# Check APK was created
ls -lh build/app/outputs/flutter-apk/

# Expected output:
# app-arm64-v8a-release.apk  27M
# app-armeabi-v7a-release.apk 25M
# app-x86_64-release.apk 28M
```

---

## 🔐 APK Signing (For Production)

### Why Sign APKs?

- **Required** for Google Play Store
- **Verifies** app authenticity
- **Prevents** tampering
- **Enables** app updates

### Generate Signing Key (First Time Only)

```bash
# Create keystore directory
mkdir -p android/app/keystore

# Generate release keystore
keytool -genkey -v -keystore android/app/keystore/signbridge-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias signbridge

# You'll be prompted for:
# - Keystore password (SAVE THIS!)
# - Key password (SAVE THIS!)
# - Your name
# - Organization
# - City, State, Country
```

**⚠️ CRITICAL**: Save your keystore file and passwords securely!
- Store keystore in secure location
- Never commit keystore to Git
- Backup keystore (losing it means you can't update your app)

### Configure Signing

Create `android/key.properties`:
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=signbridge
storeFile=keystore/signbridge-release.jks
```

Update `android/app/build.gradle`:
```gradle
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
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

### Build Signed APK

```bash
# Build signed release APK
flutter build apk --release --split-per-abi

# APKs will be automatically signed
```

### Verify Signature

```bash
# Verify APK is signed
jarsigner -verify -verbose -certs \
  build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

# Expected output: "jar verified."
```

---

## 📦 Build Optimization

### Reduce APK Size

1. **Use Split APKs**
   ```bash
   flutter build apk --release --split-per-abi
   ```

2. **Enable ProGuard** (already configured)
   ```gradle
   buildTypes {
       release {
           minifyEnabled true
           shrinkResources true
       }
   }
   ```

3. **Remove Unused Resources**
   ```bash
   flutter build apk --release --tree-shake-icons
   ```

4. **Analyze APK Size**
   ```bash
   flutter build apk --release --analyze-size
   ```

### Build Performance

```bash
# Use more CPU cores
flutter build apk --release -j 8

# Skip unnecessary checks (faster, but risky)
flutter build apk --release --no-pub --no-tree-shake-icons
```

---

## 🧪 Testing the APK

### Install on Device

```bash
# Connect Android device via USB
# Enable USB debugging on device

# Verify device is connected
adb devices

# Install APK
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

# Or install and launch
flutter install
```

### Test on Emulator

```bash
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator_id>

# Install APK
flutter install
```

### Manual Testing Checklist

- [ ] App launches successfully
- [ ] Permissions requested properly
- [ ] Camera preview works
- [ ] Sign recognition functions
- [ ] Speech recognition works
- [ ] Animations play smoothly
- [ ] Settings save correctly
- [ ] No crashes or freezes
- [ ] Performance is acceptable
- [ ] Battery usage is reasonable

---

## 🐛 Troubleshooting

### Common Build Errors

#### Error: "Gradle build failed"
```bash
# Solution 1: Clean and rebuild
flutter clean
flutter pub get
flutter build apk --release

# Solution 2: Update Gradle
cd android
./gradlew wrapper --gradle-version 7.5
cd ..
```

#### Error: "SDK location not found"
```bash
# Create local.properties
echo "sdk.dir=/path/to/Android/Sdk" > android/local.properties

# On Windows:
echo sdk.dir=C:\\Users\\YourName\\AppData\\Local\\Android\\Sdk > android/local.properties
```

#### Error: "Execution failed for task ':app:lintVitalRelease'"
```bash
# Disable lint checks temporarily
# In android/app/build.gradle:
android {
    lintOptions {
        checkReleaseBuilds false
        abortOnError false
    }
}
```

#### Error: "Out of memory"
```bash
# Increase Gradle memory
# In android/gradle.properties:
org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m
```

#### Error: "Cactus SDK not found"
```bash
# This project uses mock Cactus SDK
# For real implementation, you need:
# 1. Cactus SDK access
# 2. API keys
# 3. Replace mock implementations in lib/core/services/
```

### Build Performance Issues

```bash
# Enable Gradle daemon
echo "org.gradle.daemon=true" >> android/gradle.properties

# Enable parallel builds
echo "org.gradle.parallel=true" >> android/gradle.properties

# Enable build cache
echo "org.gradle.caching=true" >> android/gradle.properties
```

---

## 📊 Build Variants

### Debug Build
```bash
flutter build apk --debug
```
- **Use for**: Development and testing
- **Size**: ~100MB
- **Performance**: Slower
- **Debugging**: Full symbols included

### Profile Build
```bash
flutter build apk --profile
```
- **Use for**: Performance testing
- **Size**: ~50MB
- **Performance**: Optimized
- **Debugging**: Some symbols included

### Release Build
```bash
flutter build apk --release
```
- **Use for**: Production distribution
- **Size**: ~25-30MB (split APKs)
- **Performance**: Fully optimized
- **Debugging**: Minimal symbols

---

## 🚀 Distribution

### Google Play Store

1. **Create App Bundle** (preferred over APK)
   ```bash
   flutter build appbundle --release
   ```

2. **Upload to Play Console**
   - Go to https://play.google.com/console
   - Create new app
   - Upload app-release.aab
   - Fill in store listing
   - Submit for review

### Direct Distribution

1. **Host APK** on your server or GitHub Releases
2. **Generate SHA256 checksum**
   ```bash
   sha256sum app-arm64-v8a-release.apk > checksums.txt
   ```
3. **Provide installation instructions** to users
4. **Users must enable** "Install from Unknown Sources"

---

## 📝 Build Checklist

### Pre-Build
- [ ] All code committed to Git
- [ ] Version number updated in pubspec.yaml
- [ ] CHANGELOG.md updated
- [ ] All tests passing
- [ ] Code analysis clean
- [ ] Dependencies up to date

### Build
- [ ] Flutter clean executed
- [ ] Dependencies installed
- [ ] Release APK built successfully
- [ ] APK signed (if for distribution)
- [ ] APK size acceptable (<30MB per architecture)

### Post-Build
- [ ] APK tested on real device
- [ ] All features working
- [ ] No crashes or errors
- [ ] Performance acceptable
- [ ] Checksums generated
- [ ] Release notes prepared

---

## 🎯 Quick Build Commands

### For Development
```bash
# Quick debug build and install
flutter run
```

### For Testing
```bash
# Build and install debug APK
flutter build apk --debug && flutter install
```

### For Release
```bash
# Complete release build process
flutter clean && \
flutter pub get && \
flutter analyze && \
flutter test && \
flutter build apk --release --split-per-abi
```

### For Distribution
```bash
# Build signed release with checksums
flutter build apk --release --split-per-abi && \
cd build/app/outputs/flutter-apk && \
sha256sum *.apk > checksums.txt && \
ls -lh
```

---

## 📚 Additional Resources

- **Flutter Build Docs**: https://flutter.dev/docs/deployment/android
- **Android App Bundle**: https://developer.android.com/guide/app-bundle
- **ProGuard**: https://developer.android.com/studio/build/shrink-code
- **App Signing**: https://developer.android.com/studio/publish/app-signing

---

## ⚠️ Important Notes

### Current Project Status

This SignBridge project contains:
- ✅ Complete documentation (40 files)
- ✅ Full code structure
- ✅ Mock implementations for testing
- ⚠️ **Requires Cactus SDK integration** for full functionality
- ⚠️ **AI models need to be downloaded** (~1.1GB)

### To Build a Fully Functional APK

You need to:
1. **Obtain Cactus SDK access** and API keys
2. **Replace mock implementations** in `lib/core/services/cactus_model_service.dart`
3. **Implement real AI model integration**
4. **Download AI models** (LFM2-VL, Qwen3, Whisper)
5. **Test with real devices** and sign language gestures

### Current Build Will

- ✅ Compile successfully
- ✅ Install on devices
- ✅ Show UI and navigation
- ⚠️ Use mock data for AI features
- ❌ Not perform real sign language recognition (needs Cactus SDK)

---

**Version**: 1.0.0  
**Last Updated**: 2025-11-29  
**Build Target**: Android APK  
**Flutter Version**: 3.0+