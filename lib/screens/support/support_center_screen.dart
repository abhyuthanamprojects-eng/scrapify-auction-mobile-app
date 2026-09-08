import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/file_picker_service.dart';

class SupportCenterScreen extends StatefulWidget {
  const SupportCenterScreen({super.key});

  @override
  State<SupportCenterScreen> createState() => _SupportCenterScreenState();
}

class _SupportCenterScreenState extends State<SupportCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtl;
  final _subjectCtl = TextEditingController();
  final _descCtl = TextEditingController();
  final _eventCodeCtl = TextEditingController();
  String _selectedCategory = 'Live Auction Technical Query';
  PickedAttachment? _attachedFile;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _tabCtl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtl.dispose();
    _subjectCtl.dispose();
    _descCtl.dispose();
    super.dispose();
  }

  void _submitTicket() {
    if (_subjectCtl.text.trim().isEmpty || _descCtl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill subject and detailed description'),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Support ticket submission is unavailable until the support API is enabled.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        title: const Text('Help Centre & Support'),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabCtl,
          labelColor: AppColors.auction,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
          indicatorColor: AppColors.auction,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Raise Ticket'),
            Tab(text: 'My Tickets'),
            Tab(text: 'FAQ & Helplines'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtl,
        children: [
          _buildRaiseTicketTab(),
          _buildMyTicketsTab(),
          _buildFaqHelplineTab(),
        ],
      ),
    );
  }

  Widget _buildRaiseTicketTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Emergency Helpline Strip
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppColors.gradientNoir,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              border: Border.all(
                color: AppColors.auction.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.auction,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.flash_on,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency Live Auction Desk',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                        ),
                      ),
                      Text(
                        'Direct operator assistance for live bidding rooms: 1800 200 4890',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Form Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: AppColors.shadowSm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Raise a Support Ticket',
                  style: AppTextStyles.heading(
                    size: 16,
                    weight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Select category and describe the issue for fastest turnaround.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Issue Category *',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      [
                            'Live Auction Technical Query',
                            'Payment / EMD Settlement',
                            'KYB & Company Verification',
                            'Dispute & Arbitration Appeal',
                            'Gate Pass & Lifting Assistance',
                            'General Platform Feedback',
                          ]
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                c,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => setState(
                    () => _selectedCategory = v ?? _selectedCategory,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _eventCodeCtl,
                  decoration: const InputDecoration(
                    labelText: 'Related Auction / Order Code (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _subjectCtl,
                  decoration: const InputDecoration(
                    labelText: 'Subject / Summary *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descCtl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Detailed Description *',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),

                // Attachment Picker Card
                InkWell(
                  onTap: () async {
                    final picked = await AppFilePicker.showPickerBottomSheet(
                      context,
                      title: 'Attach Support File / Screenshot',
                    );
                    if (picked != null) {
                      setState(() => _attachedFile = picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.appBg,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(
                        color: _attachedFile != null
                            ? AppColors.accentBlue
                            : AppColors.cardBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _attachedFile != null
                                ? AppColors.accentBlue.withValues(alpha: 0.15)
                                : const Color(0xFFE2E8F0),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _attachedFile != null
                                ? (_attachedFile!.isImage
                                      ? Icons.image
                                      : Icons.picture_as_pdf)
                                : Icons.attach_file,
                            color: _attachedFile != null
                                ? AppColors.accentBlue
                                : const Color(0xFF64748B),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _attachedFile != null
                                    ? _attachedFile!.name
                                    : 'Attach screenshot, invoice or error log',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _attachedFile != null
                                      ? AppColors.navy
                                      : const Color(0xFF64748B),
                                ),
                              ),
                              Text(
                                _attachedFile != null
                                    ? _attachedFile!.formattedSize
                                    : 'PNG, JPG, PDF up to 10MB (Optional)',
                                style: AppTextStyles.captionMuted,
                              ),
                            ],
                          ),
                        ),
                        if (_attachedFile != null)
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 18,
                              color: AppColors.destructive,
                            ),
                            onPressed: () =>
                                setState(() => _attachedFile = null),
                          )
                        else
                          const Text(
                            'Browse',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _creating ? null : _submitTicket,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusXl,
                        ),
                      ),
                    ),
                    child: _creating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Submit Support Request',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyTicketsTab() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Support ticket history is unavailable until the support API is enabled.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildFaqHelplineTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _faqTile(
          'How does anti-sniping extension work?',
          'If a valid bid is placed in the last 3 minutes of an auction, the closing clock automatically extends by 3 minutes to guarantee fair bidding opportunity for all participants.',
        ),
        _faqTile(
          'When is my EMD security deposit refunded?',
          'For unsuccessful bidders, EMD security deposits are unblocked instantly upon event closure. Bank payouts reflect within 2 to 4 business hours via RTGS.',
        ),
        _faqTile(
          'What is the procedure for H2 Fallback offers?',
          'If the H1 winner defaults on balance settlement or fails mandatory compliance, the contract is offered to the H2 bidder at the prevailing H1 price or reserve threshold.',
        ),
        _faqTile(
          'How do I generate a digital Gate Pass for inspection?',
          'Navigate to the Event Details -> Inspection tab, select an available date/slot, enter visitor and vehicle details, and download your high-contrast QR Gate Pass.',
        ),
      ],
    );
  }

  Widget _faqTile(String q, String a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ExpansionTile(
        title: Text(
          q,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(
            a,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
