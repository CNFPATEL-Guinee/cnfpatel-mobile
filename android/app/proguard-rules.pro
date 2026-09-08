# Regles de protection specifiques au SDK Jitsi Meet, requises pour les
# builds "release" (source officielle Jitsi : evite un plantage au
# demarrage cause par la compression/renommage du code Android).

# Flutter
-keep class io.flutter.plugins.** { *; }

# React Native (utilise en interne par le SDK Jitsi)
-keep class com.facebook.react.** { *; }
-keep class com.facebook.hermes.unicode.** { *; }
-keep class com.facebook.jni.** { *; }
-dontwarn com.facebook.react.**

# SDK Jitsi Meet lui-meme
-keep class org.jitsi.meet.** { *; }
-keep class org.jitsi.meet.sdk.** { *; }
-keep class org.webrtc.** { *; }
-dontwarn org.jitsi.meet.**
-dontwarn org.webrtc.**

# Empeche la suppression des ressources (chaines, etc.) utilisees par
# reflexion dans le SDK natif Jitsi (cause du plantage observe).
-keepclassmembers class **.R$* {
    public static <fields>;
}
-keep class **.R$string { *; }
