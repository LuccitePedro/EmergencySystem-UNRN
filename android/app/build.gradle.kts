plugins {
    id("com.android.application")
    id("kotlin-android")
    // El plugin de Flutter viene configurado de base
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.emergency_system"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        // Activamos el desugaring para las notificaciones
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        // Tu ID único de aplicación
        applicationId = "com.example.emergency_system"
        // Forzamos el SDK mínimo a 21
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Esto es para cuando firmes la app para PlayStore
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Agregamos la librería específica para que funcionen las notificaciones en Android viejo
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
