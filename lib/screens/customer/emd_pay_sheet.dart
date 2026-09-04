import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/file_picker_service.dart';
import '../../core/utils/formatters.dart';

class EmdPaySheet extends StatefulWidget {
  final String auctionTitle;
  final double emdAmount;
  final double emdPercent;
  final void Function(String mode, String reference) onPay;

  const EmdPaySheet({
    super.key,
    required this.auctionTitle,
    required this.emdAmount,
    required this.emdPercent,
    required this.onPay,
  });

  @override
  State<EmdPaySheet> createState() => _EmdPaySheetState();
}

class _EmdPaySheetState extends State<EmdPaySheet> {
  String _mode = 'gateway'; // 'gateway' | 'neft'
  final _refController = TextEditingController();
  PickedAttachment? _slipAttachment;

  bool get _canPay =>
      _mode == 'gateway' || (_refController.text.trim().length >= 6 && _slipAttachment != null);

  @override
  void dispose() {
    _refController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPaddingH,
        AppSpacing.screenPaddingH,
        AppSpacing.screenPaddingH,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.blackWithOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            'Pay EMD',
            style: AppTextStyles.heading(size: 18, weight: FontWeight.w800),
          ),
          Text(
            '${widget.auctionTitle} • ${widget.emdPercent}% EMD',
            style: AppTextStyles.body(size: 12, color: AppColors.navyWithOpacity(0.6)),
          ),

          // Amount
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.appBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amount payable',
                  style: AppTextStyles.body(size: 12, color: AppColors.navyWithOpacity(0.6)),
                ),
                Text(
                  Formatters.formatINR(widget.emdAmount),
                  style: AppTextStyles.heading(size: 20, weight: FontWeight.w800),
                ),
              ],
            ),
          ),

          // Mode selector
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.appBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Row(
              children: [
                _modeTab('gateway', 'Payment gateway'),
                _modeTab('neft', 'NEFT / RTGS'),
              ],
            ),
          ),

          // Mode content
          const SizedBox(height: 16),
          if (_mode == 'neft') ...[
            // Bank info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentBlueWithOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Text.rich(
                TextSpan(
                  style: AppTextStyles.body(size: 11, color: AppColors.accentBlue),
                  children: const [
                    TextSpan(text: 'Transfer to '),
                    TextSpan(text: 'Scrapify Escrow A/C 5011 2233 4455', style: TextStyle(fontWeight: FontWeight.w700)),
                    TextSpan(text: ', IFSC '),
                    TextSpan(text: 'HDFC0000123', style: TextStyle(fontWeight: FontWeight.w700)),
                    TextSpan(text: ', then upload the transaction slip.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // UTR input
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.appBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.blackWithOpacity(0.05)),
              ),
              child: TextField(
                controller: _refController,
                onChanged: (_) => setState(() {}),
                style: AppTextStyles.body(size: 14, weight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'UTR / NEFT reference number',
                  hintStyle: AppTextStyles.body(size: 14, color: AppColors.navyWithOpacity(0.4)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Upload slip button
            GestureDetector(
              onTap: () async {
                final picked = await AppFilePicker.showPickerBottomSheet(
                  context,
                  title: 'Upload Bank Payment Slip (NEFT/RTGS)',
                );
                if (picked != null) {
                  setState(() => _slipAttachment = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _slipAttachment != null ? AppColors.success.withValues(alpha: 0.08) : AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(
                    color: _slipAttachment != null ? AppColors.success : AppColors.blackWithOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _slipAttachment != null ? Icons.check_circle : Icons.upload_file,
                      size: 20,
                      color: _slipAttachment != null ? AppColors.success : AppColors.navy,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _slipAttachment != null ? _slipAttachment!.name : 'Upload payment slip',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body(
                              size: 13,
                              weight: FontWeight.w600,
                              color: AppColors.navy,
                            ),
                          ),
                          if (_slipAttachment != null)
                            Text(
                              '${_slipAttachment!.formattedSize} • Ready to verify',
                              style: const TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.w600),
                            ),
                        ],
                      ),
                    ),
                    if (_slipAttachment != null)
                      GestureDetector(
                        onTap: () => setState(() => _slipAttachment = null),
                        child: const Icon(Icons.close, size: 18, color: AppColors.destructive),
                      )
                    else
                      const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF94A3B8)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'NEFT payments show as EMD Pending until the admin confirms the reference.',
              style: AppTextStyles.body(size: 11, color: AppColors.navyWithOpacity(0.5)),
            ),
          ] else ...[
            Text(
              'You\'ll be taken to the secure gateway. Gateway payments confirm instantly.',
              style: AppTextStyles.body(size: 11, color: AppColors.navyWithOpacity(0.5)),
            ),
          ],

          // Pay button
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _canPay
                ? () {
                    final ref = _mode == 'gateway'
                        ? 'EMDPAY${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}'
                        : _refController.text.trim();
                    widget.onPay(_mode, ref);
                    Navigator.of(context).pop();
                  }
                : null,
            child: Opacity(
              opacity: _canPay ? 1.0 : 0.4,
              child: Container(
                width: double.infinity,
                height: AppSpacing.buttonXl,
                decoration: BoxDecoration(
                  color: AppColors.auction,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                alignment: Alignment.center,
                child: Text(
                  _mode == 'gateway'
                      ? 'Pay ${Formatters.formatINR(widget.emdAmount)}'
                      : 'Submit for verification',
                  style: AppTextStyles.body(size: 14, weight: FontWeight.w700, color: AppColors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeTab(String mode, String label) {
    final selected = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mode = mode),
        child: Container(
          height: AppSpacing.buttonMd,
          decoration: BoxDecoration(
            color: selected ? AppColors.navy : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.body(
              size: 12,
              weight: FontWeight.w700,
              color: selected ? AppColors.white : AppColors.navyWithOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }
}
