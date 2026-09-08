abstract final class Endpoints {
  // Auth
  static const register = '/auth/register';
  static const login = '/auth/login';
  static const requestOtp = '/auth/request-otp';
  static const verifyOtp = '/auth/verify-otp';
  static const me = '/auth/me';
  static const logout = '/auth/logout';

  // Profile
  static const profile = '/profile';
  static const addresses = '/profile/addresses';
  static String address(int id) => '/profile/addresses/$id';
  static const paymentMethods = '/profile/payment-methods';
  static String paymentMethod(int id) => '/profile/payment-methods/$id';

  // Categories
  static const categories = '/categories';

  // Auctions
  static const auctions = '/auctions';
  static String auction(String code) => '/auctions/$code';
  static String auctionLots(String code) => '/auctions/$code/lots';
  static String auctionLot(String code, String lotId) => '/auctions/$code/lots/$lotId';
  static String auctionBids(String code) => '/auctions/$code/bids';
  static String auctionLiveState(String code) => '/auctions/$code/live-state';
  static String auctionInterested(String code) => '/auctions/$code/interested';
  static String auctionSubmit(String code) => '/auctions/$code/submit';

  // Bidding
  static String placeBid(String code) => '/auctions/$code/bids';
  static String proxyBid(String code) => '/auctions/$code/proxy-bid';
  static const myBids = '/my-bids';

  // Watchlist
  static const watchlist = '/watchlist';
  static String watchlistRemove(String code) => '/watchlist/$code';

  // Wallet & EMD
  static const wallet = '/wallet';
  static const walletTransactions = '/wallet/transactions';
  static const walletTopUp = '/wallet/top-up';
  static const emd = '/emd';
  static const emdLock = '/emd/lock';
  static String emdRelease(int id) => '/emd/$id/release';

  // Orders
  static const orders = '/orders';
  static String order(String code) => '/orders/$code';
  static String orderPay(String code) => '/orders/$code/pay';
  static String orderPickup(String code) => '/orders/$code/pickup';

  // Vendor / KYC
  static const vendorRegister = '/vendors/register';
  static const vendorSaveStep = '/vendors/save-step';
  static String vendorSubmitKyc(String code) => '/vendors/$code/submit-kyc';
  static String vendorResubmitKyc(String code) => '/vendors/$code/resubmit-kyc';
  static String vendorKycStatus(String code) => '/vendors/$code/kyc-status';
  static String vendorDocuments(String code) => '/vendors/$code/documents';
  static String vendorPayment(String code) => '/vendors/$code/registration-payment';

  // Business verification (provider credentials remain server-side)
  static const kybStatus = '/kyb/status';
  static const kybHistory = '/kyb/history';
  static const kybVerifyGstin = '/kyb/gstin/verify';
  static const kybVerifyBank = '/kyb/bank/verify';
  static const kybReverify = '/kyb/reverify';

  // Notifications
  static const notifications = '/notifications';
  static String notificationRead(int id) => '/notifications/$id/read';
  static const notificationsReadAll = '/notifications/read-all';
  static const notificationPreferences = '/notification-preferences';

  // RFx & Technical Evaluation
  static String auctionRfx(String code) => '/auctions/$code/rfx';
  static String submitRfx(String code, int packageId) => '/auctions/$code/rfx/$packageId/submit';

  // Site Inspection & Gate Pass
  static String auctionInspections(String code) => '/auctions/$code/inspections';
  static String verifyGatePass(String token) => '/gate-passes/verify/$token';
  static String scanGatePass(String token) => '/gate-passes/$token/scan';

  // Clarifications & Addenda
  static String auctionClarifications(String code) => '/auctions/$code/clarifications';
  static String acknowledgeAddendum(String code, int addendumId) => '/auctions/$code/addenda/$addendumId/acknowledge';

  // Awards & Fallback
  static String auctionAwards(String code) => '/auctions/$code/awards';
  static String acceptAward(int id) => '/awards/$id/accept';

  // Disputes
  static const disputes = '/disputes';
  static String dispute(String code) => '/disputes/$code';
  static String disputeMessage(String code) => '/disputes/$code/messages';
  static String disputeEvidence(String code) => '/disputes/$code/evidence';

  // Team Members
  static const teamMembers = '/team/members';
  static String teamMember(dynamic id) => '/team/members/$id';

  // Auction Terms
  static String acceptTerms(String code) => '/auctions/$code/terms/accept';
}
