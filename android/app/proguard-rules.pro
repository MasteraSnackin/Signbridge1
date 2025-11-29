# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /usr/local/Cellar/android-sdk/24.3.3/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Keep Cactus SDK classes
-keep class com.cactus.** { *; }
-keepclassmembers class com.cactus.** { *; }
-dontwarn com.cactus.**

# Keep TensorFlow Lite classes
-keep class org.tensorflow.** { *; }
-keepclassmembers class org.tensorflow.** { *; }
-dontwarn org.tensorflow.**

# Keep PyTorch classes
-keep class org.pytorch.** { *; }
-keepclassmembers class org.pytorch.** { *; }
-dontwarn org.pytorch.**

# Keep Flutter classes
-keep class io.flutter.** { *; }
-keepclassmembers class io.flutter.** { *; }
-dontwarn io.flutter.**

# Keep camera plugin classes
-keep class io.flutter.plugins.camera.** { *; }
-keepclassmembers class io.flutter.plugins.camera.** { *; }

# Keep permission handler classes
-keep class com.baseflow.permissionhandler.** { *; }
-keepclassmembers class com.baseflow.permissionhandler.** { *; }

# Keep TTS classes
-keep class com.tencent.tts.** { *; }
-keepclassmembers class com.tencent.tts.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep model files
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Preserve line numbers for debugging
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile