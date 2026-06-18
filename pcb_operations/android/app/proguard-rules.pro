# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Keep custom models used with reflection/serialization
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
