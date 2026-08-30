import 'package:equatable/equatable.dart';
import 'bid.dart';
import 'lot.dart';

enum AuctionStatus {
  draft,
  pendingApproval,
  approved,
  sentBack,
  rejected,
  published,
  live,
  paused,
  extended,
  underEvaluation,
  awaitingApproval,
  awarded,
  closed,
  cancelled;

  static AuctionStatus fromString(String? s) => switch (s?.toLowerCase()) {
        'draft' => draft,
        'pending_approval' => pendingApproval,
        'approved' => approved,
        'sent_back' => sentBack,
        'rejected' => rejected,
        'published' => published,
        'live' => live,
        'paused' => paused,
        'extended' => extended,
        'under_evaluation' => underEvaluation,
        'awaiting_approval' => awaitingApproval,
        'awarded' => awarded,
        'closed' => closed,
        'cancelled' => cancelled,
        _ => draft,
      };

  String get apiValue => switch (this) {
        draft => 'draft',
        pendingApproval => 'pending_approval',
        approved => 'approved',
        sentBack => 'sent_back',
        rejected => 'rejected',
        published => 'published',
        live => 'live',
        paused => 'paused',
        extended => 'extended',
        underEvaluation => 'under_evaluation',
        awaitingApproval => 'awaiting_approval',
        awarded => 'awarded',
        closed => 'closed',
        cancelled => 'cancelled',
      };

  bool get isLive => this == live || this == extended || this == paused;
  bool get isPublic => this == published || this == live || this == closed || this == extended || this == paused || this == awarded;
}

class LandedCostComponent extends Equatable {
  final String label;
  final double amount;
  final bool isPercentage;

  const LandedCostComponent({required this.label, required this.amount, this.isPercentage = false});

