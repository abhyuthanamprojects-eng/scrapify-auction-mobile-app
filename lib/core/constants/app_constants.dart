abstract final class AppConstants {
  static const appName = 'Scrapify';
  static const appTagline = 'Industrial Scrap Auction Platform';
  static const mockDelay = Duration(milliseconds: 600);
  static const currencySymbol = '₹';
  static const locale = 'en_IN';

  // Categories
  static const categories = [
    'IT Assets',
    'Mobiles',
    'PCBs',
    'Cables',
    'Batteries',
    'Appliances',
    'Mixed Lots',
    'Metals',
  ];

  // Indian cities
  static const cities = [
    'Mumbai',
    'Delhi',
    'Chennai',
    'Jaipur',
    'Bangalore',
    'Hyderabad',
    'Pune',
    'Ahmedabad',
  ];

  // Onboarding
  static const onboardingSlides = [
    (
      title: 'Discover Auctions',
      subtitle: 'Browse industrial scrap lots from verified sellers across India',
      icon: '🔍',
    ),
    (
      title: 'Live Bidding',
      subtitle: 'Bid in real-time with auto-extend timers and instant notifications',
      icon: '⚡',
    ),
    (
      title: 'Escrow Secure',
      subtitle: 'Your money is protected with EMD locks and verified transactions',
      icon: '🔒',
    ),
  ];

  // Bid increments
  static const quickIncrements = [500, 1000, 5000];

  // Add money quick amounts
  static const quickAmounts = [1000, 5000, 10000, 25000];
}
