plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.smart_study_planner"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // In Kotlin Script (.kts), the property name is prefixed with 'is'
        isCoreLibraryDesugaringEnabled = true
        
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // To fix the deprecation warning, you can use this or leave as is 
        // for now as it's just a warning, but the error was on the line above.
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.smart_study_planner"
        
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Updated to version 2.1.4 as requested by the error log
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}