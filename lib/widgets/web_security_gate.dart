import 'package:flutter/material.dart';

import '../services/web_security_service.dart';

class WebSecurityGate extends StatelessWidget {
  final Widget child;

  const WebSecurityGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final result = checkWebSecurity();
    if (result.allowed) return child;

    final mobile = result.mobilePhone;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  mobile ? Icons.phone_android : Icons.gpp_bad_outlined,
                  size: 64,
                ),
                const SizedBox(height: 20),
                Text(
                  mobile
                      ? 'Mobile web access blocked'
                      : 'Browser not supported',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  mobile
                      ? 'This platform is not available on mobile browsers. Please use the Scrapify mobile application.'
                      : 'For security and compatibility, use Google Chrome, Microsoft Edge, Mozilla Firefox, or Apple Safari.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
