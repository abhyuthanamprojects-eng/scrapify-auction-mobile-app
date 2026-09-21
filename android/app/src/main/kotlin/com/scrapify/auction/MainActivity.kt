package com.scrapify.auction

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    // Temporarily disabled for QA screenshots and screen-recording capture.
    // Set to true before the production release to restore FLAG_SECURE.
    private val screenCaptureProtectionEnabled = false

    override fun onCreate(savedInstanceState: Bundle?) {
        if (screenCaptureProtectionEnabled) {
            window.setFlags(
                WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE
            )
        }
        super.onCreate(savedInstanceState)
    }
}
