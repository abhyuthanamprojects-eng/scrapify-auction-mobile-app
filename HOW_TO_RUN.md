# How to Run Scrapify Auction App - All Flavors

## ✅ FASTEST & MOST RELIABLE METHOD

### From Terminal (Works 100% of the time)

Open terminal in the project directory and run:

```bash
# Dev flavor
flutter run --flavor dev -t lib/main_dev.dart

# Staging flavor
flutter run --flavor staging -t lib/main_staging.dart

# Prod flavor
flutter run --flavor prod -t lib/main_prod.dart
```

Or use the convenience script:
```bash
bash run_flavor.sh dev      # Dev
bash run_flavor.sh staging  # Staging
bash run_flavor.sh prod     # Prod
```

---

## Android Studio Built-in Terminal Method

1. **View → Tool Windows → Terminal** (or Alt+F12)
2. Run the command above
3. App will build and run on connected device/emulator

---

## From Android Studio UI (Direct)

### Method 1: Run Configuration Dropdown
1. Top toolbar → find dropdown showing "main"
2. Click it → Select **Dev**, **Staging**, or **Prod**
3. Click green **Play** button ▶

### Method 2: Run Configuration Menu
1. **Run → Edit Configurations...**
2. Click **+** button
3. Select **Flutter**
4. Set:
   - **Name**: Dev
   - **Dart entrypoint**: `lib/main_dev.dart`
   - **Additional args**: `--flavor dev`
5. Click **OK**
6. Repeat for Staging and Prod

### Method 3: Build Variants (Android Only)
1. **View → Tool Windows → Build Variants**
2. Select:
   - `devDebug` (for debug builds)
   - `stagingDebug`
   - `prodDebug`
3. Click Play ▶

---

## Setup Emulator First

Before running, make sure you have an emulator running:

```bash
# List available emulators
flutter emulators

# Launch an emulator (e.g., Pixel_7)
flutter emulators --launch Pixel_7
```

Or in Android Studio:
- **Tools → Device Manager → Select emulator → Play button**

---

## Check Device is Connected

```bash
flutter devices
```

You should see output like:
```
2 connected devices:
Pixel 7 Emulator (mobile)     • emulator-5554 • android
iPhone 15 Simulator (mobile)  • iphone        • ios
```

---

## Build APKs (Without Installing)

If you just want to build APKs:

```bash
# Dev APK
flutter build apk --flavor dev -t lib/main_dev.dart

# Staging APK
flutter build apk --flavor staging -t lib/main_staging.dart

# Prod APK
flutter build apk --flavor prod -t lib/main_prod.dart
```

APKs will be in:
```
build/app/outputs/flutter-apk/
├── app-dev-release.apk
├── app-staging-release.apk
└── app-prod-release.apk
```

---

## Install Multiple Flavors on Same Device

Install all 3 versions simultaneously (different package names):

```bash
flutter install --flavor dev
flutter install --flavor staging
flutter install --flavor prod
```

Now you'll have 3 app icons on your device:
- "Scrapify Auctions Dev"
- "Scrapify Auctions Staging"
- "Scrapify Auctions"

---

## iOS Setup

### Build for iOS Simulator
```bash
flutter build ios --flavor dev -t lib/main_dev.dart
flutter run --flavor dev -t lib/main_dev.dart
```

### Or use Xcode directly
```bash
cd ios
open Runner.xcworkspace
# In Xcode: Product → Scheme → Select Dev/Staging/Prod
# Press Cmd+R to run
```

---

## Keyboard Shortcuts in Android Studio

| Action | Shortcut |
|--------|----------|
| Run | Shift + F10 |
| Debug | Shift + F9 |
| Stop | Ctrl + F2 |
| Hot Reload | Ctrl + \ |
| Hot Restart | Ctrl + Shift + \ |

---

## Troubleshooting

### "No running devices found"
```bash
flutter emulators --launch Pixel_7
# Wait 30 seconds
flutter devices
```

### "Build failed"
```bash
flutter clean
flutter pub get
flutter run --flavor dev -t lib/main_dev.dart
```

### "Permission denied" on run_flavor.sh
```bash
chmod +x run_flavor.sh
bash run_flavor.sh dev
```

### "Gradle sync failed"
1. Android Studio: File → Invalidate Caches → Invalidate and Restart
2. Wait 2-3 minutes
3. Try running again

---

## Summary

**Most Reliable Way to Run:**
```bash
flutter run --flavor dev -t lib/main_dev.dart
```

**Easiest Way (Using Script):**
```bash
bash run_flavor.sh dev
```

**All Three Flavors Work:**
- ✅ Dev → lib/main_dev.dart
- ✅ Staging → lib/main_staging.dart
- ✅ Prod → lib/main_prod.dart

**App Details:**
- Dev Package: `com.scrapify.auction.dev`
- Staging Package: `com.scrapify.auction.staging`
- Prod Package: `com.scrapify.auction`
- API: `https://api.scrapifyauctions.com/api/v1`

Happy testing! 🚀
