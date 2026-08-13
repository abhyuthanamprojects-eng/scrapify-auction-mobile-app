import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/otp_screen.dart';
import '../../screens/auth/role_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/shell/app_shell.dart';
import '../../screens/lot_details/lot_details_screen.dart';
import '../../screens/live_auction/live_auction_screen.dart';
import '../../screens/live_auction/won_screen.dart';
import '../../screens/live_auction/lost_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/profile/edit_profile_screen.dart';
import '../../screens/profile/notif_settings_screen.dart';
import '../../screens/seller/create_auction_screen.dart';
import '../../screens/seller/my_auctions_screen.dart';
import '../../screens/customer/reg_status_screen.dart';
import '../../screens/customer/auction_register_screen.dart';
import '../../screens/customer/payable_summary_screen.dart';
import '../../screens/customer/refund_tracker_screen.dart';
import '../../screens/customer/emd_ledger_screen.dart';

abstract final class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/otp',
        builder: (_, state) => OtpScreen(identifier: state.extra as String? ?? ''),
      ),
      GoRoute(path: '/role', builder: (_, __) => const RoleScreen()),
      GoRoute(
        path: '/signup',
        builder: (_, state) => SignupScreen(prefillIdentifier: state.extra as String?),
      ),
      GoRoute(path: '/home', builder: (_, __) => const AppShell()),
      GoRoute(
        path: '/lot/:id',
        builder: (_, state) => LotDetailsScreen(lotId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/live/:id',
        builder: (_, state) => LiveAuctionScreen(lotId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/won', builder: (_, __) => const WonScreen()),
      GoRoute(path: '/lost', builder: (_, __) => const LostScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/profile/edit', builder: (_, __) => const EditProfileScreen()),
      GoRoute(path: '/profile/addresses', builder: (_, __) => _placeholder('Addresses')),
      GoRoute(path: '/profile/payments', builder: (_, __) => _placeholder('Payment Methods')),
      GoRoute(path: '/profile/kyc', builder: (_, __) => _placeholder('KYC Documents')),
      GoRoute(path: '/profile/notif-settings', builder: (_, __) => const NotifSettingsScreen()),
      GoRoute(path: '/seller/auctions', builder: (_, __) => const SellerMyAuctionsScreen()),
      GoRoute(path: '/seller/create-auction', builder: (_, __) => const CreateAuctionScreen()),
      GoRoute(path: '/auctions', builder: (_, __) => const AppShell()),
      GoRoute(
        path: '/reg-status',
        builder: (ctx, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return RegStatusScreen(
            status: extra['status'] as String? ?? 'pending',
            reason: extra['reason'] as String?,
            kycDetails: (extra['kycDetails'] as Map<String, String>?) ?? {},
            onBack: () => ctx.pop(),
          );
        },
      ),
      GoRoute(
        path: '/auction-register',
        builder: (ctx, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return AuctionRegisterScreen(
            auctions: (extra['auctions'] as List<AuctionParticipation>?) ?? [],
            isApproved: extra['isApproved'] as bool? ?? false,
            onBack: () => ctx.pop(),
          );
        },
      ),
      GoRoute(
        path: '/payable-summary',
        builder: (ctx, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return PayableSummaryScreen(
            auctionTitle: extra['auctionTitle'] as String? ?? '',
            h1Value: (extra['h1Value'] as num?)?.toDouble() ?? 0,
            emdAmount: (extra['emdAmount'] as num?)?.toDouble() ?? 0,
            onBack: () => ctx.pop(),
          );
        },
      ),
      GoRoute(
        path: '/refund-tracker',
        builder: (ctx, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return RefundTrackerScreen(
            refunds: (extra['refunds'] as List<RefundEntry>?) ?? [],
            onBack: () => ctx.pop(),
          );
        },
      ),
      GoRoute(
        path: '/emd-ledger',
        builder: (ctx, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return EmdLedgerScreen(
            entries: (extra['entries'] as List<EmdLedgerEntry>?) ?? [],
            onBack: () => ctx.pop(),
          );
        },
      ),
    ],
  );

  static Widget _placeholder(String title) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title — Coming in Prompt 2')),
    );
  }
}
