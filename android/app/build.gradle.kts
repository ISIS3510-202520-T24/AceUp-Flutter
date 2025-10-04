plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}


android {
    namespace = "com.aceup.aceup_clean"
    compileSdk = 35          // <-- subir a 35

    defaultConfig {
        applicationId = "com.aceup.aceup_clean"
        minSdk = 23          // ya lo tienes bien
        targetSdk = 35       // <-- subir a 35
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        debug { }
        release {
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }
}



flutter {
    source = "../.."
}
