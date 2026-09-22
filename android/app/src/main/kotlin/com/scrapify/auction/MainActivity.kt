package com.scrapify.auction

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    // Prevent screenshots and screen recording in the production app.
    private val screenCaptureProtectionEnabled = true

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
