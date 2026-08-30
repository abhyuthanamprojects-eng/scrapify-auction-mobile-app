import 'package:equatable/equatable.dart';

class InspectionSlot extends Equatable {
  final String id;
  final String date;
  final String timeRange;
  final int maxVisitors;
  final int bookedVisitors;
  final bool isAvailable;

  const InspectionSlot({
    required this.id,
    required this.date,
    required this.timeRange,
    this.maxVisitors = 10,
    this.bookedVisitors = 3,
    this.isAvailable = true,
  });

  @override
  List<Object?> get props => [id, date, timeRange, isAvailable];
}

class InspectionBooking extends Equatable {
  final String bookingId;
  final String auctionCode;
  final String auctionTitle;
  final String facilityAddress;
  final String contactPerson;
  final String contactPhone;
  final String selectedDate;
  final String selectedTimeSlot;
  final String visitorName;
  final String visitorMobile;
  final String visitorGovtId;
  final String vehicleNumber;
  final int numberOfVisitors;
  final bool isConfirmed;
  final String? gatePassToken;

  const InspectionBooking({
    required this.bookingId,
    required this.auctionCode,
    required this.auctionTitle,
    required this.facilityAddress,
    required this.contactPerson,
    required this.contactPhone,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.visitorName,
    required this.visitorMobile,
    required this.visitorGovtId,
    required this.vehicleNumber,
    this.numberOfVisitors = 1,
    this.isConfirmed = true,
    this.gatePassToken,
  });

  factory InspectionBooking.fromJson(Map<String, dynamic> json) => InspectionBooking(
        bookingId: json['booking_id'] as String? ?? 'INS-${DateTime.now().millisecondsSinceEpoch}',
        auctionCode: json['auction_code'] as String? ?? '',
        auctionTitle: json['auction_title'] as String? ?? '',
        facilityAddress: json['facility_address'] as String? ?? '',
        contactPerson: json['contact_person'] as String? ?? '',
        contactPhone: json['contact_phone'] as String? ?? '',
        selectedDate: json['selected_date'] as String? ?? '',
        selectedTimeSlot: json['selected_time_slot'] as String? ?? '',
        visitorName: json['visitor_name'] as String? ?? '',
        visitorMobile: json['visitor_mobile'] as String? ?? '',
        visitorGovtId: json['visitor_govt_id'] as String? ?? '',
        vehicleNumber: json['vehicle_number'] as String? ?? '',
        numberOfVisitors: json['number_of_visitors'] as int? ?? 1,
        isConfirmed: json['is_confirmed'] as bool? ?? true,
        gatePassToken: json['gate_pass_token'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'booking_id': bookingId,
        'auction_code': auctionCode,
        'auction_title': auctionTitle,
        'facility_address': facilityAddress,
        'contact_person': contactPerson,
        'contact_phone': contactPhone,
        'selected_date': selectedDate,
        'selected_time_slot': selectedTimeSlot,
        'visitor_name': visitorName,
        'visitor_mobile': visitorMobile,
        'visitor_govt_id': visitorGovtId,
        'vehicle_number': vehicleNumber,
        'number_of_visitors': numberOfVisitors,
        'is_confirmed': isConfirmed,
        'gate_pass_token': gatePassToken,
      };

  @override
  List<Object?> get props => [bookingId, auctionCode, selectedDate, selectedTimeSlot, isConfirmed];
}
