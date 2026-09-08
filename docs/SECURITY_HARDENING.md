# Security hardening scope

This repository contains the Flutter native mobile application. It does not
contain the bidder website, admin web console, or auction backend, so browser
allowlisting, mobile-web blocking, server-side device validation, and backend
authorization must be implemented in those separate systems.

## Implemented here

- Android applies `FLAG_SECURE` before Flutter creates its window. This blocks
  screenshots and prevents sensitive recent-app thumbnails on supported Android
  versions.
- iOS observes active screen capture and displays a privacy overlay. It also
  masks the app while backgrounded so App Switcher snapshots do not expose the
  current screen.
- iOS screenshot notifications are logged as deterrence/telemetry. Apple
  delivers that notification after the screenshot, so it is not prevention.
- The wallet action has explicit finite width constraints and cannot propagate
  an infinite-width button constraint through its `Row`.

## Platform limitations

Public web APIs cannot reliably prevent OS screenshots, external recorders,
Zoom/Meet/Teams capture, or a second camera. The web implementation should use
server authorization, dynamic watermarks, focus/visibility monitoring, and
security-event logging; it must not claim that JavaScript disables OS capture.

The backend must independently enforce authentication, roles, auction
eligibility, server-authoritative auction time, bid validation, and payment/KYC
permissions. Client headers and frontend route guards are signals only, never
authorization.
