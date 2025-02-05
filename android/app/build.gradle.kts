plugins {
  alias(libs.plugins.androidApplication)
  alias(libs.plugins.jetbrainsKotlinAndroid)
  id("com.google.android.libraries.mapsplatform.secrets-gradle-plugin")
}

secrets {
  // To add your Maps API key to this project:
  // 1. If the secrets.properties file does not exist, create it in the same folder as the
  // local.properties file.
  // 2. Add this line, where YOUR_API_KEY is your API key:
  //        MAPS_API_KEY=YOUR_API_KEY
  propertiesFileName = "secrets.properties"

  // A properties file containing default secret values. This file can be
  // checked in version control.
  defaultPropertiesFileName = "local.defaults.properties"

  // Configure which keys should be ignored by the plugin by providing regular expressions.
  // "sdk.dir" is ignored by default.
  ignoreList.add("keyToIgnore") // Ignore the key "keyToIgnore"
  ignoreList.add("sdk.*") // Ignore all keys matching the regexp "sdk.*"
}

android {
  namespace = "net.ipv64.kivop"
  compileSdk = 35

  defaultConfig {
    applicationId = "net.ipv64.kivop"
    minSdk = 26
    targetSdk = 34
    versionCode = 1
    versionName = "1.0"

    testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    vectorDrawables { useSupportLibrary = true }
    println("OPENCAGE_API_KEY = ${project.findProperty("OPENCAGE_API_KEY")}")
    buildConfigField(
        "String",
        "OPENCAGE_API_KEY",
        "\"${project.findProperty("OPENCAGE_API_KEY")?: "default_value_here"}\"")
  }

  buildTypes {
    release {
      isMinifyEnabled = false
      proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
    }
  }
  compileOptions {
    sourceCompatibility = JavaVersion.VERSION_1_8
    targetCompatibility = JavaVersion.VERSION_1_8
  }
  kotlinOptions { jvmTarget = "1.8" }
  buildFeatures {
    compose = true
    buildConfig = true
  }
  composeOptions { kotlinCompilerExtensionVersion = "1.5.1" }
  packaging { resources { excludes += "/META-INF/{AL2.0,LGPL2.1}" } }
}

dependencies {
  implementation(libs.androidx.core.ktx)
  implementation(libs.androidx.lifecycle.runtime.ktx)
  implementation(libs.androidx.activity.compose)
  implementation(platform(libs.androidx.compose.bom))
  implementation(libs.androidx.ui)
  implementation(libs.androidx.ui.graphics)
  implementation(libs.androidx.ui.tooling.preview)
  implementation(libs.androidx.material3)
  implementation(libs.androidx.navigation.runtime.ktx)
  implementation(libs.play.services.maps)
  implementation(libs.play.services.location)
  testImplementation(libs.junit)
  androidTestImplementation(libs.androidx.junit)
  androidTestImplementation(libs.androidx.espresso.core)
  androidTestImplementation(platform(libs.androidx.compose.bom))
  androidTestImplementation(libs.androidx.ui.test.junit4)
  debugImplementation(libs.androidx.ui.tooling)
  debugImplementation(libs.androidx.ui.test.manifest)
  implementation("io.noties.markwon:core:4.6.2")
  // Navigation
  implementation("androidx.navigation:navigation-compose:2.8.4")
  implementation("com.squareup.okhttp3:okhttp:4.12.0")
  implementation("com.google.code.gson:gson:2.10.1")
  // EncryptedSharedPreferences
  implementation("androidx.security:security-crypto:1.1.0-alpha06")
  // Glide for smooth sliding Todo:Remove glide if not needed
  implementation("com.github.bumptech.glide:compose:1.0.0-beta01")
  // ViewModel Compose
  implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.6.2")
  // Coil AsyncImage
  implementation("io.coil-kt.coil3:coil-compose:3.0.4")
  // Tav Compose
  implementation(libs.accompanist.pager)
  implementation(libs.accompanist.pager.indicators)
  implementation("com.google.android.gms:play-services-maps:19.0.0")
  implementation("com.google.maps.android:maps-compose:6.4.0")
  // ML Kit Barcode Scanning
  implementation(libs.mlkit.barcode.scanning)
  implementation(libs.camera.mlkit.vision)
  // CameraX dependencies for camera integration
  implementation(libs.androidx.camera.core)
  implementation(libs.camera.camera2)
  implementation(libs.camera.lifecycle)
  implementation(libs.camera.view)
  // Accompanist Permissions for handling runtime permissions
  implementation(libs.accompanistPermissions)
}
