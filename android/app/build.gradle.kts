import java.io.File
import java.io.FileInputStream
import java.util.Properties

val signingPropertiesFile = rootProject.file("scrapify-auction-key.properties")
val signingProperties = Properties()
if (signingPropertiesFile.exists()) {
    FileInputStream(signingPropertiesFile).use { signingProperties.load(it) }
}

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
    namespace = "com.scrapify.auction"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.scrapify.auction"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = signingProperties.getProperty("keyAlias")
            keyPassword = signingProperties.getProperty("keyPassword")
            storePassword = signingProperties.getProperty("storePassword")

            val storePath = signingProperties.getProperty("storeFile")
            storeFile = storePath?.let {
                val file = File(it)
                if (file.isAbsolute) file else rootProject.file(it)
            }
        }
    }

    flavorDimensions += "environment"

    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "Scrapify Auctions Dev")
            resValue("string", "api_base_url", "https://api.scrapifyauctions.com/api/v1")
        }
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            resValue("string", "app_name", "Scrapify Auctions Staging")
            resValue("string", "api_base_url", "https://staging-api.scrapifyauctions.com/api/v1")
        }
        create("prod") {
            dimension = "environment"
            applicationIdSuffix = ""
            resValue("string", "app_name", "Scrapify Auction")
            resValue("string", "api_base_url", "https://api.scrapifyauctions.com/api/v1")
        }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
