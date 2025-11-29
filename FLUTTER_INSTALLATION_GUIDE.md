# 🚀 Flutter Installation Guide for SignBridge

Complete guide to installing Flutter SDK and building SignBridge APK on Windows.

---

## 📋 System Requirements

- **OS**: Windows 10 or later (64-bit)
- **Disk Space**: 2.5 GB (not including IDE/tools)
- **RAM**: 8 GB minimum (16 GB recommended)
- **Tools**: Git for Windows, PowerShell 5.0 or newer

---

## 🔧 Step 1: Install Flutter SDK

### Download Flutter

1. **Visit Flutter website**: https://flutter.dev/docs/get-started/install/windows
2. **Download** the latest stable release (Flutter SDK)
3. **Extract** the zip file to `C:\flutter` (or your preferred location)

**Direct Download Link**: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip

### Add Flutter to PATH

1. **Open System Environment Variables**:
   - Press `Win + X` and select "System"
   - Click "Advanced system settings"
   - Click "Environment Variables"

2. **Edit PATH**:
   - Under "User variables", find "Path"
   - Click "Edit"
   - Click "New"
   - Add: `C:\flutter\bin`
   - Click "OK" on all dialogs

3. **Verify Installation**:
   ```cmd
   # Open new Command Prompt
   flutter --version
   ```

   Expected output:
   ```
   Flutter 3.16.0 • channel stable
   Framework • revision ...
   Engine • revision ...
   Tools • Dart 3.2.0 • DevTools 2.28.0
   ```

---

## 🔧 Step 2: Install Android SDK

### Option A: Install Android Studio (Recommended)

1. **Download Android Studio**: https://developer.android.com/studio
2. **Install** with default settings
3. **Launch** Android Studio
4. **Complete** the setup wizard
5. **Install** Android SDK (API 34) and build tools

### Option B: Install Command Line Tools Only

1. **Download**: https://developer.android.com/studio#command-tools
2. **Extract** to `C:\Android\cmdline-tools`
3. **Set environment variables**:
   ```
   ANDROID_HOME=C:\Android
   PATH=%PATH%;%ANDROID_HOME%\cmdline-tools\latest\bin
   PATH=%PATH%;%ANDROID_HOME%\platform-tools
   ```

4. **Install SDK**:
   ```cmd
   sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
   ```

---

## 🔧 Step 3: Accept Android Licenses

```cmd
flutter doctor --android-licenses
```

Press `y` to accept all licenses.

---

## 🔧 Step 4: Verify Installation

```cmd
flutter doctor -v
```

Expected output:
```
[✓] Flutter (Channel stable, 3.16.0)
[✓] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
[✓] Chrome - develop for the web
[✓] Visual Studio - develop for Windows
[✓] Android Studio (version 2023.1)
[✓] VS Code (version 1.85)
[✓] Connected device (1 available)
[✓] Network resources
```

Fix any issues marked with `[✗]` before proceeding.

---

## 🚀 Step 5: Build SignBridge APK

### Quick Build (Automated)

1. **Navigate to project**:
   ```cmd
   cd "c:\Users\first\OneDrive\Desktop\Hackathon\Mobile AI Hackathon"
   ```

2. **Run build script**:
   ```cmd
   setup_and_build.bat
   ```

   This will:
   - Clean previous builds
   - Install dependencies
   - Run tests
   - Build debug APK
   - Build release APK
   - Generate checksums

### Manual Build

```cmd
# Navigate to project
cd "c:\Users\first\OneDrive\Desktop\Hackathon\Mobile AI Hackathon"

# Clean
flutter clean

# Get dependencies
flutter pub get

# Build debug APK
flutter build apk --debug

# Build release APK (split by architecture)
flutter build apk --release --split-per-abi
```

---

## 📱 Step 6: Install APK on Device

### Via USB Cable

1. **Enable Developer Options** on Android device:
   - Go to Settings > About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings > Developer Options
   - Enable "USB Debugging"

2. **Connect device** via USB

3. **Verify connection**:
   ```cmd
   adb devices
   ```

4. **Install APK**:
   ```cmd
   adb install build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
   ```

