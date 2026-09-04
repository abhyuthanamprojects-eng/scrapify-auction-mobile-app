import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/file_picker_service.dart';
import '../../providers/domain_providers.dart';

class NewDisputeScreen extends ConsumerStatefulWidget {
  final String orderId;
  const NewDisputeScreen({super.key, required this.orderId});

  @override
  ConsumerState<NewDisputeScreen> createState() => _NewDisputeScreenState();
}

class _NewDisputeScreenState extends ConsumerState<NewDisputeScreen> {
  String _category = 'Quantity Variance / Weight Shortage';
  final _amountCtl = TextEditingController(text: '45000');
  final _titleCtl = TextEditingController();
  final _descCtl = TextEditingController();
  PickedAttachment? _attachedEvidence;
  bool _submitting = false;

  final _categories = const [
    'Quantity Variance / Weight Shortage',
    'Grade / Material Quality Mismatch',
    'Damaged Goods on Delivery',
    'Non-Delivery / Yard Access Refusal',
    'Lifting Delay / Demurrage Dispute',
    'Overcharging / Tariff Discrepancy',
  ];

  @override
  void dispose() {
    _amountCtl.dispose();
    _titleCtl.dispose();
    _descCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        title: const Text('Raise Commercial Dispute'),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notice
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Disputes are reviewed by the Scrapify Commercial Arbitration Board within 24 hours. Relevant weighbridge slips and site photos will expedite resolution.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.navy.withValues(alpha: 0.85), height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Category Dropdown
            Text('Dispute Category', style: AppTextStyles.labelMedium),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _category,
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _category = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Claim Amount
            Text('Claimed Amount (₹)', style: AppTextStyles.labelMedium),
            const SizedBox(height: 6),
            TextField(
              controller: _amountCtl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'e.g. 50000',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Summary Title
            Text('Short Summary', style: AppTextStyles.labelMedium),
            const SizedBox(height: 6),
            TextField(
              controller: _titleCtl,
              decoration: const InputDecoration(
                hintText: 'e.g. 0.85 MT weight shortage on tare weighment',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Text('Detailed Evidence Description', style: AppTextStyles.labelMedium),
            const SizedBox(height: 6),
            TextField(
              controller: _descCtl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe exact discrepancies, yard timings, driver statements, and invoice references...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Evidence Upload Box
            Text('Supporting Evidence (Weighbridge Slip / Photos / Invoices)', style: AppTextStyles.labelMedium),
            const SizedBox(height: 6),
            InkWell(
              onTap: () async {
                final picked = await AppFilePicker.showPickerBottomSheet(
                  context,
                  title: 'Attach Commercial Dispute Evidence',
                );
                if (picked != null) {
                  setState(() => _attachedEvidence = picked);
                }
              },
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(
                    color: _attachedEvidence != null ? AppColors.success.withValues(alpha: 0.5) : AppColors.cardBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _attachedEvidence != null
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.auction.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _attachedEvidence != null
                            ? (_attachedEvidence!.isImage ? Icons.image : Icons.picture_as_pdf)
                            : Icons.attach_file,
                        color: _attachedEvidence != null ? AppColors.success : AppColors.auction,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _attachedEvidence != null
                                ? _attachedEvidence!.name
                                : 'Tap to attach weighbridge slip, photos or PDF',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: _attachedEvidence != null ? AppColors.navy : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _attachedEvidence != null
                                ? '${_attachedEvidence!.formattedSize} • Ready to upload'
                                : 'Supports Camera, Gallery, PDF up to 10MB',
                            style: AppTextStyles.captionMuted,
                          ),
                        ],
                      ),
                    ),
                    if (_attachedEvidence != null)
                      IconButton(
                        icon: const Icon(Icons.close, size: 18, color: AppColors.destructive),
                        onPressed: () => setState(() => _attachedEvidence = null),
                        tooltip: 'Remove',
                      )
                    else
                      TextButton.icon(
                        onPressed: () async {
                          final picked = await AppFilePicker.showPickerBottomSheet(
                            context,
                            title: 'Attach Commercial Dispute Evidence',
                          );
                          if (picked != null) {
                            setState(() => _attachedEvidence = picked);
                          }
                        },
                        icon: const Icon(Icons.upload, size: 16),
                        label: const Text('Browse', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: const Border(top: BorderSide(color: AppColors.cardBorder)),
          boxShadow: AppColors.shadowLg,
        ),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _submitting
                ? null
                : () async {
                    setState(() => _submitting = true);
                    try {
                      await ref.read(disputesProvider.notifier).addDispute({
                        'order_id': widget.orderId,
                        'category': _category,
                        'subject': _titleCtl.text.trim().isNotEmpty ? _titleCtl.text.trim() : _category,
                        'description': _descCtl.text.trim().isNotEmpty
                            ? _descCtl.text.trim()
                            : 'Material weighment variance reported against manifest.',
                        'claimed_amount': double.tryParse(_amountCtl.text.trim()) ?? 45000,
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✓ Dispute filed successfully. Arbitration ticket generated.')),
                        );
                        context.pop();
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
              elevation: 0,
            ),
            child: _submitting
                ? const CircularProgressIndicator(color: AppColors.white)
                : const Text('Submit Commercial Claim', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ),
        ),
      ),
    );
  }
}
