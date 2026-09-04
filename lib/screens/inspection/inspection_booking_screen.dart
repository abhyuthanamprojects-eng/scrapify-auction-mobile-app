import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/auction_provider.dart';
import '../../providers/domain_providers.dart';

class InspectionBookingScreen extends ConsumerStatefulWidget {
  final String auctionCode;
  const InspectionBookingScreen({super.key, required this.auctionCode});

  @override
  ConsumerState<InspectionBookingScreen> createState() => _InspectionBookingScreenState();
}

class _InspectionBookingScreenState extends ConsumerState<InspectionBookingScreen> {
  String _selectedDate = '28 Aug 2026';
  String _selectedSlot = '11:30 AM – 12:30 PM';

  final _nameCtl = TextEditingController(text: 'Rahul Sharma');
  final _mobileCtl = TextEditingController(text: '+91 98765 43210');
  final _govtIdCtl = TextEditingController(text: 'PAN: ABCDE1234F');
  final _vehicleCtl = TextEditingController(text: 'JH-05-AB-1234');
  int _visitorsCount = 2;
  bool _submitting = false;

  final _slots = const [
    '10:00 AM – 11:00 AM',
    '11:30 AM – 12:30 PM',
    '02:00 PM – 03:00 PM',
    '03:30 PM – 04:30 PM',
  ];

  @override
  void dispose() {
    _nameCtl.dispose();
    _mobileCtl.dispose();
    _govtIdCtl.dispose();
    _vehicleCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auctionAsync = ref.watch(auctionDetailProvider(widget.auctionCode));

    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        title: const Text('Book Site Inspection'),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: auctionAsync.when(
        data: (auction) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Requirement Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: AppColors.shadowSm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.auction.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text('PHYSICAL INSPECTION',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.auction)),
                        ),
                        const Spacer(),
                        const Icon(Icons.location_on, color: AppColors.auction, size: 16),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(auction.title, style: AppTextStyles.labelLarge),
                    const SizedBox(height: 4),
                    Text(
                      auction.inspectionLocation ?? 'Main Factory Gate 3, Plant Site',
                      style: AppTextStyles.captionMuted,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Contact: ${auction.inspectionContact ?? "Site Security Officer"}',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.navy),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Date Selection
              _sectionHeader('Select Inspection Date'),
              const SizedBox(height: 8),
              Row(
                children: ['28 Aug 2026', '29 Aug 2026', '30 Aug 2026'].map((d) {
                  final sel = _selectedDate == d;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDate = d),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.navy : AppColors.white,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                          border: Border.all(color: sel ? AppColors.navy : AppColors.cardBorder),
                          boxShadow: sel ? AppColors.shadowSm : null,
                        ),
                        child: Center(
                          child: Text(
                            d,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: sel ? AppColors.white : AppColors.navy,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Time Slot Selection
              _sectionHeader('Available Time Slots'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _slots.map((s) {
                  final sel = _selectedSlot == s;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSlot = s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.auction : AppColors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        border: Border.all(color: sel ? AppColors.auction : AppColors.cardBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule, size: 14, color: sel ? AppColors.white : AppColors.navy),
                          const SizedBox(width: 6),
                          Text(
                            s,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: sel ? AppColors.white : AppColors.navy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Visitor Form
              _sectionHeader('Visitor Information for Security Clearance'),
              const SizedBox(height: 10),
              _field('Lead Visitor Name', _nameCtl, Icons.person_outline),
              _field('Mobile Number', _mobileCtl, Icons.phone_outlined),
              _field('Govt ID (PAN / Aadhaar / DL)', _govtIdCtl, Icons.badge_outlined),
              _field('Vehicle Registration Number', _vehicleCtl, Icons.directions_car_outlined),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Number of Visitors', style: AppTextStyles.labelMedium),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: _visitorsCount > 1 ? () => setState(() => _visitorsCount--) : null,
                      ),
                      Text('$_visitorsCount', style: AppTextStyles.labelLarge),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: _visitorsCount < 5 ? () => setState(() => _visitorsCount++) : null,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: const Border(top: BorderSide(color: AppColors.cardBorder)),
          boxShadow: AppColors.shadowLg,
        ),
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _submitting
                ? null
                : () async {
                    setState(() => _submitting = true);
                    try {
                      await ref.read(inspectionBookingsProvider.notifier).book(widget.auctionCode, {
                        'visitor_name': _nameCtl.text.trim(),
                        'visitor_mobile': _mobileCtl.text.trim(),
                        'visitor_govt_id': _govtIdCtl.text.trim(),
                        'vehicle_number': _vehicleCtl.text.trim(),
                        'number_of_visitors': _visitorsCount,
                        'slot': _selectedSlot,
                        'date': _selectedDate,
                      });
                      if (mounted) {
                        context.pushReplacement('/gate-pass/${widget.auctionCode}');
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                        setState(() => _submitting = false);
                      }
                    }
                  },
            icon: const Icon(Icons.qr_code_2_rounded),
            label: _submitting
                ? const CircularProgressIndicator(color: AppColors.white)
                : const Text('Confirm Booking & Issue Gate Pass',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.auction,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.3),
    );
  }

  Widget _field(String label, TextEditingController ctl, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navy)),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: TextField(
              controller: ctl,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.navy),
              decoration: InputDecoration(
                prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
