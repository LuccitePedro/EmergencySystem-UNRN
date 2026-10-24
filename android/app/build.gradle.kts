plugins {
    id("com.android.application")
    id("kotlin-android")
    // El plugin de Flutter viene configurado de base
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "ar.edu.unrn.emergencysystem"
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
        applicationId = "ar.edu.unrn.emergencysystem"
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
    // Temas AppCompat que necesita local_auth en Android 8 o anterior
    implementation("androidx.appcompat:appcompat:1.7.0")
}
