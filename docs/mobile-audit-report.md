# Scrapify Auction Mobile Audit

Scope: Flutter mobile application for Android and iOS. Website and operations-console repositories are outside this report.

## Automated verification

| Check | Result | Notes |
| --- | --- | --- |
| `flutter analyze` | Pass | 8 informational curly-brace lints; no errors or warnings that block compilation. |
| `flutter test` | Pass | Existing widget test passed: app launches without crashing. |
| Android dev debug build | Pass after fix | The build initially failed because Google Services was applied to `com.scrapify.auction.dev` although only the production client existed. The unused plugin application was removed. |
| Android production release build | Pass | `app-prod-release.apk` built successfully with the configured signing properties. |
| iOS production compile | Pass | `flutter build ios --release --no-codesign -t lib/main_prod.dart` produced `Runner.app`; signing/upload still belongs in Xcode/CI. |
| Git diff hygiene | Pass | No whitespace errors from the current mobile changes. |

## Static flow coverage

- Authentication: password login, OTP request/resend/verification, registration, session refresh, forced logout on HTTP 401, biometric lock, suspended and expired-session screens.
- Seller: registration, business verification, documents, payment proof, auction creation, template upload, seller auction list, terms configuration.
- Buyer: auction browse/detail, registration, EMD lock and ledger, terms acceptance, live forward/reverse auctions, proxy bidding, bid history, awards, fallback offers, payment, orders, pickup/gate pass, disputes, notifications and profile deletion.
- Security: bearer token storage uses secure storage, API logging is disabled by default, role guards protect buyer/seller routes, and the Android app does not request broad media-storage permissions.
- iOS release metadata: camera, photo library, location, encryption declaration, and all four iPad interface orientations are present.

## Confirmed fix

The Google Services Gradle plugin was applied globally even though the app has no Firebase usage and the checked-in configuration only contains the production package. This made `flutter build apk --debug` fail with:

```text
No matching client found for package name 'com.scrapify.auction.dev'
```

The plugin application and unused settings declaration were removed. Dev and production builds now complete.

## Remaining manual verification

These require a real Android/iPhone and safe test data; they were not simulated or performed against production:

1. Buyer login/OTP with `8888888888` / `0000`.
2. Seller login/OTP with `9999999999` / `0000`.
3. Camera/photo picker permissions and denied-permission recovery.
4. Seller KYB uploads, payment proof, auction draft/submission and duplicate-submit behavior.
5. Buyer terms acceptance, EMD payment confirmation, forward/reverse bidding, reconnect/poll fallback and cutoff handling.
6. Awards, payment, pickup, gate pass, disputes and account deletion.
7. Cold start after logout, token expiry, offline/API failure states, accessibility and device-size checks.

## Release cautions

- Flutter reports that Gradle 8.14, Android Gradle Plugin 8.11.1, and Kotlin 2.2.20 will require upgrades in a future Flutter release. They are not current build failures.
- 80 dependency updates are available but were not applied during this audit; upgrading them without a compatibility pass could change payment, picker, auth or storage behavior.
- The iOS build was intentionally unsigned. Create the signed archive with the production scheme and verify the App Store Connect build metadata before upload.