### Via File Transfer

1. **Copy APK** to device:
   - Connect device via USB
   - Copy `app-arm64-v8a-release.apk` to device storage

2. **Install on device**:
   - Open file manager on device
   - Navigate to APK file
   - Tap to install
   - Enable "Install from Unknown Sources" if prompted

---

## 🐛 Troubleshooting

### Flutter Not Recognized

**Problem**: `'flutter' is not recognized as an internal or external command`

**Solution**:
1. Verify Flutter is extracted to `C:\flutter`
2. Check PATH environment variable includes `C:\flutter\bin`
3. Restart Command Prompt
4. Run `flutter doctor`

### Android SDK Not Found

**Problem**: `Android SDK not found`

**Solution**:
1. Install Android Studio or Command Line Tools
2. Set `ANDROID_HOME` environment variable
3. Run `flutter doctor --android-licenses`
4. Run `flutter doctor` to verify

### Gradle Build Failed

**Problem**: `Gradle build failed with exit code 1`

**Solution**:
```cmd
cd android
gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

### Out of Memory

**Problem**: `Out of memory error during build`

**Solution**:
1. Edit `android\gradle.properties`
2. Add: `org.gradle.jvmargs=-Xmx4096m`
3. Rebuild

### Device Not Detected

**Problem**: `adb devices` shows no devices

**Solution**:
1. Enable USB Debugging on device
2. Install device drivers (if Windows)
3. Try different USB cable/port
4. Run `adb kill-server` then `adb start-server`

---

## 📊 Build Output

After successful build, you'll find APKs in:
```
build\app\outputs\flutter-apk\
├── app-arm64-v8a-release.apk    (~27MB) - 64-bit ARM (most devices)
├── app-armeabi-v7a-release.apk  (~25MB) - 32-bit ARM (older devices)
├── app-x86_64-release.apk       (~28MB) - Intel/AMD (emulators)
└── app-debug.apk                (~100MB) - Debug build
```

**Recommended**: Use `app-arm64-v8a-release.apk` for most modern Android devices.

---

## 🎯 Quick Reference

### Essential Commands

```cmd
# Check Flutter installation
flutter doctor

# Update Flutter
flutter upgrade

# Clean project
flutter clean

# Get dependencies
flutter pub get

# Run app on connected device
flutter run

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release --split-per-abi

# Install on device
adb install path\to\app.apk

# Check connected devices
adb devices

# View device logs
adb logcat
```

---

## 📚 Additional Resources

- **Flutter Documentation**: https://flutter.dev/docs
- **Android Studio**: https://developer.android.com/studio
- **Flutter Samples**: https://flutter.dev/docs/cookbook
- **Dart Language**: https://dart.dev/guides
- **Stack Overflow**: https://stackoverflow.com/questions/tagged/flutter

---

## ⏱️ Estimated Time

- **Flutter Installation**: 30-60 minutes
- **Android SDK Setup**: 20-30 minutes
- **First Build**: 10-15 minutes
- **Subsequent Builds**: 2-5 minutes

---

## ✅ Installation Checklist

- [ ] Downloaded Flutter SDK
- [ ] Extracted to C:\flutter
- [ ] Added to PATH
- [ ] Verified with `flutter --version`
- [ ] Installed Android Studio or SDK
- [ ] Accepted Android licenses
- [ ] Ran `flutter doctor` successfully
- [ ] All checks passed (✓)
- [ ] Built debug APK successfully
- [ ] Built release APK successfully
- [ ] Installed APK on device
- [ ] App launches successfully

---

## 🎉 Success!

Once all steps are complete, you'll have:
- ✅ Flutter SDK installed and configured
- ✅ Android development environment ready
- ✅ SignBridge APK built successfully
- ✅ App installed on your device

---

**Need Help?**
- Check the troubleshooting section above
- Review `APK_BUILD_GUIDE.md` for detailed build instructions
- Consult Flutter documentation
- Open an issue on GitHub

---

**Version**: 1.0.0  
**Last Updated**: 2025-11-29  
**Platform**: Windows 10/11  
**Flutter Version**: 3.16.0+