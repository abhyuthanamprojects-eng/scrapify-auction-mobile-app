import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/team_member.dart';
import '../../providers/domain_providers.dart';

class TeamManagementScreen extends ConsumerWidget {
  const TeamManagementScreen({super.key});

  void _addMemberDialog(BuildContext context, WidgetRef ref) {
    final nameCtl = TextEditingController();
    final emailCtl = TextEditingController();
    final mobileCtl = TextEditingController();
    final limitCtl = TextEditingController(text: '5000000');
    String role = 'Authorized Bidder';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
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
              Text('Add Corporate Bidder', style: AppTextStyles.heading(size: 17, weight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('Delegate bidding limits and event access to team members.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const SizedBox(height: 16),
              TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: emailCtl, decoration: const InputDecoration(labelText: 'Corporate Email', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: mobileCtl, decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(
                controller: limitCtl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Max Bidding Limit (₹)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: role,
                decoration: const InputDecoration(labelText: 'Role Permission', border: OutlineInputBorder()),
                items: ['Administrator', 'Authorized Bidder', 'Viewer / Observer']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setModalState(() => role = v ?? role),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtl.text.trim().isEmpty) return;
                    final member = TeamMember(
                      id: 'TM-00${DateTime.now().millisecondsSinceEpoch % 100}',
                      name: nameCtl.text.trim(),
                      email: emailCtl.text.trim(),
                      mobile: mobileCtl.text.trim(),
                      role: TeamRole.values.firstWhere(
                        (r) => r.label == role,
                        orElse: () => TeamRole.authorizedBidder,
                      ),
                      maxBiddingLimitInr: double.tryParse(limitCtl.text.trim()) ?? 5000000,
                      isActive: true,
                      allowedCategories: const ['All Categories'],
                    );
                    ref.read(teamMembersProvider.notifier).addMember(member);
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✓ Team member authorization updated')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
                  ),
                  child: const Text('Add Authorized Member', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(teamMembersProvider);

    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        title: const Text('Team & Authorized Bidders'),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addMemberDialog(context, ref),
        backgroundColor: AppColors.auction,
        icon: const Icon(Icons.person_add, color: AppColors.white),
        label: const Text('Add Member', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.white)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: members.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final m = members[i];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: AppColors.shadowSm,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.navy.withValues(alpha: 0.1),
                  child: Text(
                    m.name.isNotEmpty ? m.name.substring(0, 1) : 'U',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.navy),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(m.name, style: AppTextStyles.labelLarge),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.navy.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(m.role.label, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('${m.email} • ${m.mobile}', style: AppTextStyles.captionMuted),
                      const SizedBox(height: 4),
                      Text(
                        'Max Bid Limit: ${Formatters.formatINR(m.maxBiddingLimitInr)}',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.auction),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: m.isActive,
                  activeColor: AppColors.success,
                  onChanged: (_) => ref.read(teamMembersProvider.notifier).toggleStatus(m.id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
