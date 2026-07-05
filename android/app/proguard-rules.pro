# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep line numbers and source file names for better stack traces in crash logs
-keepattributes SourceFile,LineNumberTable

# Preserve Javascript Interface for WebViews (youtube_player_flutter uses this)
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Preserve Flutter WebView plugin classes
-keep class io.flutter.plugins.webviewflutter.** { *; }

# Flutter Play Store Split Compat / Deferred Components warnings suppression
-dontwarn com.google.android.play.core.**
