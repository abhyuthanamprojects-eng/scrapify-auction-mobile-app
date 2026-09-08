import 'web_security_service.dart';

WebSecurityResult checkWebSecurityImpl() => const WebSecurityResult(
  allowed: true,
  mobilePhone: false,
  browser: 'native',
  device: 'mobile-app',
);
