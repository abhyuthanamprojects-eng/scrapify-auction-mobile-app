import 'web_security_service_stub.dart'
    if (dart.library.html) 'web_security_service_html.dart';

class WebSecurityResult {
  final bool allowed;
  final bool mobilePhone;
  final String browser;
  final String device;

  const WebSecurityResult({
    required this.allowed,
    required this.mobilePhone,
    required this.browser,
    required this.device,
  });
}

WebSecurityResult checkWebSecurity() => checkWebSecurityImpl();
