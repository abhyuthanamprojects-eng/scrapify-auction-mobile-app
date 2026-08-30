import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/fulfilment.dart';
import '../../providers/domain_providers.dart';
import '../../widgets/fulfilment/evidence_capture_sheet.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final fulfilments = ref.watch(fulfilmentsProvider);
    final order = fulfilments.firstWhere(
      (f) => f.orderId == widget.orderId,
      orElse: () => fulfilments.isNotEmpty ? fulfilments.first : _fallbackOrder(),
    );

    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        title: const Text('Fulfilment Tracking'),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.report_problem_outlined),
            tooltip: 'Raise Dispute',
            onPressed: () => context.push('/new-dispute/${order.orderId}'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.gradientNoir,
                borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
                boxShadow: AppColors.shadowSm,
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
                          color: AppColors.goldSoft.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(order.orderId, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.goldSoft)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.auction.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(order.category.toUpperCase(), style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.goldSoft)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(order.auctionTitle, style: AppTextStyles.heading(size: 16, weight: FontWeight.w800, color: AppColors.white)),
                  const SizedBox(height: 4),
                  Text('Seller: ${order.sellerCompany}', style: TextStyle(fontSize: 12, color: AppColors.white.withValues(alpha: 0.7))),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Contract Total: ${Formatters.formatINR(order.totalAmountInr)}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.white)),
                      Text('Status: ${order.status}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.goldSoft)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Dispatch Gate Pass Card (If Generated)
            if (order.gatePass != null)
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('DISPATCH GATE PASS',
                            style: TextStyle(fontFamily: 'monospace', fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text('ACTIVE & VALID',
                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.success)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: AppColors.appBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: const Icon(Icons.qr_code_2_rounded, size: 40, color: AppColors.navy),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(order.gatePass!.gatePassNumber, style: AppTextStyles.labelLarge),
                              Text('Vehicle: ${order.gatePass!.vehicleNumber} • Driver: ${order.gatePass!.driverName}', style: AppTextStyles.captionMuted),
                              Text('Valid: ${order.gatePass!.validUntil}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.navy)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Stepper Roadmap
            Text('FULFILMENT ROADMAP & EVIDENCE',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5)),
            const SizedBox(height: 12),

            ...order.stages.asMap().entries.map((entry) {
              final idx = entry.key;
              final stage = entry.value;
              final isLast = idx == order.stages.length - 1;
              return _buildStageStep(order, stage, isLast);
            }),
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
          child: ElevatedButton.icon(
            onPressed: () {
              EvidenceCaptureSheet.show(
                context,
                orderId: order.orderId,
                stage: order.currentStage,
                onEvidenceCaptured: (ev) {
                  ref.read(evidenceListProvider.notifier).capture(ev);
                  setState(() {});
                },
              );
            },
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Capture Stage Evidence', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
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

  Widget _buildStageStep(FulfilmentRecord order, FulfilmentStage stage, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left timeline line & icon
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: stage.isCompleted
                    ? AppColors.success
                    : stage.key == order.currentStage
                        ? AppColors.auction
                        : const Color(0xFFCBD5E1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: stage.isCompleted
                    ? const Icon(Icons.check, size: 16, color: AppColors.white)
                    : Text(
                        '${stage.stepNumber}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.white),
                      ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: stage.isCompleted ? AppColors.success : const Color(0xFFCBD5E1),
              ),
          ],
        ),
        const SizedBox(width: 14),
        // Stage content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(
                  color: stage.key == order.currentStage ? AppColors.auction : AppColors.cardBorder,
                  width: stage.key == order.currentStage ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(stage.label, style: AppTextStyles.labelLarge),
                      if (stage.completedAt != null)
                        Text(stage.completedAt!.split('T').first, style: AppTextStyles.captionMuted),
                    ],
                  ),
                  if (stage.evidenceUrl != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.appBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified, size: 12, color: AppColors.success),
                          const SizedBox(width: 4),
                          const Text('Digital Evidence Verified', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  FulfilmentRecord _fallbackOrder() {
    return const FulfilmentRecord(
      id: 'FUL-001',
      orderId: 'ORD-2026-1048',
      auctionCode: 'BP-FWD-2026-1048',
      title: 'Industrial Copper Scrap & Armoured Cables',
      type: FulfilmentType.materialPickup,
      stages: [
        FulfilmentStage(step: 1, title: 'Order & Award Confirmed', description: 'Award accepted and PO issued', isCompleted: true, completedAt: '2026-08-25T10:00:00'),
        FulfilmentStage(step: 2, title: '100% Payment Confirmed', description: 'Settlement cleared via RTGS', isCompleted: true, completedAt: '2026-08-26T14:30:00'),
        FulfilmentStage(step: 3, title: 'Dispatch Gate Pass Generated', description: 'Digital QR token issued', isCompleted: true, completedAt: '2026-08-27T09:00:00'),
        FulfilmentStage(step: 4, title: 'Truck Entered Yard & Gate In', description: 'Security gate scan', isCompleted: false),
        FulfilmentStage(step: 5, title: 'Tare Weight Recorded on Weighbridge', description: 'Empty truck weight recorded', isCompleted: false),
        FulfilmentStage(step: 6, title: 'Material Loading & Inspection', description: 'Loading verified by supervisor', isCompleted: false),
        FulfilmentStage(step: 7, title: 'Gross Weight & Net Weight Slips', description: 'Final weight slip verified', isCompleted: false),
        FulfilmentStage(step: 8, title: 'Exit Gate Pass & Order Closed', description: 'Lifting handover complete', isCompleted: false),
      ],
      gatePass: const GatePassData(
        passId: 'GP-DISPATCH-9912',
        qrPayload: 'SCRAPIFY-DISPATCH-GP-9912-VERIFIED',
        visitorName: 'Suresh Yadav',
        companyName: 'Devzign Solutions Pvt Ltd',
        auctionCode: 'SC-FWD-2026-1048',
        facilityName: 'Tata Power Works, Yard 3',
        date: '30 Aug 2026',
        timeSlot: '06:00 PM',
        vehicleNumber: 'JH-05-AB-1234',
      ),
    );
  }
}
