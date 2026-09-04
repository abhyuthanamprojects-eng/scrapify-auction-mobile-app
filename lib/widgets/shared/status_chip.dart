import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color? color;
  final bool showDot;
  final bool animate;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    this.color,
    this.showDot = false,
    this.animate = false,
    this.icon,
  });

  factory StatusChip.live() => const StatusChip(
        label: 'LIVE',
        color: AppColors.destructive,
        showDot: true,
        animate: true,
      );

  factory StatusChip.fromStatus(String status) {
    final s = status.toLowerCase();
    return switch (s) {
      'live' => const StatusChip(label: 'LIVE', color: AppColors.destructive, showDot: true, animate: true),
      'upcoming' || 'scheduled' => const StatusChip(label: 'Upcoming', color: AppColors.auction, icon: Icons.schedule),
      'preview' => const StatusChip(label: 'Preview', color: AppColors.accentBlue, icon: Icons.visibility_outlined),
      'extended' => const StatusChip(label: 'Extended', color: AppColors.warning, icon: Icons.timer),
      'paused' => const StatusChip(label: 'Paused', color: AppColors.warning, icon: Icons.pause_circle_outline),
      'closed' || 'ended' => const StatusChip(label: 'Closed', color: AppColors.navy, icon: Icons.lock_outline),
      'won' => const StatusChip(label: 'Won', color: AppColors.success, icon: Icons.emoji_events_outlined),
      'lost' => const StatusChip(label: 'Lost', color: AppColors.navy, icon: Icons.close),
      'leading' => const StatusChip(label: 'Rank #1', color: AppColors.success, icon: Icons.check_circle_outline),
      'outbid' => const StatusChip(label: 'Outbid', color: AppColors.destructive, icon: Icons.warning_amber_rounded),
      'under_evaluation' || 'awaiting_approval' => const StatusChip(label: 'Under Review', color: AppColors.purple, icon: Icons.hourglass_top),
      'awarded' => const StatusChip(label: 'Awarded', color: AppColors.accentBlue, icon: Icons.verified_outlined),
      'fallback_offered' => const StatusChip(label: 'Fallback Offer', color: AppColors.auction, icon: Icons.replay),
      'cancelled' => const StatusChip(label: 'Cancelled', color: AppColors.destructive, icon: Icons.cancel_outlined),
      _ => StatusChip(label: status, color: AppColors.navy),
    };
  }

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.navy;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withValues(alpha: 0.2), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            _LiveDot(color: c, animate: animate),
            const SizedBox(width: 4),
          ] else if (icon != null) ...[
            Icon(icon, size: 11, color: c),
            const SizedBox(width: 3.5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: c,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class AuctionTypeChip extends StatelessWidget {
  final String direction; // forward, reverse, rfq, sealed, multi_lot, line_item
  final bool compact;

  const AuctionTypeChip({
    super.key,
    required this.direction,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final d = direction.toLowerCase();
    final (label, icon, color) = switch (d) {
      'reverse' => ('Reverse Auction', Icons.trending_down, AppColors.accentBlue),
      'rfq' => ('RFQ / Tender', Icons.request_quote_outlined, AppColors.purple),
      'sealed' => ('Sealed Bid', Icons.lock_outline, AppColors.navy),
      'lot_wise' || 'multi_lot' => ('Multi-Lot', Icons.layers_outlined, AppColors.auction),
      'line_item' => ('Line-Item', Icons.list_alt, AppColors.accentBlue),
      _ => ('Forward Auction', Icons.trending_up, AppColors.auction),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8, vertical: compact ? 2 : 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 10 : 12, color: color),
          const SizedBox(width: 3.5),
          Text(
            compact ? label.split(' ').first : label,
            style: TextStyle(
              fontSize: compact ? 9.5 : 10.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class EmdStatusChip extends StatelessWidget {
  final String status; // held, refund_due, refunded, paid, pending, forfeited

  const EmdStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    final (label, icon, color) = switch (s) {
      'held' || 'locked' => ('Held in Escrow', Icons.shield_outlined, AppColors.accentBlue),
      'paid' => ('EMD Paid', Icons.check_circle_outline, AppColors.success),
      'refund_due' => ('Refund Due', Icons.history_toggle_off, AppColors.auction),
      'refunded' => ('Refunded', Icons.replay_circle_filled, AppColors.success),
      'forfeited' => ('Forfeited', Icons.error_outline, AppColors.destructive),
      _ => ('EMD Required', Icons.payment, AppColors.warning),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

class _LiveDot extends StatefulWidget {
  final Color color;
  final bool animate;
  const _LiveDot({required this.color, required this.animate});

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.animate) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 8,
      height: 8,
      child: Stack(
        children: [
          if (widget.animate)
            AnimatedBuilder(
              animation: _controller,
              builder: (_, _) => Opacity(
                opacity: 1 - _controller.value,
                child: Transform.scale(
                  scale: 1 + _controller.value,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color,
                    ),
                  ),
                ),
              ),
            ),
          Center(
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

