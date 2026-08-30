import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class ClarificationsSheet extends StatefulWidget {
  final String auctionCode;
  final String auctionTitle;

  const ClarificationsSheet({
    super.key,
    required this.auctionCode,
    required this.auctionTitle,
  });

  static Future<void> show(BuildContext context, {required String auctionCode, required String auctionTitle}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClarificationsSheet(auctionCode: auctionCode, auctionTitle: auctionTitle),
    );
  }

  @override
  State<ClarificationsSheet> createState() => _ClarificationsSheetState();
}

class _ClarificationsSheetState extends State<ClarificationsSheet> {
  final _queryCtl = TextEditingController();
  String _category = 'Technical Specifications';

  final List<Map<String, String>> _questions = [
    {
      'question': 'Can we bring 40-foot multi-axle trailers into the plant yard for lifting?',
      'author': 'Bidder #04',
      'date': '26 Aug 2026',
      'answer': 'Yes, Gate 3 has 14-meter clearance and can accommodate 40ft hydraulic multi-axle trailers with prior gate pass token.',
      'answeredBy': 'Auctioneer (Tata Power Logistics)',
      'status': 'Published as Addendum #01',
    },
    {
      'question': 'Is weighbridge calibration certified by Weights & Measures department?',
      'author': 'Bidder #02',
      'date': '27 Aug 2026',
      'answer': 'Yes, the plant weighbridge was recalibrated on 15 August 2026. Certified copy is available under Documents tab.',
      'answeredBy': 'Plant Supervisor',
      'status': 'Answered',
    },
  ];

  void _submitQuery() {
    if (_queryCtl.text.trim().isEmpty) return;
    setState(() {
      _questions.insert(0, {
        'question': _queryCtl.text.trim(),
        'author': 'You (Devzign Solutions)',
        'date': 'Just now',
        'answer': 'Your query has been submitted to the auction committee. An official response will be published as an addendum before the event starts.',
        'answeredBy': 'Compliance Desk (Pending Review)',
        'status': 'Under Review',
      });
      _queryCtl.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✓ Pre-bid clarification submitted to auction committee')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pre-Bid Clarifications & Q&A', style: AppTextStyles.heading(size: 16, weight: FontWeight.w800)),
                  Text(widget.auctionCode, style: AppTextStyles.captionMuted),
                ],
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
            ],
          ),
          const Divider(height: 20),

          // Q&A List
          Expanded(
            child: ListView.separated(
              itemCount: _questions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final q = _questions[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.appBg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Q: ${q['author']} • ${q['date']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.navy.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(4)),
                            child: Text(q['status']!, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.navy)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(q['question']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navy)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.reply, size: 14, color: AppColors.success),
                                const SizedBox(width: 6),
                                Text(q['answeredBy']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(q['answer']!, style: const TextStyle(fontSize: 12, color: AppColors.navy, height: 1.35)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Ask Query Box
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.appBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _category,
                          isDense: true,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navy),
                          items: ['Technical Specifications', 'Commercial & Payment', 'Logistics & Lifting', 'Taxation & Invoicing']
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) => setState(() => _category = v ?? _category),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _queryCtl,
                        decoration: const InputDecoration(
                          hintText: 'Type your clarification question...',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: AppColors.navy),
                      onPressed: _submitQuery,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
