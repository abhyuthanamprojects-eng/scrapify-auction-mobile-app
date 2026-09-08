import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../services/auction_service.dart';

class ClarificationsSheet extends StatefulWidget {
  final String auctionCode;
  final String auctionTitle;

  const ClarificationsSheet({
    super.key,
    required this.auctionCode,
    required this.auctionTitle,
  });

  static Future<void> show(
    BuildContext context, {
    required String auctionCode,
    required String auctionTitle,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClarificationsSheet(
        auctionCode: auctionCode,
        auctionTitle: auctionTitle,
      ),
    );
  }

  @override
  State<ClarificationsSheet> createState() => _ClarificationsSheetState();
}

class _ClarificationsSheetState extends State<ClarificationsSheet> {
  final _queryCtl = TextEditingController();
  final _auctionService = AuctionService();
  String _category = 'Technical Specifications';
  List<Map<String, String>> _questions = [];
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final response = await _auctionService.getClarifications(
        widget.auctionCode,
      );
      final rows = response['data'] as List? ?? const [];
      if (!mounted) return;
      setState(() {
        _questions = rows.whereType<Map>().map((raw) {
          final q = raw.map((key, value) => MapEntry(key.toString(), value));
          return <String, String>{
            'question': '${q['question'] ?? q['question_text'] ?? ''}',
            'author': '${q['author'] ?? q['asked_by'] ?? 'Participant'}',
            'date': '${q['date'] ?? q['created_at'] ?? ''}',
            'answer': '${q['answer'] ?? q['response'] ?? ''}',
            'answeredBy': '${q['answered_by'] ?? q['responded_by'] ?? ''}',
            'status': '${q['status'] ?? 'Published'}',
          };
        }).toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitQuery() async {
    if (_queryCtl.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    try {
      await _auctionService.askClarification(
        widget.auctionCode,
        _queryCtl.text.trim(),
        section: _category,
      );
      _queryCtl.clear();
      await _loadQuestions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clarification submitted.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to submit clarification: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pre-Bid Clarifications & Q&A',
                    style: AppTextStyles.heading(
                      size: 16,
                      weight: FontWeight.w800,
                    ),
                  ),
                  Text(widget.auctionCode, style: AppTextStyles.captionMuted),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(height: 20),

          // Q&A List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _questions.isEmpty
                ? const Center(
                    child: Text(
                      'No published clarifications for this auction.',
                    ),
                  )
                : ListView.separated(
                    itemCount: _questions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final q = _questions[i];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.appBg,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusXl,
                          ),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Q: ${q['author']} • ${q['date']}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.navy.withValues(
                                      alpha: 0.08,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    q['status']!,
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.navy,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              q['question']!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navy,
                              ),
                            ),
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
                                      const Icon(
                                        Icons.reply,
                                        size: 14,
                                        color: AppColors.success,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        q['answeredBy']!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    q['answer']!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.navy,
                                      height: 1.35,
                                    ),
                                  ),
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
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                          items:
                              [
                                    'Technical Specifications',
                                    'Commercial & Payment',
                                    'Logistics & Lifting',
                                    'Taxation & Invoicing',
                                  ]
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) =>
                              setState(() => _category = v ?? _category),
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
                      icon: const Icon(
                        Icons.send_rounded,
                        color: AppColors.navy,
                      ),
                      onPressed: _submitting ? null : _submitQuery,
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
