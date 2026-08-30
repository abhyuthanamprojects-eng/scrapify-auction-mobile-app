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
import '../services/mock_bidplay_repository.dart';

final mockRepoProvider = Provider<MockBidPlayRepository>((ref) => MockBidPlayRepository());

// Awards
final awardsProvider = StateNotifierProvider<AwardsNotifier, List<Award>>((ref) {
  return AwardsNotifier(ref.watch(mockRepoProvider));
});

class AwardsNotifier extends StateNotifier<List<Award>> {
  final MockBidPlayRepository _repo;
  AwardsNotifier(this._repo) : super(_repo.getAwards());

  void accept(String id) {
    _repo.acceptAward(id);
    state = _repo.getAwards();
  }

  void decline(String id, String reason) {
    _repo.declineAward(id, reason);
    state = _repo.getAwards();
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
final ordersProvider = Provider<List<Order>>((ref) {
  return ref.watch(mockRepoProvider).getOrders();
});

// Fulfilment
final fulfilmentsProvider = Provider<List<FulfilmentRecord>>((ref) {
  return ref.watch(mockRepoProvider).getFulfilments();
});

// Disputes
final disputesProvider = StateNotifierProvider<DisputesNotifier, List<DisputeItem>>((ref) {
  return DisputesNotifier(ref.watch(mockRepoProvider));
});

class DisputesNotifier extends StateNotifier<List<DisputeItem>> {
  final MockBidPlayRepository _repo;
  DisputesNotifier(this._repo) : super(_repo.getDisputes());

  void addDispute(DisputeItem item) {
    _repo.addDispute(item);
    state = _repo.getDisputes();
  }
}

// Team Members
final teamMembersProvider = StateNotifierProvider<TeamNotifier, List<TeamMember>>((ref) {
  return TeamNotifier(ref.watch(mockRepoProvider));
});

class TeamNotifier extends StateNotifier<List<TeamMember>> {
  final MockBidPlayRepository _repo;
  TeamNotifier(this._repo) : super(_repo.getTeamMembers());

  void addMember(TeamMember tm) {
    _repo.addTeamMember(tm);
    state = _repo.getTeamMembers();
  }

  void toggleStatus(String id) {
    _repo.toggleTeamMember(id);
    state = _repo.getTeamMembers();
  }
}

// Performance
final performanceProvider = Provider<VendorPerformance>((ref) {
  return ref.watch(mockRepoProvider).getPerformance();
});

// RFx
final rfxProvider = Provider.family<RfxPackage?, String>((ref, code) {
  return ref.watch(mockRepoProvider).getRfx(code);
});

// Inspection
final inspectionBookingsProvider = StateNotifierProvider<InspectionNotifier, List<InspectionBooking>>((ref) {
  return InspectionNotifier(ref.watch(mockRepoProvider));
});

class InspectionNotifier extends StateNotifier<List<InspectionBooking>> {
  final MockBidPlayRepository _repo;
  InspectionNotifier(this._repo) : super(_repo.getInspectionBookings());

  void book(InspectionBooking booking) {
    _repo.addInspectionBooking(booking);
    state = _repo.getInspectionBookings();
  }
}

// Evidence
final evidenceListProvider = StateNotifierProvider<EvidenceNotifier, List<CapturedEvidence>>((ref) {
  return EvidenceNotifier(ref.watch(mockRepoProvider));
});

class EvidenceNotifier extends StateNotifier<List<CapturedEvidence>> {
  final MockBidPlayRepository _repo;
  EvidenceNotifier(this._repo) : super(_repo.getEvidenceList());

  void capture(CapturedEvidence ev) {
    _repo.addEvidence(ev);
    state = _repo.getEvidenceList();
  }
}
