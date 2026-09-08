import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/domain_providers.dart';

class GatePassScreen extends ConsumerWidget {
  final String auctionCode;
  const GatePassScreen({super.key, required this.auctionCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(inspectionBookingsProvider);
    final matchingBookings = bookings.where((b) => b.auctionCode == auctionCode);
    final booking = matchingBookings.isEmpty ? null : matchingBookings.first;

    if (booking == null) {
      return Scaffold(
        backgroundColor: AppColors.appBg,
        appBar: AppBar(
          title: const Text('Digital Gate Pass'),
          backgroundColor: AppColors.navy,
          foregroundColor: AppColors.white,
          leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('No issued gate pass is available for this auction.'),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text('Digital Gate Pass'),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gate Pass link shared')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Ticket Pass Container
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: AppColors.shadowNoir,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Pass Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        gradient: AppColors.gradientNoir,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle, color: AppColors.success, size: 12),
                                    SizedBox(width: 4),
                                    Text(
                                      'VALID FOR ENTRY',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.success),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                booking.bookingId,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.goldSoft),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            booking.auctionTitle,
                            style: AppTextStyles.heading(size: 16, weight: FontWeight.w800, color: AppColors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Facility: ${booking.facilityAddress}',
                            style: TextStyle(fontSize: 11.5, color: AppColors.white.withValues(alpha: 0.7)),
                          ),
                        ],
                      ),
                    ),

                    // QR Code Area
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      child: Column(
                        children: [
                          Container(
                            width: 170,
                            height: 170,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.cardBorder, width: 2),
                              boxShadow: AppColors.shadowSm,
                            ),
                            child: const Center(
                              child: Icon(Icons.qr_code_2_rounded, size: 140, color: AppColors.navy),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'TOKEN: ${booking.gatePassToken ?? "SCRAPIFY-PASS-VERIFIED"}',
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),

                    // Perforated Divider
                    Row(
                      children: List.generate(
                        30,
                        (i) => Expanded(
                          child: Container(
                            height: 2,
                            color: i % 2 == 0 ? Colors.transparent : const Color(0xFFCBD5E1),
                          ),
                        ),
                      ),
                    ),

                    // Visitor & Vehicle Information
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _row('Authorized Visitor', booking.visitorName),
                          _row('Visitor Mobile', booking.visitorMobile),
                          _row('Govt ID', booking.visitorGovtId),
                          _row('Vehicle Reg Number', booking.vehicleNumber),
                          _row('Date of Visit', booking.selectedDate),
                          _row('Valid Time Slot', booking.selectedTimeSlot),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Security Instruction Notice
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.goldSoft, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Present this digital pass at the plant security gate. Physical helmet and safety shoes are mandatory for yard entry.',
                        style: TextStyle(fontSize: 11.5, color: AppColors.white.withValues(alpha: 0.85), height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Download Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gate Pass PDF saved to device downloads')),
                    );
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download Pass (PDF)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.auction,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navy)),
        ],
      ),
    );
  }
}
