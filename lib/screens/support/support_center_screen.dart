import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class SupportCenterScreen extends StatefulWidget {
  const SupportCenterScreen({super.key});

  @override
  State<SupportCenterScreen> createState() => _SupportCenterScreenState();
}

class _SupportCenterScreenState extends State<SupportCenterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtl;
  final _subjectCtl = TextEditingController();
  final _descCtl = TextEditingController();
  final _eventCodeCtl = TextEditingController(text: 'BP-FWD-2026-1048');
  String _selectedCategory = 'Live Auction Technical Query';
  bool _creating = false;

  final List<Map<String, String>> _tickets = [
    {
      'id': 'TKT-2026-0412',
      'subject': 'Proxy Bid limit adjustment for Lot #01',
      'category': 'Live Auction Technical Query',
      'eventCode': 'BP-FWD-2026-1048',
      'status': 'In Progress',
      'createdAt': 'Today, 11:20 AM',
      'latestResponse': 'Technical desk is verifying proxy trigger threshold on bidding engine.',
    },
    {
      'id': 'TKT-2026-0390',
      'subject': 'EMD Refund clearance for closed event #BP-FWD-2026-0890',
      'category': 'Payment / EMD Settlement',
      'eventCode': 'BP-FWD-2026-0890',
      'status': 'Resolved',
      'createdAt': '24 Aug 2026',
      'latestResponse': '₹50,000 security deposit unblocked and credited to primary wallet.',
    },
  ];

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
        const SnackBar(content: Text('Please fill subject and detailed description')),
      );
      return;
    }
    setState(() => _creating = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _creating = false;
        _tickets.insert(0, {
          'id': 'TKT-2026-0${DateTime.now().millisecondsSinceEpoch % 1000}',
          'subject': _subjectCtl.text.trim(),
          'category': _selectedCategory,
          'eventCode': _eventCodeCtl.text.trim(),
          'status': 'Open',
          'createdAt': 'Just now',
          'latestResponse': 'Ticket queued for Priority Level 1 support team.',
        });
        _subjectCtl.clear();
        _descCtl.clear();
        _tabCtl.animateTo(1);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✓ Support ticket raised. Reference assigned.')),
      );
    });
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
              border: Border.all(color: AppColors.auction.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: AppColors.auction, shape: BoxShape.circle),
                  child: const Icon(Icons.flash_on, color: AppColors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Emergency Live Auction Desk', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.white)),
                      Text('Direct operator assistance for live bidding rooms: 1800 200 4890', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
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
                Text('Raise a Support Ticket', style: AppTextStyles.heading(size: 16, weight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('Select category and describe the issue for fastest turnaround.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Issue Category *', border: OutlineInputBorder()),
                  items: [
                    'Live Auction Technical Query',
                    'Payment / EMD Settlement',
                    'KYB & Company Verification',
                    'Dispute & Arbitration Appeal',
                    'Gate Pass & Lifting Assistance',
                    'General Platform Feedback',
                  ].map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v ?? _selectedCategory),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _eventCodeCtl,
                  decoration: const InputDecoration(labelText: 'Related Auction / Order Code (Optional)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _subjectCtl,
                  decoration: const InputDecoration(labelText: 'Subject / Summary *', border: OutlineInputBorder()),
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
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _creating ? null : _submitTicket,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
                    ),
                    child: _creating
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                        : const Text('Submit Support Request', style: TextStyle(fontWeight: FontWeight.w800)),
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
    if (_tickets.isEmpty) {
      return const Center(child: Text('No active support tickets found'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _tickets.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final t = _tickets[i];
        final isResolved = t['status'] == 'Resolved';
        return Container(
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
                  Text(t['id']!, style: AppTextStyles.mono),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isResolved ? AppColors.success.withValues(alpha: 0.12) : AppColors.auction.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      t['status']!,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isResolved ? AppColors.success : AppColors.auction),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(t['subject']!, style: AppTextStyles.heading(size: 14.5, weight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('${t['category']} • ${t['createdAt']}', style: AppTextStyles.captionMuted),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.appBg, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.support_agent, size: 16, color: AppColors.accentBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(t['latestResponse']!, style: const TextStyle(fontSize: 11.5, color: AppColors.navy, height: 1.35)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFaqHelplineTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _faqTile('How does anti-sniping extension work?', 'If a valid bid is placed in the last 3 minutes of an auction, the closing clock automatically extends by 3 minutes to guarantee fair bidding opportunity for all participants.'),
        _faqTile('When is my EMD security deposit refunded?', 'For unsuccessful bidders, EMD security deposits are unblocked instantly upon event closure. Bank payouts reflect within 2 to 4 business hours via RTGS.'),
        _faqTile('What is the procedure for H2 Fallback offers?', 'If the H1 winner defaults on balance settlement or fails mandatory compliance, the contract is offered to the H2 bidder at the prevailing H1 price or reserve threshold.'),
        _faqTile('How do I generate a digital Gate Pass for inspection?', 'Navigate to the Event Details -> Inspection tab, select an available date/slot, enter visitor and vehicle details, and download your high-contrast QR Gate Pass.'),
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
        title: Text(q, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(a, style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4)),
        ],
      ),
    );
  }
}
