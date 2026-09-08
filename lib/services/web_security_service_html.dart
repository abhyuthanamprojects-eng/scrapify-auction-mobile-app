import 'dart:html' as html;
import 'web_security_service.dart';

WebSecurityResult checkWebSecurityImpl() {
  final ua = html.window.navigator.userAgent.toLowerCase();
  final platform = html.window.navigator.platform!.toLowerCase();
  final touchPoints = html.window.navigator.maxTouchPoints!;
  final isIpad =
      ua.contains('ipad') || (platform.contains('mac') && touchPoints > 1);
  final isAndroid = ua.contains('android');
  final isPhone =
      ua.contains('iphone') ||
      ua.contains('ipod') ||
      (isAndroid && ua.contains('mobile'));

  final browser = ua.contains('edg/')
      ? 'Microsoft Edge'
      : ua.contains('firefox/')
      ? 'Mozilla Firefox'
      : ua.contains('crios/') || ua.contains('chrome/')
      ? 'Google Chrome'
      : ua.contains('safari/') && !ua.contains('chrome/')
      ? 'Apple Safari'
      : 'Unsupported browser';
  final supportedBrowser = browser != 'Unsupported browser';
  final device = isPhone
      ? 'mobile-phone'
      : isIpad || (isAndroid && !ua.contains('mobile'))
      ? 'tablet'
      : 'desktop';

  return WebSecurityResult(
    allowed: supportedBrowser && !isPhone,
    mobilePhone: isPhone,
    browser: browser,
    device: device,
  );
}
