# Ignore missing Google Play Services annotations
-dontwarn com.google.android.gms.common.annotation.NoNullnessRewrite
-dontwarn com.google.android.play.core.ktx.**

# Keep Play Asset Delivery classes from being stripped
-keep class com.google.android.play.core.assetpacks.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
