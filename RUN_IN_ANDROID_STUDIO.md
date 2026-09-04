# How to Run the App in Android Studio (All Flavors)

## Quick Start

### Step 1: Open the Project
1. Open **Android Studio**
2. File → Open → Select your project folder
3. Wait for Gradle sync to complete

### Step 2: Select a Flavor & Run

#### Option A: Using Run Configurations (Recommended)
1. Look at the top toolbar
2. Find the **dropdown** that says `Dev`, `main`, `Staging`, or `Prod`
3. Click it and select:
   - **Dev** (runs `lib/main_dev.dart`)
   - **Staging** (runs `lib/main_staging.dart`)
   - **Prod** (runs `lib/main_prod.dart`)
4. Make sure you have a device/emulator running:
   ```bash
   flutter emulators --launch <emulator_name>
   # or connect a physical device via USB
   ```
5. Click the green **Play** button (▶) in the toolbar

#### Option B: Using Build Variants
1. View → Tool Windows → **Build Variants** (bottom-left panel)
2. Select variant:
   - `devDebug` / `devRelease`
   - `stagingDebug` / `stagingRelease`
   - `prodDebug` / `prodRelease`
3. Click Play button (▶)

#### Option C: Using Terminal (Inside Android Studio)
1. Open the integrated terminal (View → Tool Windows → Terminal)
2. Run one of these:

**Dev:**
```bash
flutter run --flavor dev -t lib/main_dev.dart
```

**Staging:**
```bash
flutter run --flavor staging -t lib/main_staging.dart
```

**Prod:**
```bash
flutter run --flavor prod -t lib/main_prod.dart
```

---

## Emulator Setup

### Start Android Emulator
```bash
flutter emulators --launch <emulator_name>
```

### List Available Emulators
```bash
flutter emulators
```

### Verify Device is Connected
```bash
flutter devices
```

---

## What Each Flavor Does

| Flavor | Package Name | App Name | Entry Point |
|--------|--------------|----------|-------------|
| **Dev** | `com.scrapify.auction.dev` | "Scrapify Auctions Dev" | `lib/main_dev.dart` |
| **Staging** | `com.scrapify.auction.staging` | "Scrapify Auctions Staging" | `lib/main_staging.dart` |
| **Prod** | `com.scrapify.auction` | "Scrapify Auctions" | `lib/main_prod.dart` |

All flavors connect to the **live API** at `https://api.scrapifyauctions.com/api/v1`

---

## Install All Three Flavors on Same Device

You can install all 3 versions simultaneously (different package names):

```bash
# Install Dev
flutter install --flavor dev

# Install Staging
flutter install --flavor staging

# Install Prod
flutter install --flavor prod
```

Now all three apps appear on your device with different icons & names!

---

## Troubleshooting

### Problem: "Run Configuration not showing"
**Solution:**
1. File → Invalidate Caches → **Invalidate and Restart**
2. Wait for Android Studio to restart
3. Configurations will reload automatically

### Problem: "Gradle sync failed"
**Solution:**
```bash
flutter clean
flutter pub get
```
Then retry in Android Studio

### Problem: "No devices detected"
**Solution:**
1. Start emulator first:
   ```bash
   flutter emulators --launch Pixel_7
   ```
2. Wait 30 seconds for it to fully boot
3. Check devices:
   ```bash
   flutter devices
   ```

### Problem: "Build failed with Gradle error"
**Solution:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run --flavor dev -t lib/main_dev.dart
```

### Problem: "Stuck on 'Waiting for device to report its views'"
**Solution:**
1. Stop the build (Ctrl+C)
2. Kill the app on device (Settings → Apps → Force Stop)
3. Run again

---

## Android Studio Hotkeys

| Action | Hotkey |
|--------|--------|
| Run App | Shift + F10 |
| Debug App | Shift + F9 |
| Stop App | Ctrl + F2 |
| Rebuild | Ctrl + Shift + F9 |
| Hot Reload | Ctrl + \ |
| Hot Restart | Ctrl + Shift + \ |

---

## Check App is Running Correctly

1. **App Launch:**
   - Should show Scrapify Auctions splash screen
   - Then load login screen

2. **Verify Flavor:**
   - Check app name in device home screen
   - Should show: "Scrapify Auctions Dev" / "Staging" / or just "Scrapify Auctions"

3. **Test Login:**
   - Try logging in with test credentials
   - App should connect to live API
   - Should fetch auctions and display data

4. **Navigate Screens:**
   - Test all major screens (Home, Auctions, Orders, Performance, etc.)
   - Everything should work without errors

---

## Next Steps

✅ Flavors configured and ready
✅ All three run configurations set up
✅ Can run on Android, iOS, and web

Happy testing! 🚀
