import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/award.dart';
import '../models/order.dart';
import '../models/fulfilment.dart';
import '../models/dispute.dart';
import '../models/team_member.dart';
import '../models/performance.dart';
import '../models/rfx.dart';
import '../models/inspection.dart';
import '../models/evidence.dart';
import '../services/auction_service.dart';
import '../services/order_service.dart';

// Awards
final awardsProvider = StateNotifierProvider<AwardsNotifier, List<Award>>((ref) {
  return AwardsNotifier();
});

class AwardsNotifier extends StateNotifier<List<Award>> {
  AwardsNotifier() : super(const []);

  Future<void> accept(String id) async {
    await AuctionService().acceptAward(int.parse(id));
    state = state.map((a) => a.id == id ? a.copyWith(status: AwardStatus.accepted) : a).toList();
  }

  void decline(String id, String reason) {
    state = state.map((a) => a.id == id ? a.copyWith(status: AwardStatus.declined, declinedReason: reason) : a).toList();
  }
}

final awardDetailProvider = Provider.family<Award?, String>((ref, id) {
  final awards = ref.watch(awardsProvider);
  try {
    return awards.firstWhere((a) => a.id == id);
  } catch (_) {
    return null;
  }
});

// Orders
final ordersProvider = FutureProvider<List<Order>>((ref) {
  return OrderService().list();
});

// Fulfilment
final fulfilmentsProvider = Provider<List<FulfilmentRecord>>((ref) {
  return const [];
});

// Disputes
final disputesProvider = StateNotifierProvider<DisputesNotifier, List<DisputeItem>>((ref) {
  return DisputesNotifier();
});

class DisputesNotifier extends StateNotifier<List<DisputeItem>> {
  DisputesNotifier() : super(const []);

  void addDispute(DisputeItem item) {
    state = [item, ...state];
  }
}

// Team Members
final teamMembersProvider = StateNotifierProvider<TeamNotifier, List<TeamMember>>((ref) {
  return TeamNotifier();
});

class TeamNotifier extends StateNotifier<List<TeamMember>> {
  TeamNotifier() : super(const []);

  void addMember(TeamMember tm) {
    state = [tm, ...state];
  }

  void toggleStatus(String id) {
    state = state
        .map(
          (member) => member.id == id
              ? TeamMember(
                  id: member.id,
                  name: member.name,
                  email: member.email,
                  mobile: member.mobile,
                  role: member.role,
                  maxBiddingLimitInr: member.maxBiddingLimitInr,
                  isActive: !member.isActive,
                  joinedAt: member.joinedAt,
                  allowedCategories: member.allowedCategories,
                )
              : member,
        )
        .toList();
  }
}

// Performance
final performanceProvider = Provider<VendorPerformance>((ref) {
  return const VendorPerformance(
    totalAuctionsParticipated: 0,
    totalWins: 0,
    winRatePercentage: 0,
    totalAwardValueInr: 0,
    onTimeFulfilmentRate: 0,
    complianceScore: 0,
    totalDisputes: 0,
    resolvedDisputes: 0,
    tierBadge: 'Verified',
    rankInCategory: 0,
  );
});

// RFx
final rfxProvider = FutureProvider.family<RfxPackage?, String>((ref, code) async {
  final response = await AuctionService().getRfx(code);
  final rows = response['data'] as List? ?? const [];
  if (rows.isEmpty) return null;
  final first = rows.first as Map<String, dynamic>;
  final questions = (first['questions'] as List? ?? const [])
      .map((raw) => _questionFromJson(raw as Map<String, dynamic>))
      .toList();
  return RfxPackage(
    id: '${first['id'] ?? ''}',
    auctionCode: code,
    title: first['title'] as String? ?? 'RFx Questionnaire',
    buyerName: first['buyer_name'] as String? ?? '',
    submissionDeadline: first['submission_deadline'] as String? ?? '',
    questions: questions,
    isSubmitted: first['is_submitted'] as bool? ?? false,
    submittedAt: first['submitted_at'] as String?,
    technicalScore: (first['technical_score'] as num?)?.toDouble(),
  );
});

RfxQuestion _questionFromJson(Map<String, dynamic> json) {
  final type = switch ((json['type'] as String? ?? 'text').toLowerCase()) {
    'number' => RfxQuestionType.number,
    'boolean' => RfxQuestionType.boolean,
    'select' || 'dropdown' => RfxQuestionType.dropdown,
    'multi_select' => RfxQuestionType.multiSelect,
    'file' || 'file_attachment' => RfxQuestionType.fileAttachment,
    _ => RfxQuestionType.text,
  };
  return RfxQuestion(
    id: '${json['id'] ?? ''}',
    section: json['section'] as String? ?? 'General',
    questionText: json['title'] as String? ?? json['question_text'] as String? ?? '',
    type: type,
    isRequired: json['mandatory'] as bool? ?? json['is_required'] as bool? ?? true,
    options: (json['options'] as List?)?.map((e) => '$e').toList() ?? const [],
  );
}

// Inspection
final inspectionBookingsProvider = StateNotifierProvider<InspectionNotifier, List<InspectionBooking>>((ref) {
  return InspectionNotifier();
});

class InspectionNotifier extends StateNotifier<List<InspectionBooking>> {
  InspectionNotifier() : super(const []);

  void book(InspectionBooking booking) {
    state = [booking, ...state];
  }
}

// Evidence
final evidenceListProvider = StateNotifierProvider<EvidenceNotifier, List<CapturedEvidence>>((ref) {
  return EvidenceNotifier();
});

class EvidenceNotifier extends StateNotifier<List<CapturedEvidence>> {
  EvidenceNotifier() : super(const []);

  void capture(CapturedEvidence ev) {
    state = [ev, ...state];
  }
}
