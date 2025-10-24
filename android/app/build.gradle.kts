plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.pim4chamados"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.pim4chamados"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// Ensure Flutter tool can find APK under projectRoot/build when running `flutter run`.
// Copies the built APK from module output to the Flutter expected location.
tasks.register<Copy>("copyDebugApkToFlutterOut") {
    val srcApk = layout.buildDirectory.file("outputs/flutter-apk/app-debug.apk")
    val destDir = rootProject.layout.projectDirectory.dir("../build/app/outputs/flutter-apk")
    from(srcApk)
    into(destDir)
    doFirst {
        destDir.asFile.mkdirs()
    }
}

tasks.matching { it.name == "assembleDebug" || it.name == "packageDebug" }.configureEach {
    finalizedBy("copyDebugApkToFlutterOut")
}
