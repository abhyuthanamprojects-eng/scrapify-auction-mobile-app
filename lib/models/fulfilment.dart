import 'package:equatable/equatable.dart';

enum FulfilmentType {
  materialPickup,
  goodsProcurement,
  serviceContract,
  logisticsPod;

  String get label => switch (this) {
        materialPickup => 'Material Pickup & Lifting',
        goodsProcurement => 'Goods Procurement & GRN',
        serviceContract => 'Service Contract Milestones',
        logisticsPod => 'Logistics & Proof of Delivery',
      };
}

class FulfilmentStage extends Equatable {
  final int step;
  final String title;
  final String description;
  final bool isCompleted;
  final String? completedAt;
  final String? actionRequired;

  const FulfilmentStage({
    required this.step,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.completedAt,
    this.actionRequired,
  });

  int get stepNumber => step;
  String get label => title;
  String get key => 'step_$step';
  String? get evidenceUrl => null;

  factory FulfilmentStage.fromJson(Map<String, dynamic> json) => FulfilmentStage(
        step: json['step'] as int? ?? 1,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        isCompleted: json['is_completed'] as bool? ?? false,
        completedAt: json['completed_at'] as String?,
        actionRequired: json['action_required'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'step': step,
        'title': title,
        'description': description,
        'is_completed': isCompleted,
        'completed_at': completedAt,
        'action_required': actionRequired,
      };

  @override
  List<Object?> get props => [step, title, isCompleted];
}

class GatePassData extends Equatable {
  final String passId;
  final String qrPayload;
  final String visitorName;
  final String companyName;
  final String auctionCode;
  final String facilityName;
  final String date;
  final String timeSlot;
  final String vehicleNumber;
  final bool isValid;

  const GatePassData({
    required this.passId,
    required this.qrPayload,
    required this.visitorName,
    required this.companyName,
    required this.auctionCode,
    required this.facilityName,
    required this.date,
    required this.timeSlot,
    required this.vehicleNumber,
    this.isValid = true,
  });

  String get gatePassNumber => passId;
  String get validUntil => '$date, $timeSlot';
  String get driverName => visitorName;
  String get qrToken => qrPayload;

  factory GatePassData.fromJson(Map<String, dynamic> json) => GatePassData(
        passId: json['pass_id'] as String? ?? 'GP-${DateTime.now().millisecondsSinceEpoch}',
        qrPayload: json['qr_payload'] as String? ?? 'SCRAPIFY-GP-TOKEN',
        visitorName: json['visitor_name'] as String? ?? '',
        companyName: json['company_name'] as String? ?? '',
        auctionCode: json['auction_code'] as String? ?? '',
        facilityName: json['facility_name'] as String? ?? '',
        date: json['date'] as String? ?? '',
        timeSlot: json['time_slot'] as String? ?? '',
        vehicleNumber: json['vehicle_number'] as String? ?? '',
        isValid: json['is_valid'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'pass_id': passId,
        'qr_payload': qrPayload,
        'visitor_name': visitorName,
        'company_name': companyName,
        'auction_code': auctionCode,
        'facility_name': facilityName,
        'date': date,
        'time_slot': timeSlot,
        'vehicle_number': vehicleNumber,
        'is_valid': isValid,
      };

  @override
  List<Object?> get props => [passId, qrPayload, isValid];
}

class FulfilmentRecord extends Equatable {
  final String id;
  final String orderId;
  final String auctionCode;
  final String title;
  final FulfilmentType type;
  final int currentStageIndex;
  final List<FulfilmentStage> stages;
  final GatePassData? gatePass;
  final double? grossWeightKg;
  final double? tareWeightKg;
  final double? netWeightKg;
  final String? trackingNumber;
  final String? transporterName;
  final String? deliveryStatus;

  const FulfilmentRecord({
    required this.id,
    required this.orderId,
    required this.auctionCode,
    required this.title,
    required this.type,
    this.currentStageIndex = 0,
    required this.stages,
    this.gatePass,
    this.grossWeightKg,
    this.tareWeightKg,
    this.netWeightKg,
    this.trackingNumber,
    this.transporterName,
    this.deliveryStatus,
  });

  String get category => type.label;
  String get status => deliveryStatus ?? (currentStageIndex >= stages.length ? 'COMPLETED' : 'IN_FULFILMENT');
  String get auctionTitle => title;
  String get sellerCompany => 'Tata Power Heavy Logistics';
  double get totalAmountInr => 2480000;
  String get currentStage => (currentStageIndex < stages.length && stages.isNotEmpty) ? stages[currentStageIndex].title : 'Completed';

  @override
  List<Object?> get props => [id, orderId, type, currentStageIndex];
}
