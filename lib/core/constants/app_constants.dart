abstract final class AppConstants {
  static const appName = 'Scrapify Auctions';
  static const appTagline =
      'Enterprise Auction & Strategic Sourcing Marketplace';
  static const currencySymbol = '₹';
  static const locale = 'en_IN';

  // Generic Auction & Procurement Categories
  static const categories = [
    'All Categories',
    'Metals & Scrap',
    'Machinery & Plant',
    'IT Assets & Electronics',
    'Vehicles & Fleet',
    'Raw Materials',
    'Inventory & Stock',
    'Logistics & Freight',
    'Facility Management',
    'Construction & Equipment',
    'Service Contracts',
    'Packaging & Bulk',
  ];

  // Indian Industrial Hubs & Cities
  static const cities = [
    'Gurugram',
    'Mumbai',
    'Bengaluru',
    'Delhi NCR',
    'Chennai',
    'Hyderabad',
    'Pune',
    'Ahmedabad',
    'Kolkata',
    'Jamshedpur',
    'Surat',
    'Jaipur',
  ];

  // Indian States
  static const states = [
    'Maharashtra',
    'Haryana',
    'Karnataka',
    'Delhi',
    'Tamil Nadu',
    'Telangana',
    'Gujarat',
    'Uttar Pradesh',
    'West Bengal',
    'Rajasthan',
    'Jharkhand',
  ];

  // Onboarding Slides
  static const onboardingSlides = [
    (
      title: 'Discover Opportunities',
      subtitle:
          'Participate in verified forward & reverse auctions across diverse enterprise categories.',
      icon: '🔍',
    ),
    (
      title: 'Bid in Real Time',
      subtitle:
          'Secure live bidding with auto-bid proxy, anti-snipe extensions, and instant outbid alerts.',
      icon: '⚡',
    ),
    (
      title: 'Manage Full Lifecycle',
      subtitle:
          'Track EMD security, digital gate passes, awards, fulfilment evidence, and payments in one place.',
      icon: '🔒',
    ),
  ];

  // Quick Bid Increments / Decrements
  static const quickIncrements = [5000, 10000, 25000, 50000];

  // Add Money Quick Amounts
  static const quickAmounts = [10000, 25000, 50000, 100000];
}
