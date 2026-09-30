# ═══════════════════════════════════════════════════════════════
# 🛡️ PROGUARD RULES — Medical Care App
# ═══════════════════════════════════════════════════════════════
# These rules prevent R8/ProGuard from stripping critical classes
# used via reflection by Flutter plugins.
# ═══════════════════════════════════════════════════════════════

# ─── Flutter Local Notifications ───
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# ─── Firebase ───
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# ─── Mobile Scanner (ZXing + ML Kit) ───
-keep class com.google.mlkit.** { *; }
-keep class com.google.zxing.** { *; }

# ─── Local Auth (Biometric) ───
-keep class androidx.biometric.** { *; }

# ─── Flutter Secure Storage ───
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# ─── Image Picker / Cropper ───
-keep class com.yalantis.ucrop.** { *; }

# ─── Connectivity Plus ───
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

# ─── Kotlin Metadata ───
-keepattributes RuntimeVisible*Annotations,Metadata
-keep class kotlin.Metadata { *; }

# ─── Enums ───
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# ─── General Safety ───
-keepattributes Signature,InnerClasses,EnclosingMethod
-keepattributes *Annotation*
-dontwarn javax.annotation.**
-dontwarn kotlin.**
-dontwarn kotlinx.**

# ─── Prevent stripping Serializable classes ───
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
