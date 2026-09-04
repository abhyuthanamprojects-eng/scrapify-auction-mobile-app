import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/file_picker_service.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/shared/screen_header.dart';

class PayableSummaryScreen extends StatefulWidget {
  final String auctionTitle;
  final double h1Value;
  final double emdAmount;
  final VoidCallback onBack;
  final VoidCallback? onPayBalance;
  final VoidCallback? onUploadSlip;
  final VoidCallback? onDownloadAwardLetter;

  const PayableSummaryScreen({
    super.key,
    required this.auctionTitle,
    required this.h1Value,
    required this.emdAmount,
    required this.onBack,
    this.onPayBalance,
    this.onUploadSlip,
    this.onDownloadAwardLetter,
  });

  @override
  State<PayableSummaryScreen> createState() => _PayableSummaryScreenState();
}

class _PayableSummaryScreenState extends State<PayableSummaryScreen> {
  bool _paid = false;
  String? _selectedSlot;

  double get _gst => widget.h1Value * 0.18;
  double get _tcs => widget.h1Value * 0.01;
  double get _balance => widget.h1Value + _gst + _tcs - widget.emdAmount;

  @override
  Widget build(BuildContext context) {
    final slots = ['12 Aug · AM', '13 Aug · AM', '14 Aug · PM'];

    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: Column(
        children: [
          ScreenHeader(
            title: 'Award & payment',
            subtitle: widget.auctionTitle,
            onBack: widget.onBack,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPaddingH,
                0,
                AppSpacing.screenPaddingH,
                AppSpacing.bottomNavPadding,
              ),
              children: [
                // Payable summary
                _card(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.blackWithOpacity(0.05))),
                        ),
                        child: Text(
                          'PAYABLE SUMMARY (H1)',
                          style: AppTextStyles.body(
                            size: 10,
                            weight: FontWeight.w700,
                            color: AppColors.navyWithOpacity(0.5),
                          ).copyWith(letterSpacing: 1.0),
                        ),
                      ),
                      _kvRow('H1 value', Formatters.formatINR(widget.h1Value)),
                      _divider(),
                      _kvRow('GST @ 18%', Formatters.formatINR(_gst)),
                      _divider(),
                      _kvRow('TCS @ 1%', Formatters.formatINR(_tcs)),
                      _divider(),
                      _kvRow('Less: EMD held', '- ${Formatters.formatINR(widget.emdAmount)}'),
                      _divider(),
                      _kvRow('Balance payable', Formatters.formatINR(_balance), strong: true),
                    ],
                  ),
                ),

                // Award letter
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: widget.onDownloadAwardLetter,
                  child: _card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.description, size: 18, color: AppColors.navy),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Award letter',
                                  style: AppTextStyles.body(size: 14, weight: FontWeight.w700, color: AppColors.navy),
                                ),
                                Text(
                                  'PDF • issued by Scrapify Auction',
                                  style: AppTextStyles.body(size: 11, color: AppColors.navyWithOpacity(0.5)),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.download, size: 16, color: AppColors.accentBlue),
                        ],
                      ),
                    ),
                  ),
                ),

                // Pay balance / Payment recorded
                const SizedBox(height: 12),
                if (!_paid)
                  _card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pay balance',
                            style: AppTextStyles.body(size: 14, weight: FontWeight.w700, color: AppColors.navy),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Gateway payment, or upload an NEFT/RTGS transfer slip for verification.',
                            style: AppTextStyles.body(size: 11, color: AppColors.navyWithOpacity(0.55)),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => _paid = true);
                                    widget.onPayBalance?.call();
                                  },
                                  child: Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.auction,
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Pay ${Formatters.formatINR(_balance)}',
                                      style: AppTextStyles.body(size: 12, weight: FontWeight.w700, color: AppColors.white),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    final picked = await AppFilePicker.showPickerBottomSheet(
                                      context,
                                      title: 'Upload Balance Payment Slip (NEFT/RTGS)',
                                    );
                                    if (picked != null) {
                                      setState(() => _paid = true);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('✓ Payment slip "${picked.name}" submitted for verification')),
                                        );
                                      }
                                      widget.onUploadSlip?.call();
                                    }
                                  },
                                  child: Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                                      border: Border.all(color: AppColors.blackWithOpacity(0.1)),
                                    ),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.upload_file, size: 14, color: AppColors.navy),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Upload slip',
                                          style: AppTextStyles.body(size: 12, weight: FontWeight.w700, color: AppColors.navy),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.successWithOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                      border: Border.all(color: AppColors.successWithOpacity(0.25)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 20, color: AppColors.success),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment recorded',
                                style: AppTextStyles.body(size: 14, weight: FontWeight.w700, color: AppColors.success),
                              ),
                              Text(
                                'Invoice and gate pass unlock once finance verifies.',
                                style: AppTextStyles.body(size: 11, color: AppColors.successWithOpacity(0.8)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Lifting schedule
                const SizedBox(height: 12),
                _card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.local_shipping, size: 17, color: AppColors.navy),
                            const SizedBox(width: 8),
                            Text(
                              'Lifting schedule',
                              style: AppTextStyles.body(size: 14, weight: FontWeight.w700, color: AppColors.navy),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: slots.map((s) {
                            final selected = _selectedSlot == s;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: s != slots.last ? 8 : 0),
                                child: GestureDetector(
                                  onTap: _paid ? () => setState(() => _selectedSlot = s) : null,
                                  child: Opacity(
                                    opacity: _paid ? 1.0 : 0.4,
                                    child: Container(
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: selected ? AppColors.navy : AppColors.appBg,
                                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        s,
                                        style: AppTextStyles.body(
                                          size: 11,
                                          weight: FontWeight.w700,
                                          color: selected ? AppColors.white : AppColors.navy,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        if (_selectedSlot != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.appBg,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'GATE PASS',
                                  style: AppTextStyles.body(
                                    size: 10,
                                    color: AppColors.navyWithOpacity(0.5),
                                  ).copyWith(letterSpacing: 0.5),
                                ),
                                Text(
                                  'GP-2026-88421',
                                  style: AppTextStyles.mono.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.navy,
                                    letterSpacing: 3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Slot $_selectedSlot • show this at the plant gate with a photo ID.',
                                  style: AppTextStyles.body(size: 11, color: AppColors.navyWithOpacity(0.55)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Delivery status stepper
                const SizedBox(height: 12),
                _card(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'DELIVERY STATUS',
                            style: AppTextStyles.body(
                              size: 10,
                              weight: FontWeight.w700,
                              color: AppColors.navyWithOpacity(0.5),
                            ).copyWith(letterSpacing: 1.0),
                          ),
                        ),
                      ),
                      ...[
                        _DeliveryStep('Payment', _paid),
                        _DeliveryStep('Gate pass issued', _selectedSlot != null),
                        _DeliveryStep('Material lifted', false),
                        _DeliveryStep('Completed', false),
                      ].map((step) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(top: BorderSide(color: AppColors.blackWithOpacity(0.05))),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: step.done ? AppColors.success : AppColors.navyWithOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  size: 12,
                                  color: step.done ? AppColors.white : AppColors.navyWithOpacity(0.4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                step.label,
                                style: AppTextStyles.body(size: 12, weight: FontWeight.w600, color: AppColors.navy),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.blackWithOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackWithOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _kvRow(String label, String value, {bool strong = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body(
              size: 12,
              weight: strong ? FontWeight.w700 : FontWeight.w400,
              color: strong ? AppColors.navy : AppColors.navyWithOpacity(0.6),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body(
              size: 13,
              weight: strong ? FontWeight.w800 : FontWeight.w600,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, thickness: 1, color: AppColors.blackWithOpacity(0.05));
  }
}

class _DeliveryStep {
  final String label;
  final bool done;
  const _DeliveryStep(this.label, this.done);
}
