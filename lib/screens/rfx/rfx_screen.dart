import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/rfx.dart';
import '../../providers/domain_providers.dart';
import '../../services/auction_service.dart';

class RfxScreen extends ConsumerStatefulWidget {
  final String auctionCode;
  const RfxScreen({super.key, required this.auctionCode});

  @override
  ConsumerState<RfxScreen> createState() => _RfxScreenState();
}

class _RfxScreenState extends ConsumerState<RfxScreen> {
  late Map<String, dynamic> _answers;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _answers = {};
  }

  @override
  Widget build(BuildContext context) {
    final pkg = ref.watch(rfxProvider(widget.auctionCode)).valueOrNull;

    if (pkg == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('RFx Questionnaire')),
        body: const Center(child: Text('No RFx questionnaire available for this event')),
      );
    }

    final total = pkg.questions.length;
    final answered = _answers.length;

    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        title: const Text('Technical RFx Response'),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Header
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.purple.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text('PREQUALIFICATION QUESTIONNAIRE',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.purple)),
                      ),
                      Text(
                        '$answered / $total Complete',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.navy),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(pkg.title, style: AppTextStyles.heading(size: 16, weight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Buyer: ${pkg.buyerName}', style: AppTextStyles.captionMuted),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : (answered / total).clamp(0.0, 1.0),
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation(AppColors.purple),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Continue on Web Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.blueLight.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.desktop_mac_outlined, size: 18, color: AppColors.accentBlue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'For extensive multi-line BOQs (> 50 items), you can also submit on the Scrapify Web Portal.',
                      style: TextStyle(fontSize: 11, color: AppColors.navy.withValues(alpha: 0.8), height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Questions List
            ...pkg.questions.map((q) => _buildQuestionCard(q)),
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
          height: 52,
          child: ElevatedButton(
            onPressed: answered < total || _submitted
                ? null
                : () async {
                    setState(() => _submitted = true);
                    try {
                      await AuctionService().submitRfx(widget.auctionCode, int.parse(pkg.id), _answers);
                    } catch (_) {
                      if (mounted) setState(() => _submitted = false);
                      return;
                    }
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✓ Technical RFx Response Submitted Successfully')),
                      );
                      context.pop();
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
              elevation: 0,
            ),
            child: _submitted
                ? const CircularProgressIndicator(color: AppColors.white)
                : const Text(
                    'Submit Technical Proposal',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(RfxQuestion q) {
    final current = _answers[q.id];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: AppColors.navy.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(q.section, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
              ),
              const Spacer(),
              if (current != null)
                const Icon(Icons.check_circle, color: AppColors.success, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(q.questionText, style: AppTextStyles.labelLarge),
          const SizedBox(height: 12),

          // Render by Type
          if (q.type == RfxQuestionType.boolean)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _answers[q.id] = true),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: current == true ? AppColors.navy : Colors.transparent,
                      foregroundColor: current == true ? AppColors.white : AppColors.navy,
                      side: BorderSide(color: current == true ? AppColors.navy : AppColors.cardBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
                    ),
                    child: const Text('Yes', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _answers[q.id] = false),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: current == false ? AppColors.navy : Colors.transparent,
                      foregroundColor: current == false ? AppColors.white : AppColors.navy,
                      side: BorderSide(color: current == false ? AppColors.navy : AppColors.cardBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
                    ),
                    child: const Text('No', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            )
          else if (q.type == RfxQuestionType.number)
            Container(
              decoration: BoxDecoration(
                color: AppColors.appBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: TextFormField(
                initialValue: current?.toString() ?? '',
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => _answers[q.id] = v),
                decoration: const InputDecoration(
                  hintText: 'Enter numeric value...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            )
          else if (q.type == RfxQuestionType.text)
            Container(
              decoration: BoxDecoration(
                color: AppColors.appBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: TextFormField(
                initialValue: current?.toString() ?? '',
                maxLines: 3,
                onChanged: (v) => setState(() => _answers[q.id] = v),
                decoration: const InputDecoration(
                  hintText: 'Type your detailed proposal response here...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            )
          else if (q.type == RfxQuestionType.fileAttachment)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.appBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.attach_file, color: AppColors.purple),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      current != null ? 'fleet-permit-verified.pdf' : 'Attach required certification',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: current != null ? AppColors.navy : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _answers[q.id] = 'https://docs.scrapify.io/doc.pdf'),
                    child: Text(current != null ? 'Replace' : 'Upload',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.purple)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
