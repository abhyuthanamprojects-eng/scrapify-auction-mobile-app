import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/evidence.dart';

class EvidenceCaptureSheet extends StatefulWidget {
  final String orderId;
  final String stage;
  final Function(CapturedEvidence evidence) onEvidenceCaptured;

  const EvidenceCaptureSheet({
    super.key,
    required this.orderId,
    required this.stage,
    required this.onEvidenceCaptured,
  });

  static Future<void> show(
    BuildContext context, {
    required String orderId,
    required String stage,
    required Function(CapturedEvidence evidence) onEvidenceCaptured,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EvidenceCaptureSheet(
        orderId: orderId,
        stage: stage,
        onEvidenceCaptured: onEvidenceCaptured,
      ),
    );
  }

  @override
  State<EvidenceCaptureSheet> createState() => _EvidenceCaptureSheetState();
}

class _EvidenceCaptureSheetState extends State<EvidenceCaptureSheet> {
  EvidenceType _selectedType = EvidenceType.photo;
  final _remarksCtl = TextEditingController();
  final _metricValCtl = TextEditingController();
  bool _signed = false;
  bool _uploading = false;

  @override
  void dispose() {
    _remarksCtl.dispose();
    _metricValCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.camera_alt_outlined, color: AppColors.auction),
              const SizedBox(width: 8),
              Text('Capture Fulfilment Evidence', style: AppTextStyles.heading(size: 17, weight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Stage: ${widget.stage} • Order: ${widget.orderId}', style: AppTextStyles.captionMuted),
          const SizedBox(height: 16),

          // Evidence Type Selector Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _typeChip('Camera Photo', Icons.photo_camera, EvidenceType.photo),
                _typeChip('Weighbridge Slip', Icons.scale, EvidenceType.weighbridgeSlip),
                _typeChip('Serial OCR', Icons.document_scanner, EvidenceType.serialNumberScan),
                _typeChip('Document PDF', Icons.picture_as_pdf, EvidenceType.documentPdf),
                _typeChip('Digital Signature', Icons.draw, EvidenceType.digitalSignature),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Form fields based on selected type
          if (_selectedType == EvidenceType.weighbridgeSlip) ...[
            TextField(
              controller: _metricValCtl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Gross / Tare Weight (Metric Tonnes)',
                hintText: 'e.g. 18.450 MT',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
          ],

          if (_selectedType == EvidenceType.digitalSignature) ...[
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.appBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Center(
                child: _signed
                    ? const Text('✓ Digital Signature Recorded',
                        style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.success))
                    : TextButton.icon(
                        onPressed: () => setState(() => _signed = true),
                        icon: const Icon(Icons.draw),
                        label: const Text('Tap to Sign'),
                      ),
              ),
            ),
            const SizedBox(height: 12),
          ] else ...[
            // Photo Preview Placeholder
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.appBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.cardBorder, style: BorderStyle.solid),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_a_photo_outlined, size: 36, color: AppColors.navy),
                    SizedBox(height: 4),
                    Text('Capture Photo with GPS & Timestamp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          TextField(
            controller: _remarksCtl,
            decoration: const InputDecoration(
              labelText: 'Remarks / Notes',
              hintText: 'e.g. Driver verified, truck loaded in bay 4...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _uploading
                  ? null
                  : () async {
                      setState(() => _uploading = true);
                      final ev = CapturedEvidence(
                        id: 'EV-${DateTime.now().millisecondsSinceEpoch % 10000}',
                        type: _selectedType,
                        title: '${_selectedType.name.toUpperCase()} Evidence',
                        fileUrl: 'https://cdn.bidplay.io/evidence/ev1.jpg',
                        timestamp: DateTime.now().toIso8601String(),
                        capturedBy: 'Yard Supervisor / Driver',
                        geoCoordinates: '22.8046° N, 86.2029° E (Tata Plant Yard)',
                        remarks: _remarksCtl.text.trim(),
                        status: 'VERIFIED',
                        metricValue: _metricValCtl.text.trim().isNotEmpty ? _metricValCtl.text.trim() : null,
                      );
                      widget.onEvidenceCaptured(ev);
                      await Future.delayed(const Duration(milliseconds: 300));
                      if (mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✓ Fulfilment evidence captured & verified on ledger')),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.auction,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
              ),
              child: _uploading
                  ? const CircularProgressIndicator(color: AppColors.white)
                  : const Text('Save & Verify Evidence', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeChip(String label, IconData icon, EvidenceType type) {
    final isSel = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? AppColors.navy : AppColors.appBg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: isSel ? AppColors.navy : AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isSel ? AppColors.white : AppColors.navy),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                color: isSel ? AppColors.white : AppColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
