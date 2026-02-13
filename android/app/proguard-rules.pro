# --- Added for MediaPipe / Gemma / Protobuf ---
-keep class com.google.mediapipe.** { *; }
-keep class com.google.mediapipe.proto.** { *; }
-keep class com.google.protobuf.** { *; }
-dontwarn com.google.mediapipe.**
-dontwarn com.google.protobuf.**

# Keep enum members (important for generated proto/model enums)
-keepclassmembers enum * { public static **[] values(); public static ** valueOf(java.lang.String); }

# Generated proto presence related (avoid stripping)
-keep class com.google.protobuf.ProtoField { *; }
-keep class com.google.protobuf.ProtoPresenceBits { *; }
-keep class com.google.protobuf.ProtoPresenceCheckedField { *; }

# JavaPoet (shaded) used by AutoValue in some builds
-keep class autovalue.shaded.com.squareup.javapoet.** { *; }
-dontwarn autovalue.shaded.com.squareup.javapoet.**

# Annotation / model elements referenced reflectively
-keep class javax.lang.model.** { *; }
-dontwarn javax.lang.model.**

# Optional SSL providers (avoid hard fails if absent)
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**
-keep class org.conscrypt.** { *; }
-dontwarn org.conscrypt.**
-keep class org.openjsse.** { *; }
-dontwarn org.openjsse.**

# OkHttp internal platform lookups
-dontwarn okhttp3.internal.platform.**
-keep class okhttp3.internal.platform.** { *; }

# Flutter Gemma specific keeps
-keep class com.google.mediapipe.tasks.** { *; }
-keep class com.google.mediapipe.framework.** { *; }
-dontwarn com.google.mediapipe.tasks.**
-dontwarn com.google.mediapipe.framework.**

# LLM inference engine
-keep class **llm_inference_engine** { *; }
-keep class **LlmInferenceEngine** { *; }

# Preserve JNI methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Preserve public APIs in your AI model layer if using reflection
-keep class com.yourpackage.**Model** { *; }

# (Optional) If you still see missing_rules.txt suggestions, append them below:
# --- END ---
