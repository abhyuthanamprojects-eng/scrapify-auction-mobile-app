import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// The legal and support documents live on the website so there is one copy to
/// keep current. `?embed=1` tells the site to drop its own header and tab bar,
/// since the in-app browser already supplies navigation.
enum LegalPage { terms, privacy, refund, help }

extension LegalPageInfo on LegalPage {
  String get path => switch (this) {
        LegalPage.terms => '/terms',
        LegalPage.privacy => '/privacy',
        LegalPage.refund => '/refund',
        LegalPage.help => '/help',
      };

  String get title => switch (this) {
        LegalPage.terms => 'Terms & Conditions',
        LegalPage.privacy => 'Privacy Policy',
        LegalPage.refund => 'Refund & Cancellation Policy',
        LegalPage.help => 'Help & Support',
      };

  IconData get icon => switch (this) {
        LegalPage.terms => Icons.gavel_outlined,
        LegalPage.privacy => Icons.privacy_tip_outlined,
        LegalPage.refund => Icons.receipt_long_outlined,
        LegalPage.help => Icons.help_outline,
      };
}

class LegalPages {
  static const String siteBaseUrl = 'https://scrapifyauctions.com';

  static Uri uriFor(LegalPage page) =>
      Uri.parse('$siteBaseUrl${page.path}?embed=1');

  /// Opens the page in an in-app browser, falling back to the external browser
  /// where the platform has no in-app view available.
  static Future<void> open(BuildContext context, LegalPage page) async {
    final uri = uriFor(page);
    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      if (!opened) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      messenger?.showSnackBar(
        SnackBar(content: Text('Could not open ${page.title}.')),
      );
    }
  }
}
