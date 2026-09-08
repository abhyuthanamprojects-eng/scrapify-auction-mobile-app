import 'package:go_router/go_router.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/onboarding/vendor_onboarding_screen.dart';
import '../../screens/profile/business_verification_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/otp_screen.dart';
import '../../screens/auth/role_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/mfa_screen.dart';
import '../../screens/auth/session_expired_screen.dart';
import '../../screens/auth/account_suspended_screen.dart';
import '../../screens/security/trusted_devices_screen.dart';
import '../../screens/documents/document_centre_screen.dart';
import '../../screens/support/support_center_screen.dart';
import '../../screens/shell/app_shell.dart';
import '../../screens/auctions/auctions_screen.dart';
import '../../screens/lot_details/lot_details_screen.dart';
import '../../screens/live_auction/live_auction_screen.dart';
import '../../screens/live_auction/live_reverse_auction_screen.dart';
import '../../screens/live_auction/auction_waiting_room_screen.dart';
import '../../screens/live_auction/won_screen.dart';
import '../../screens/live_auction/lost_screen.dart';
import '../../screens/terms/terms_conditions_screen.dart';
import '../../screens/inspection/inspection_booking_screen.dart';
import '../../screens/inspection/gate_pass_screen.dart';
import '../../screens/rfx/rfx_screen.dart';
import '../../screens/awards/awards_screen.dart';
import '../../screens/awards/award_detail_screen.dart';
import '../../screens/awards/fallback_offer_screen.dart';
import '../../screens/payments/payments_dashboard_screen.dart';
import '../../screens/orders/orders_screen.dart';
import '../../screens/orders/order_detail_screen.dart';
import '../../screens/disputes/disputes_screen.dart';
import '../../screens/disputes/new_dispute_screen.dart';
import '../../screens/team/team_management_screen.dart';
import '../../screens/performance/performance_screen.dart';
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
import '../../screens/wallet/wallet_screen.dart';
import '../../screens/my_bids/my_bids_screen.dart';

abstract final class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/vendor-onboarding', builder: (_, __) => const VendorOnboardingScreen()),
      GoRoute(path: '/business-verification', builder: (_, __) => const BusinessVerificationScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/otp',
        builder: (_, state) => OtpScreen(identifier: state.extra as String? ?? ''),
      ),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(
        path: '/mfa',
        builder: (_, state) => MfaScreen(redirectPath: state.extra as String?),
      ),
      GoRoute(
        path: '/session-expired',
        builder: (_, state) => SessionExpiredScreen(returnPath: state.extra as String?),
      ),
      GoRoute(
        path: '/account-suspended',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return AccountSuspendedScreen(
            reason: extra['reason'] as String? ?? 'Annual KYB Re-verification & GSTIN Filing Due',
            ticketRef: extra['ticketRef'] as String? ?? 'COMP-2026-8812',
          );
        },
      ),
      GoRoute(path: '/trusted-devices', builder: (_, __) => const TrustedDevicesScreen()),
      GoRoute(path: '/documents', builder: (_, __) => const DocumentCentreScreen()),
      GoRoute(path: '/support', builder: (_, __) => const SupportCenterScreen()),
      GoRoute(path: '/role', builder: (_, __) => const RoleScreen()),
      GoRoute(
        path: '/signup',
        builder: (_, state) => SignupScreen(prefillIdentifier: state.extra as String?),
      ),
      GoRoute(path: '/home', builder: (_, __) => const AppShell()),
      GoRoute(path: '/auctions', builder: (_, __) => const AuctionsScreen()),
      GoRoute(path: '/wallet', builder: (_, __) => const WalletScreen()),
      GoRoute(path: '/my-bids', builder: (_, __) => const MyBidsScreen()),
      GoRoute(
        path: '/lot/:id',
        builder: (_, state) => LotDetailsScreen(lotId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/waiting-room/:id',
        builder: (_, state) => AuctionWaitingRoomScreen(auctionCode: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/live/:id',
        builder: (_, state) => LiveAuctionScreen(lotId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/live-reverse/:id',
        builder: (_, state) => LiveReverseAuctionScreen(lotId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/terms/:id',
        builder: (_, state) => TermsConditionsScreen(auctionCode: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/inspection/:id',
        builder: (_, state) => InspectionBookingScreen(auctionCode: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/gate-pass/:id',
        builder: (_, state) => GatePassScreen(auctionCode: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/rfx/:id',
        builder: (_, state) => RfxScreen(auctionCode: state.pathParameters['id']!),
      ),
      GoRoute(path: '/won', builder: (_, __) => const WonScreen()),
      GoRoute(path: '/lost', builder: (_, __) => const LostScreen()),
      GoRoute(path: '/awards', builder: (_, __) => const AwardsScreen()),
      GoRoute(
        path: '/award/:id',
        builder: (_, state) => AwardDetailScreen(awardId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/fallback-offer/:id',
        builder: (_, state) => FallbackOfferScreen(offerId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/payments', builder: (_, __) => const PaymentsDashboardScreen()),
      GoRoute(path: '/orders', builder: (_, __) => const OrdersScreen()),
      GoRoute(
        path: '/order/:id',
        builder: (_, state) => OrderDetailScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/disputes', builder: (_, __) => const DisputesScreen()),
      GoRoute(
        path: '/new-dispute/:id',
        builder: (_, state) => NewDisputeScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/team', builder: (_, __) => const TeamManagementScreen()),
      GoRoute(path: '/performance', builder: (_, __) => const PerformanceScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/profile/edit', builder: (_, __) => const EditProfileScreen()),
      GoRoute(path: '/profile/notif-settings', builder: (_, __) => const NotifSettingsScreen()),
      GoRoute(path: '/seller/auctions', builder: (_, __) => const SellerMyAuctionsScreen()),
      GoRoute(path: '/seller/create-auction', builder: (_, __) => const CreateAuctionScreen()),
      GoRoute(
        path: '/reg-status',
        builder: (ctx, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return RegStatusScreen(
            status: extra['status'] as String? ?? 'pending',
            reason: extra['reason'] as String?,
            kycDetails: (extra['kycDetails'] as Map<String, String>?) ?? {},
            onBack: () => ctx.go('/onboarding'),
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
}
