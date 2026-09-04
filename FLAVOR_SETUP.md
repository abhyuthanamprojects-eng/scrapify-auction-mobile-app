# Flutter Flavors Setup - Dev, Staging, Prod

This document explains how to use the three flavors (Dev, Staging, Prod) in your Flutter app.

## Overview

- **Dev**: Development environment (live API)
- **Staging**: Staging environment (live API)
- **Prod**: Production environment (live API)

Each flavor:
- Uses a different `main_*.dart` entry point
- Has unique package naming (Android)
- Has unique app display names
- Connects to the same API but can be configured separately

---

## Android Studio / Android Emulator

### Using Run Configurations

Android Studio automatically detects the run configurations:

1. **In Android Studio:**
   - Look for the run configuration dropdown (top-right, next to the play button)
   - Select:
     - `Dev` - Debug Dev flavor
     - `Staging` - Debug Staging flavor
     - `Prod` - Debug Prod flavor
   - Click the **Play** button to run

2. **From Terminal (Android):**
   ```bash
   flutter run --flavor dev -t lib/main_dev.dart      # Dev
   flutter run --flavor staging -t lib/main_staging.dart  # Staging
   flutter run --flavor prod -t lib/main_prod.dart     # Prod
   ```

### Build Variants in Android Studio

You can also select build variants in Android Studio:

1. **View → Tool Windows → Build Variants**
2. Select:
   - `devDebug` / `devRelease`
   - `stagingDebug` / `stagingRelease`
   - `prodDebug` / `prodRelease`

The app will show:
- **Dev app**: `com.scrapify.auction.dev` - "Scrapify Auctions Dev"
- **Staging app**: `com.scrapify.auction.staging` - "Scrapify Auctions Staging"
- **Prod app**: `com.scrapify.auction` - "Scrapify Auctions"

---

## Xcode / iOS Simulator

### Using Schemes

Xcode schemes are set up for you:

1. **In Xcode:**
   - Product → Scheme → Select:
     - `Dev`
     - `Staging`
     - `Prod`
   - Press Cmd+R to run

2. **From Terminal (iOS):**
   ```bash
   flutter run --flavor dev -t lib/main_dev.dart      # Dev
   flutter run --flavor staging -t lib/main_staging.dart  # Staging
   flutter run --flavor prod -t lib/main_prod.dart     # Prod
   ```

---

## VS Code

### Using Debug Configurations

VS Code has debug configurations for all flavors:

1. **Press Ctrl+Shift+D** (or Cmd+Shift+D on Mac)
2. Select from the dropdown:
   - **Dev - iOS Simulator**
   - **Staging - iOS Simulator**
   - **Prod - iOS Simulator**
   - **Dev - Android**
   - **Staging - Android**
   - **Prod - Android**
   - **Dev - Release**
   - **Staging - Release**
   - **Prod - Release**
3. Press **F5** to start debugging

---

## Claude Code Preview

You can also run flavors via Claude Code:

```bash
flutter run -t lib/main_dev.dart --flavor dev
flutter run -t lib/main_staging.dart --flavor staging
flutter run -t lib/main_prod.dart --flavor prod
```

---

## How Flavors Work

### Entry Points

Each flavor has a different main file:
- `lib/main_dev.dart` → Dev flavor
- `lib/main_staging.dart` → Staging flavor
- `lib/main_prod.dart` → Prod flavor

### Configuration

The flavors are controlled in:

**Android** (`android/app/build.gradle.kts`):
```kotlin
productFlavors {
    create("dev") {
        dimension = "environment"
        applicationIdSuffix = ".dev"
        resValue("string", "app_name", "Scrapify Auctions Dev")
    }
    create("staging") {
        dimension = "environment"
        applicationIdSuffix = ".staging"
        resValue("string", "app_name", "Scrapify Auctions Staging")
    }
    create("prod") {
        dimension = "environment"
        applicationIdSuffix = ""
        resValue("string", "app_name", "Scrapify Auctions")
    }
}
```

**iOS** (`ios/Runner.xcodeproj/xcshareddata/xcschemes/`):
- `Dev.xcscheme`
- `Staging.xcscheme`
- `Prod.xcscheme`

### API Configuration

All flavors use the same API endpoint, configured in:
- `lib/core/config/app_env.dart`

---

## Troubleshooting

### Problem: Run configuration not showing in Android Studio

**Solution:**
1. File → Invalidate Caches
2. Restart Android Studio
3. The configurations in `.idea/runConfigurations/` will be detected

### Problem: Scheme not showing in Xcode

**Solution:**
1. Close Xcode
2. Xcode → Preferences → Accounts
3. Add your Apple ID (if not already)
4. Reopen `ios/Runner.xcworkspace`
5. Product → Scheme → Select Dev/Staging/Prod

### Problem: "No valid iOS scheme found"

**Solution:**
1. Verify schemes exist: `ls ios/Runner.xcodeproj/xcshareddata/xcschemes/`
2. Should show: `Dev.xcscheme`, `Staging.xcscheme`, `Prod.xcscheme`
3. If missing, run: `bash ios/create_schemes.sh`

### Problem: App still showing old name after switching flavors

**Solution:**
1. Clean build:
   ```bash
   flutter clean
   flutter pub get
   ```
2. On Android: Run → Clean Project
3. On iOS: Xcode → Product → Clean Build Folder (Cmd+Shift+K)

---

## Verifying Flavors

After launching an app with a flavor:

1. **App Display Name:**
   - Dev: Shows "Scrapify Auctions Dev"
   - Staging: Shows "Scrapify Auctions Staging"
   - Prod: Shows "Scrapify Auctions"

2. **Package Name (Android only):**
   - Dev: `com.scrapify.auction.dev`
   - Staging: `com.scrapify.auction.staging`
   - Prod: `com.scrapify.auction`

3. **Install Multiple Versions:**
   - You can install all 3 versions on the same device (different package names)
   - Great for testing multiple flavors simultaneously!

---

## Next Steps

1. ✅ Flavors are configured for both Android and iOS
2. ✅ Run configurations are ready in all IDEs
3. 🚀 Start using `flutter run --flavor dev/staging/prod`

Happy testing!