  factory LandedCostComponent.fromJson(Map<String, dynamic> json) => LandedCostComponent(
        label: json['label'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        isPercentage: json['is_percentage'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {'label': label, 'amount': amount, 'is_percentage': isPercentage};

  @override
  List<Object?> get props => [label, amount, isPercentage];
}

class AuctionAddendum extends Equatable {
  final String id;
  final int number;
  final String title;
  final String description;
  final String publishedAt;
  final bool isAcknowledged;

  const AuctionAddendum({
    required this.id,
    required this.number,
    required this.title,
    required this.description,
    required this.publishedAt,
    this.isAcknowledged = false,
  });

  factory AuctionAddendum.fromJson(Map<String, dynamic> json) => AuctionAddendum(
        id: json['id'] as String? ?? '',
        number: json['number'] as int? ?? 1,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        publishedAt: json['published_at'] as String? ?? '',
        isAcknowledged: json['is_acknowledged'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'number': number,
        'title': title,
        'description': description,
        'published_at': publishedAt,
        'is_acknowledged': isAcknowledged,
      };

  @override
  List<Object?> get props => [id, number, title, isAcknowledged];
}

class Auction extends Equatable {
  final String code;
  final String title;
  final String description;
  final String company;
  final String? plant;
  final String? warehouse;
  final String? location;
  final String? organizationId;
  final String? category;
  final int? categoryId;
  final String lotType;
  final String direction; // 'forward' | 'reverse' | 'rfq' | 'sealed' | 'lot_wise'
  final String? materialType;
  final String? quantity;
  final String? uom;
  final double reservePriceInr;
  final bool reserveNa;
  final double startingPriceInr;
  final double bidIncrementInr;
  final double decrementInr;
  final double targetPriceInr;
  final double emdAmountInr;
  final double currentHighestInr;
  final int bidders;
  final AuctionStatus status;
  final String? submittedBy;
  final String? submittedAt;
  final String? scheduleStart;
  final String? scheduleEnd;
  final bool inspectionRequired;
  final String? inspectionDate;
  final String? inspectionTime;
  final String? inspectionLocation;
  final String? inspectionContact;
  final String? terms;
  final int termsVersion;
  final bool termsAccepted;
  final bool emdPaid;
  final bool isInvited;
  final int? myRank;
  final double? myLastBidInr;
  final String? paymentTerms;
  final String? liftingPeriod;
  final String? liftingUnit;
  final AuctionContact? contact;
  final List<String> photos;
  final List<Lot> subLots;
  final List<Bid> bids;
  final List<AuctionExtension> extensions;
  final List<AuctionAddendum> addenda;
  final List<LandedCostComponent> landedCosts;
  final String? reviewComment;
  final String? publishedAt;
  final List<String> publishChannels;
  final String? closedAt;
  final double? finalPriceInr;
  final String? winner;
  final int interestedCount;
  final String? createdAt;
  final String? guidelinesDoc;

  const Auction({
    required this.code,
    required this.title,
    this.description = '',
    required this.company,
    this.plant,
    this.warehouse,
    this.location,
    this.organizationId,
    this.category,
    this.categoryId,
    this.lotType = 'single',
    this.direction = 'forward',
    this.materialType,
    this.quantity,
    this.uom,
    this.reservePriceInr = 0,
    this.reserveNa = false,
    this.startingPriceInr = 0,
    this.bidIncrementInr = 5000,
    this.decrementInr = 5000,
    this.targetPriceInr = 0,
    this.emdAmountInr = 0,
    this.currentHighestInr = 0,
    this.bidders = 0,
    this.status = AuctionStatus.draft,
    this.submittedBy,
    this.submittedAt,
    this.scheduleStart,
    this.scheduleEnd,
    this.inspectionRequired = false,
    this.inspectionDate,
    this.inspectionTime,
    this.inspectionLocation,
    this.inspectionContact,
    this.terms,
    this.termsVersion = 1,
    this.termsAccepted = false,
    this.emdPaid = false,
    this.isInvited = false,
    this.myRank,
    this.myLastBidInr,
    this.paymentTerms,
    this.liftingPeriod,
    this.liftingUnit,
    this.contact,
    this.photos = const [],
    this.subLots = const [],
    this.bids = const [],
    this.extensions = const [],
    this.addenda = const [],
    this.landedCosts = const [],
    this.reviewComment,
    this.publishedAt,
    this.publishChannels = const [],
    this.closedAt,
    this.finalPriceInr,
    this.winner,
    this.interestedCount = 0,
    this.createdAt,
    this.guidelinesDoc,
  });

  factory Auction.fromJson(Map<String, dynamic> json) => Auction(
        code: json['code'] as String? ?? json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        company: json['company'] as String? ?? '',
        plant: json['plant'] as String?,
        warehouse: json['warehouse'] as String?,
        location: json['location'] as String?,
        organizationId: json['organization_id'] as String?,
        category: json['category'] as String?,
        categoryId: json['category_id'] as int?,
        lotType: json['lot_type'] as String? ?? 'single',
        direction: json['direction'] as String? ?? 'forward',
        materialType: json['material_type'] as String?,
        quantity: json['quantity'] as String?,
        uom: json['uom'] as String?,
        reservePriceInr: _num(json['reserve_price_inr']),
        reserveNa: json['reserve_na'] as bool? ?? false,
        startingPriceInr: _num(json['starting_price_inr']),
        bidIncrementInr: _num(json['bid_increment_inr']) == 0 ? 5000 : _num(json['bid_increment_inr']),
        decrementInr: _num(json['decrement_inr']) == 0 ? 5000 : _num(json['decrement_inr']),
        targetPriceInr: _num(json['target_price_inr']),
        emdAmountInr: _num(json['emd_amount_inr']),
        currentHighestInr: _num(json['current_highest_inr']),
        bidders: json['bidders'] as int? ?? 0,
        status: AuctionStatus.fromString(json['status'] as String?),
        submittedBy: json['submitted_by'] as String?,
        submittedAt: json['submitted_at'] as String?,
        scheduleStart: json['schedule_start'] as String?,
        scheduleEnd: json['schedule_end'] as String?,
        inspectionRequired: json['inspection_required'] as bool? ?? false,
        inspectionDate: json['inspection_date'] as String?,
        inspectionTime: json['inspection_time'] as String?,
        inspectionLocation: json['inspection_location'] as String?,
        inspectionContact: json['inspection_contact'] as String?,
        terms: json['terms'] as String?,
        termsVersion: json['terms_version'] as int? ?? 1,
        termsAccepted: json['terms_accepted'] as bool? ?? false,
        emdPaid: json['emd_paid'] as bool? ?? false,
        isInvited: json['is_invited'] as bool? ?? false,
        myRank: json['my_rank'] as int?,
        myLastBidInr: json['my_last_bid_inr'] != null ? _num(json['my_last_bid_inr']) : null,
        paymentTerms: json['payment_terms'] as String?,
        liftingPeriod: json['lifting_period'] as String?,
        liftingUnit: json['lifting_unit'] as String?,
        contact: json['contact'] != null
            ? AuctionContact.fromJson(json['contact'] as Map<String, dynamic>)
            : null,
        photos: (json['photos'] as List?)?.cast<String>() ?? [],
        subLots: (json['sub_lots'] as List?)
                ?.map((e) => Lot.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        bids: (json['bids'] as List?)
                ?.map((e) => Bid.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        extensions: (json['extensions'] as List?)
                ?.map((e) =>
                    AuctionExtension.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        addenda: (json['addenda'] as List?)
                ?.map((e) => AuctionAddendum.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        landedCosts: (json['landed_costs'] as List?)
                ?.map((e) => LandedCostComponent.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        reviewComment: json['review_comment'] as String?,
        publishedAt: json['published_at'] as String?,
        publishChannels:
            (json['publish_channels'] as List?)?.cast<String>() ?? [],
        closedAt: json['closed_at'] as String?,
        finalPriceInr: json['final_price_inr'] != null
            ? _num(json['final_price_inr'])
            : null,
        winner: json['winner'] as String?,
        interestedCount: json['interested_count'] as int? ?? 0,
        createdAt: json['created_at'] as String?,
        guidelinesDoc: json['guidelines_doc'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'company': company,
        'plant': plant,
        'warehouse': warehouse,
        'location': location,
        'organization_code': organizationId,
        'category': category,
        'lot_type': lotType,
        'direction': direction,
        'material_type': materialType,
        'quantity': quantity,
        'uom': uom,
        'reserve_price': reservePriceInr,
        'reserve_na': reserveNa,
        'starting_price': startingPriceInr,
        'bid_increment': bidIncrementInr,
        'decrement_inr': decrementInr,
        'target_price': targetPriceInr,
        'emd_amount': emdAmountInr,
        'schedule_start': scheduleStart,
        'schedule_end': scheduleEnd,
        'inspection_required': inspectionRequired,
        'inspection_date': inspectionDate,
        'inspection_time': inspectionTime,
        'inspection_location': inspectionLocation,
        'terms': terms,
        'terms_accepted': termsAccepted,
        'emd_paid': emdPaid,
        'is_invited': isInvited,
        'my_rank': myRank,
        'my_last_bid_inr': myLastBidInr,
        'payment_terms': paymentTerms,
        'lifting_period': liftingPeriod,
        'lifting_unit': liftingUnit,
        'contact_name': contact?.name,
        'contact_phone': contact?.phone,
        'contact_email': contact?.email,
        'photos': photos,
        'guidelines_doc': guidelinesDoc,
      };

  bool get isLive => status == AuctionStatus.live || status == AuctionStatus.extended || status == AuctionStatus.paused;
  bool get isLotWise => lotType == 'lot_wise' || lotType == 'multi_lot';
  bool get isForward => direction == 'forward';
  bool get isReverse => direction == 'reverse';
  bool get isRfq => direction == 'rfq';

  int get secondsRemaining {
    if (scheduleEnd == null) return 0;
    final end = DateTime.tryParse(scheduleEnd!);
    if (end == null) return 0;
    return end.difference(DateTime.now()).inSeconds.clamp(0, 999999);
  }

  Auction copyWith({
    double? currentHighestInr,
    int? bidders,
    AuctionStatus? status,
    String? scheduleEnd,
    List<Bid>? bids,
    bool? termsAccepted,
    bool? emdPaid,
    int? myRank,
    double? myLastBidInr,
  }) =>
      Auction(
        code: code,
        title: title,
        description: description,
        company: company,
        plant: plant,
        warehouse: warehouse,
        location: location,
        organizationId: organizationId,
        category: category,
        categoryId: categoryId,
        lotType: lotType,
        direction: direction,
        materialType: materialType,
        quantity: quantity,
        uom: uom,
        reservePriceInr: reservePriceInr,
        reserveNa: reserveNa,
        startingPriceInr: startingPriceInr,
        bidIncrementInr: bidIncrementInr,
        decrementInr: decrementInr,
        targetPriceInr: targetPriceInr,
        emdAmountInr: emdAmountInr,
        currentHighestInr: currentHighestInr ?? this.currentHighestInr,
        bidders: bidders ?? this.bidders,
        status: status ?? this.status,
        submittedBy: submittedBy,
        submittedAt: submittedAt,
        scheduleStart: scheduleStart,
        scheduleEnd: scheduleEnd ?? this.scheduleEnd,
        inspectionRequired: inspectionRequired,
        inspectionDate: inspectionDate,
        inspectionTime: inspectionTime,
        inspectionLocation: inspectionLocation,
        inspectionContact: inspectionContact,
        terms: terms,
        termsVersion: termsVersion,
        termsAccepted: termsAccepted ?? this.termsAccepted,
        emdPaid: emdPaid ?? this.emdPaid,
        isInvited: isInvited,
        myRank: myRank ?? this.myRank,
        myLastBidInr: myLastBidInr ?? this.myLastBidInr,
        paymentTerms: paymentTerms,
        liftingPeriod: liftingPeriod,
        liftingUnit: liftingUnit,
        contact: contact,
        photos: photos,
        subLots: subLots,
        bids: bids ?? this.bids,
        extensions: extensions,
        addenda: addenda,
        landedCosts: landedCosts,
        reviewComment: reviewComment,
        publishedAt: publishedAt,
        publishChannels: publishChannels,
        closedAt: closedAt,
        finalPriceInr: finalPriceInr,
        winner: winner,
        interestedCount: interestedCount,
        createdAt: createdAt,
        guidelinesDoc: guidelinesDoc,
      );

  @override
  List<Object?> get props => [code, currentHighestInr, bidders, status, termsAccepted, emdPaid, myRank];
}

class AuctionContact {
  final String? name;
  final String? phone;
  final String? email;

  const AuctionContact({this.name, this.phone, this.email});

  factory AuctionContact.fromJson(Map<String, dynamic> json) =>
      AuctionContact(
        name: json['name'] as String?,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'email': email,
      };
}

class AuctionExtension {
  final String? reason;
  final int minutes;
  final String? at;

  const AuctionExtension({this.reason, this.minutes = 0, this.at});

  factory AuctionExtension.fromJson(Map<String, dynamic> json) =>
      AuctionExtension(
        reason: json['reason'] as String?,
        minutes: json['minutes'] as int? ?? 0,
        at: json['at'] as String?,
      );
}

double _num(dynamic v) => (v as num?)?.toDouble() ?? 0;

