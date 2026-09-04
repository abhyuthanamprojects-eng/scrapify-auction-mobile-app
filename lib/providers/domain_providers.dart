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

  Future<void> decline(String id, String reason) async {
    await AuctionService().declineAward(int.parse(id), reason);
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
final fulfilmentsProvider = FutureProvider<List<FulfilmentRecord>>((ref) async {
  final data = await OrderService().list();
  return data.map((o) => FulfilmentRecord(
    id: o.code,
    orderId: o.code,
    auctionCode: o.code,
    title: 'Order ${o.code}',
    type: FulfilmentType.materialPickup,
    currentStageIndex: 0,
    stages: [],
  )).toList();
});

// Disputes
final disputesProvider = StateNotifierProvider<DisputesNotifier, List<DisputeItem>>((ref) {
  return DisputesNotifier();
});

class DisputesNotifier extends StateNotifier<List<DisputeItem>> {
  DisputesNotifier() : super(const []);

  Future<void> addDispute(Map<String, dynamic> body) async {
    final result = await AuctionService().raiseDispute(body);
    final item = DisputeItem(
      id: result['code'] ?? result['id'] ?? '',
      auctionCode: body['auction_code'] ?? '',
      auctionTitle: body['auction_title'] ?? '',
      orderNumber: body['order_id'] ?? '',
      title: body['subject'] ?? '',
      description: body['description'] ?? '',
      status: DisputeStatus.raised,
      createdDate: DateTime.now().toIso8601String().split('T').first,
    );
    state = [item, ...state];
  }
}

// Team Members
final teamMembersProvider = StateNotifierProvider<TeamNotifier, List<TeamMember>>((ref) {
  return TeamNotifier();
});

class TeamNotifier extends StateNotifier<List<TeamMember>> {
  TeamNotifier() : super(const []);

  Future<void> addMember(Map<String, dynamic> body) async {
    final result = await AuctionService().addTeamMember(body);
    final roleStr = (result['role'] ?? 'vendorAdmin').toString().toLowerCase();
    final role = switch(roleStr) {
      'bidder' || 'authorized_bidder' => TeamRole.authorizedBidder,
      'inspector' || 'field_inspector' => TeamRole.fieldInspector,
      'finance' || 'finance_approver' => TeamRole.financeApprover,
      _ => TeamRole.vendorAdmin,
    };
    final tm = TeamMember(
      id: result['id']?.toString() ?? '',
      name: result['name'] ?? '',
      email: result['email'] ?? '',
      mobile: result['mobile'] ?? '',
      role: role,
      maxBiddingLimitInr: (result['max_bidding_limit_inr'] as num?)?.toDouble() ?? 0.0,
      isActive: result['is_active'] ?? true,
      joinedAt: result['joined_at'] ?? DateTime.now().toString(),
      allowedCategories: List<String>.from(result['allowed_categories'] as List? ?? []),
    );
    state = [tm, ...state];
  }

  Future<void> toggleStatus(String id) async {
    final member = state.firstWhere((m) => m.id == id);
    await AuctionService().updateTeamMember(int.parse(id), {'is_active': !member.isActive});
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
final performanceProvider = FutureProvider<VendorPerformance>((ref) async {
  try {
    return const VendorPerformance(
      totalAuctionsParticipated: 12,
      totalWins: 8,
      winRatePercentage: 66.67,
      totalAwardValueInr: 4500000,
      onTimeFulfilmentRate: 95,
      complianceScore: 98,
      totalDisputes: 1,
      resolvedDisputes: 1,
      tierBadge: 'Gold',
      rankInCategory: 3,
    );
  } catch (_) {
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
  }
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

  Future<void> book(String auctionCode, Map<String, dynamic> body) async {
    final result = await AuctionService().bookInspection(auctionCode, body);
    final booking = InspectionBooking(
      bookingId: result['id']?.toString() ?? 'INS-${DateTime.now().millisecondsSinceEpoch}',
      auctionCode: auctionCode,
      auctionTitle: result['auction_title'] ?? '',
      facilityAddress: result['facility_address'] ?? '',
      contactPerson: result['contact_person'] ?? '',
      contactPhone: result['contact_phone'] ?? '',
      selectedDate: body['date'] ?? '',
      selectedTimeSlot: body['slot'] ?? '',
      visitorName: body['visitor_name'] ?? '',
      visitorMobile: body['visitor_mobile'] ?? '',
      visitorGovtId: body['visitor_govt_id'] ?? '',
      vehicleNumber: body['vehicle_number'] ?? '',
      numberOfVisitors: body['number_of_visitors'] ?? 1,
      isConfirmed: true,
      gatePassToken: result['gate_pass_token'],
    );
    state = [booking, ...state];
  }
}

// Evidence
final evidenceListProvider = StateNotifierProvider<EvidenceNotifier, List<CapturedEvidence>>((ref) {
  return EvidenceNotifier();
});

class EvidenceNotifier extends StateNotifier<List<CapturedEvidence>> {
  EvidenceNotifier() : super(const []);

  Future<void> capture(String disputeCode, Map<String, dynamic> body) async {
    final result = await AuctionService().uploadDisputeEvidence(disputeCode, body);
    final typeStr = (body['type'] ?? 'photo').toString().toLowerCase();
    final type = switch(typeStr) {
      'weighbridge' || 'weighbridgeslip' => EvidenceType.weighbridgeSlip,
      'serial' || 'serialnumberscan' => EvidenceType.serialNumberScan,
      'pdf' || 'documentpdf' => EvidenceType.documentPdf,
      'signature' || 'digitalsignature' => EvidenceType.digitalSignature,
      _ => EvidenceType.photo,
    };
    final ev = CapturedEvidence(
      id: result['id']?.toString() ?? 'EV-${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      title: '${type.name.toUpperCase()} Evidence',
      fileUrl: result['file_url'],
      timestamp: DateTime.now().toIso8601String(),
      remarks: body['remarks'],
      capturedBy: result['captured_by'],
      geoCoordinates: result['geo_coordinates'],
      status: result['status'],
      metricValue: body['metric_value']?.toString(),
      isUploaded: true,
    );
    state = [ev, ...state];
  }
}
