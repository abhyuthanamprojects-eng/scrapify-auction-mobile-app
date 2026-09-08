import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var privacyOverlay: UIView?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    preventScreenCapture()
    return result
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  private func preventScreenCapture() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screenCaptureChanged),
      name: UIScreen.capturedDidChangeNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screenshotTaken),
      name: UIApplication.userDidTakeScreenshotNotification,
      object: nil
    )
  }

  @objc private func screenCaptureChanged() {
    if UIScreen.main.isCaptured {
      showPrivacyOverlay(message: "Screen capture is restricted")
    } else {
      hidePrivacyOverlay()
    }
  }

  @objc private func screenshotTaken() {
    // iOS reports this after the screenshot has already been taken. This is
    // intentionally telemetry/deterrence, not a claim that screenshots can be
    // prevented by a public iOS API.
    NSLog("SECURITY_EVENT: screenshot_taken")
  }

  func showPrivacyOverlay(message: String = "Privacy mode") {
    guard let window = window, privacyOverlay == nil else { return }
    let overlay = UIView(frame: window.bounds)
    overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    overlay.backgroundColor = UIColor(red: 0.04, green: 0.07, blue: 0.12, alpha: 1)
    let label = UILabel(frame: overlay.bounds)
    label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    label.text = message
    label.textColor = .white
    label.textAlignment = .center
    label.font = .boldSystemFont(ofSize: 17)
    overlay.addSubview(label)
    window.addSubview(overlay)
    privacyOverlay = overlay
  }

  func hidePrivacyOverlay() {
    privacyOverlay?.removeFromSuperview()
    privacyOverlay = nil
  }

  override func applicationDidEnterBackground(_ application: UIApplication) {
    super.applicationDidEnterBackground(application)
    showPrivacyOverlay(message: "Scrapify Auction")
  }

  override func applicationWillEnterForeground(_ application: UIApplication) {
    super.applicationWillEnterForeground(application)
    if !UIScreen.main.isCaptured { hidePrivacyOverlay() }
  }
}
