import '../models/auction.dart';
import '../models/lot.dart';
import '../models/award.dart';
import '../models/order.dart';
import '../models/fulfilment.dart';
import '../models/dispute.dart';
import '../models/team_member.dart';
import '../models/performance.dart';
import '../models/rfx.dart';
import '../models/inspection.dart';
import '../models/evidence.dart';

class MockBidPlayRepository {
  static final MockBidPlayRepository _instance = MockBidPlayRepository._internal();
  factory MockBidPlayRepository() => _instance;

  MockBidPlayRepository._internal() {
    _initData();
  }

  late List<Auction> _auctions;
  late List<Award> _awards;
  late List<Order> _orders;
  late List<FulfilmentRecord> _fulfilments;
  late List<DisputeItem> _disputes;
  late List<TeamMember> _teamMembers;
  late VendorPerformance _performance;
  late Map<String, RfxPackage> _rfxPackages;
  late List<InspectionBooking> _inspectionBookings;
  late List<CapturedEvidence> _evidenceList;

  void _initData() {
    final now = DateTime.now();

    // Curated realistic Indian auction events
    _auctions = [
      Auction(
        code: 'BP-FWD-2026-1048',
        title: 'Industrial Copper Scrap & Armoured Cables — Plant 04',
        description: 'Grade-A copper wire scrap and high-voltage power cables stripped from power distribution yard. Total estimated 42.5 Metric Tonnes. Lifting within 15 days of full payment.',
        company: 'Tata Power Heavy Logistics',
        plant: 'Jamshedpur Thermal Unit 4',
        location: 'Jamshedpur, Jharkhand',
        category: 'Metals & Scrap',
        lotType: 'single',
        direction: 'forward',
        materialType: 'Grade-A Copper Scrap',
        quantity: '42.5',
        uom: 'MT',
        startingPriceInr: 2200000,
        currentHighestInr: 2480000,
        bidIncrementInr: 20000,
        reservePriceInr: 2350000,
        emdAmountInr: 100000,
        bidders: 14,
        status: AuctionStatus.live,
        scheduleStart: now.subtract(const Duration(minutes: 45)).toIso8601String(),
        scheduleEnd: now.add(const Duration(minutes: 8, seconds: 42)).toIso8601String(),
        inspectionRequired: true,
        inspectionDate: '28 Aug 2026',
        inspectionTime: '10:00 AM – 4:00 PM',
        inspectionLocation: 'Yard Gate 3, Jamshedpur Works',
        inspectionContact: 'Suresh Verma (+91 98765 43210)',
        terms: '1. Material sold on As-Is Where-Is basis.\n2. 100% advance payment required within 48h of award.\n3. Weighing at verified plant weighbridge.\n4. Safety gear mandatory for lifting crew.',
        termsAccepted: true,
        emdPaid: true,
        myRank: 2,
        myLastBidInr: 2460000,
        photos: [
          'https://images.unsplash.com/photo-1601275802397-e8f5e5f4d3f4?w=800&q=70',
          'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800&q=70',
        ],
        subLots: const [
          Lot(
            code: 'sl-1',
            auctionId: 'BP-FWD-2026-1048',
            name: '99.9% Copper Armoured Wire',
            quantity: '28.0',
            uom: 'MT',
            currentBidInr: 1680000,
          ),
          Lot(
            code: 'sl-2',
            auctionId: 'BP-FWD-2026-1048',
            name: 'Stripped Secondary Busbars',
            quantity: '14.5',
            uom: 'MT',
            currentBidInr: 800000,
          ),
        ],
        addenda: [
          AuctionAddendum(
            id: 'add-1',
            number: 1,
            title: 'Lifting Window Extended',
            description: 'Lifting window extended from 10 days to 15 days due to plant maintenance schedule.',
            publishedAt: now.subtract(const Duration(hours: 4)).toIso8601String(),
            isAcknowledged: true,
          ),
        ],
      ),
      Auction(
        code: 'BP-REV-2026-0872',
        title: 'Annual Comprehensive Facility Management Contract',
        description: 'Reverse e-Procurement for Pan-India Facility Management, HVAC upkeep, cleaning, and security personnel for 12 corporate campuses.',
        company: 'Bharat Global Tech Parks',
        plant: 'Corporate HQ & 12 Tech Hubs',
        location: 'Bengaluru, Karnataka',
        category: 'Facility Management',
        lotType: 'single',
        direction: 'reverse',
        startingPriceInr: 4800000, // Opening ceiling
        currentHighestInr: 4235000, // Current lowest L1 offer
        decrementInr: 25000,
        targetPriceInr: 4100000,
        emdAmountInr: 150000,
        bidders: 8,
        status: AuctionStatus.live,
        scheduleStart: now.subtract(const Duration(hours: 1)).toIso8601String(),
        scheduleEnd: now.add(const Duration(minutes: 14, seconds: 18)).toIso8601String(),
        inspectionRequired: false,
        terms: '1. SLA compliance minimum 98.5%.\n2. Monthly invoicing with 30-day payment cycle.\n3. Background check verified staff only.',
        termsAccepted: true,
        emdPaid: true,
        myRank: 3,
        myLastBidInr: 4285000,
        photos: [
          'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=800&q=70',
        ],
        landedCosts: const [
          LandedCostComponent(label: 'Base Manpower Rate', amount: 3600000),
          LandedCostComponent(label: 'Consumables & Machinery', amount: 350000),
          LandedCostComponent(label: 'GST & Compliance Taxes (18%)', amount: 285000),
        ],
      ),
      Auction(
        code: 'BP-FWD-2026-1055',
        title: 'Decommissioned CNC Lathes & Milling Machinery',
        description: '5 Units of heavy CNC 5-Axis Milling Centers (Mazak & Haas) in excellent operational condition with maintenance records.',
        company: 'Larsen Engineering Works',
        location: 'Pune, Maharashtra',
        category: 'Machinery & Plant',
        lotType: 'lot_wise',
        direction: 'forward',
        startingPriceInr: 6500000,
        currentHighestInr: 7150000,
        bidIncrementInr: 50000,
        emdAmountInr: 250000,
        bidders: 19,
        status: AuctionStatus.live,
        scheduleStart: now.subtract(const Duration(hours: 2)).toIso8601String(),
        scheduleEnd: now.add(const Duration(hours: 1, minutes: 22)).toIso8601String(),
        inspectionRequired: true,
        inspectionDate: '29 Aug 2026',
        inspectionLocation: 'Shop Floor 2, Chakan MIDC, Pune',
        termsAccepted: true,
        emdPaid: true,
        myRank: 1,
        myLastBidInr: 7150000,
        photos: [
          'https://images.unsplash.com/photo-1591488320449-011701bb6704?w=800&q=70',
        ],
      ),
      Auction(
        code: 'BP-RFQ-2026-0319',
        title: 'Bulk Logistics & Dedicated Freight Corridor Fleet',
        description: 'Tender for 32-Foot Multi-Axle Container Trucks for daily runs between NCR, Gujarat, and JNPT Mumbai port.',
        company: 'Adani Logistics Hubs',
        location: 'Gurugram, Haryana',
        category: 'Logistics & Freight',
        direction: 'rfq',
        startingPriceInr: 8500000,
        currentHighestInr: 0,
        emdAmountInr: 200000,
        bidders: 11,
        status: AuctionStatus.published,
        scheduleStart: now.add(const Duration(hours: 4)).toIso8601String(),
        scheduleEnd: now.add(const Duration(days: 3)).toIso8601String(),
        inspectionRequired: false,
        photos: [
          'https://images.unsplash.com/photo-1587202372775-e229f172b9d7?w=800&q=70',
        ],
      ),
      Auction(
        code: 'BP-FWD-2026-1032',
        title: '150 Mixed Corporate Laptops (Dell & Lenovo Core i7)',
        description: 'Corporate refreshed 14-inch business laptops with chargers. Tested and working.',
        company: 'Infosys Assets Disposal',
        location: 'Bengaluru, Karnataka',
        category: 'IT Assets & Electronics',
        startingPriceInr: 2400000,
        currentHighestInr: 2820000,
        bidIncrementInr: 25000,
        emdAmountInr: 100000,
        bidders: 26,
        status: AuctionStatus.awarded,
        scheduleStart: now.subtract(const Duration(days: 2)).toIso8601String(),
        scheduleEnd: now.subtract(const Duration(hours: 3)).toIso8601String(),
        myRank: 1,
        myLastBidInr: 2820000,
        winner: 'Devzign Solutions Pvt Ltd',
        finalPriceInr: 2820000,
        photos: [
          'https://images.unsplash.com/photo-1587202372775-e229f172b9d7?w=800&q=70',
        ],
      ),
    ];

    // Awards
    _awards = [
      Award(
        id: 'AWD-2026-0041',
        auctionCode: 'BP-FWD-2026-1032',
        auctionTitle: '150 Mixed Corporate Laptops (Dell & Lenovo Core i7)',
        company: 'Infosys Assets Disposal',
        category: 'IT Assets & Electronics',
        awardValueInr: 2820000,
        emdAdjustedInr: 100000,
        netPayableInr: 2720000,
        status: AwardStatus.offered,
        acceptanceDeadline: now.add(const Duration(hours: 18)).toIso8601String(),
        awardedAt: now.subtract(const Duration(hours: 2)).toIso8601String(),
        poNumber: 'PO-INF-2026-8891',
      ),
      Award(
        id: 'AWD-2026-0038',
        auctionCode: 'BP-FWD-2026-0994',
        auctionTitle: 'Aluminium Extrusion Scrap Lot (6063 Alloy)',
        company: 'Hindalco Industries',
        category: 'Metals & Scrap',
        awardValueInr: 1840000,
        emdAdjustedInr: 75000,
        netPayableInr: 1765000,
        status: AwardStatus.accepted,
        acceptanceDeadline: now.subtract(const Duration(days: 4)).toIso8601String(),
        awardedAt: now.subtract(const Duration(days: 5)).toIso8601String(),
        acceptedAt: now.subtract(const Duration(days: 4)).toIso8601String(),
        poNumber: 'PO-HND-2026-4412',
      ),
      Award(
        id: 'AWD-2026-0035',
        auctionCode: 'BP-REV-2026-0744',
        auctionTitle: 'Security & Surveillance Services — Hyderabad DC',
        company: 'CtrlS Datacenters',
        category: 'Service Contracts',
        awardValueInr: 3200000,
        emdAdjustedInr: 100000,
        netPayableInr: 3100000,
        status: AwardStatus.fallbackOffered,
        acceptanceDeadline: now.add(const Duration(hours: 8)).toIso8601String(),
        awardedAt: now.subtract(const Duration(hours: 4)).toIso8601String(),
        isFallback: true,
        fallbackOriginalBidder: 'Apex Security Services (Defaulted)',
        poNumber: 'PO-CTRL-2026-1090',
      ),
    ];

    // Orders
    _orders = [
      const Order(
        code: 'ORD-2026-0182',
        auctionId: 'BP-FWD-2026-0994',
        title: 'Aluminium Extrusion Scrap Lot (6063 Alloy)',
        vendorId: 'VND-HINDALCO-01',
        status: 'in_progress',
        winningAmountInr: 1840000,
        totalAmountInr: 1840000,
        balanceDueInr: 0,
      ),
    ];

    // Fulfilments
    _fulfilments = [
      FulfilmentRecord(
        id: 'FUL-001',
        orderId: 'ORD-2026-0182',
        auctionCode: 'BP-FWD-2026-0994',
        title: 'Aluminium Extrusion Scrap — Lifting & Gate Pass',
        type: FulfilmentType.materialPickup,
        currentStageIndex: 1,
        gatePass: GatePassData(
          passId: 'GP-2026-8819',
          qrPayload: 'SCRAPIFY-GP-HND-2026-8819-VALID',
          visitorName: 'Ramesh Patel (Driver)',
          companyName: 'Devzign Solutions Pvt Ltd',
          auctionCode: 'SC-FWD-2026-0994',
          facilityName: 'Hindalco Belur Plant, Gate 2',
          date: '30 Aug 2026',
          timeSlot: '11:30 AM – 1:30 PM',
          vehicleNumber: 'MH-12-RN-4820',
          isValid: true,
        ),
        stages: [
          FulfilmentStage(
            step: 1,
            title: 'Payment & PO Confirmation',
            description: '100% invoice settlement cleared via RTGS',
            isCompleted: true,
            completedAt: '28 Aug 2026, 04:30 PM',
          ),
          FulfilmentStage(
            step: 2,
            title: 'Schedule Lifting & Gate Pass',
            description: 'Digital gate pass issued with QR token',
            isCompleted: true,
            completedAt: '29 Aug 2026, 11:00 AM',
          ),
          FulfilmentStage(
            step: 3,
            title: 'Vehicle Entry & Tare Weighing',
            description: 'Truck check-in at weighing bridge with empty tare weight',
            isCompleted: false,
            actionRequired: 'Scan Gate Pass at Security Gate',
          ),
          FulfilmentStage(
            step: 4,
            title: 'Material Loading & Gross Weighing',
            description: 'Hydraulic loading and final gross weight slip generation',
            isCompleted: false,
          ),
          FulfilmentStage(
            step: 5,
            title: 'Handover & Order Closure',
            description: 'Digital signature on delivery challan and final sign-off',
            isCompleted: false,
          ),
        ],
      ),
    ];

    // Disputes
    _disputes = [
      DisputeItem(
        id: 'DSP-2026-0012',
        auctionCode: 'BP-FWD-2026-0912',
        auctionTitle: 'Heavy Machinery Copper Windings',
        orderNumber: 'ORD-2026-0150',
        category: DisputeCategory.quantityVariance,
        description: 'Weight discrepancy of 420 kg observed between plant slip and delivery weighbridge.',
        status: DisputeStatus.underReview,
        raisedAt: '25 Aug 2026',
        messages: [
          DisputeMessage(
            senderName: 'Rahul Sharma',
            senderRole: 'Bidder',
            message: 'Gross weight at destination came out 420 kg lower than invoiced quantity. Attached certified calibration slip.',
            timestamp: '25 Aug 2026, 02:15 PM',
          ),
          DisputeMessage(
            senderName: 'Compliance Officer',
            senderRole: 'Admin',
            message: 'We have initiated joint calibration inspection with Hindalco logistics team.',
            timestamp: '26 Aug 2026, 11:00 AM',
          ),
        ],
      ),
    ];

    // Team Members
    _teamMembers = [
      const TeamMember(
        id: 'TM-01',
        name: 'Rahul Sharma',
        email: 'rahul.s@devzign.in',
        mobile: '+91 98765 43210',
        role: TeamRole.vendorAdmin,
        maxBiddingLimitInr: 10000000,
        isActive: true,
        joinedAt: 'Jan 2025',
      ),
      const TeamMember(
        id: 'TM-02',
        name: 'Amit Verma',
        email: 'amit.v@devzign.in',
        mobile: '+91 98112 23344',
        role: TeamRole.authorizedBidder,
        maxBiddingLimitInr: 2500000,
        isActive: true,
        joinedAt: 'Mar 2025',
      ),
      const TeamMember(
        id: 'TM-03',
        name: 'Vikram Singh',
        email: 'vikram.s@devzign.in',
        mobile: '+91 97234 56789',
        role: TeamRole.fieldInspector,
        maxBiddingLimitInr: 500000,
        isActive: true,
        joinedAt: 'Jul 2025',
      ),
    ];

    // Performance
    _performance = const VendorPerformance();

    // RFx
    _rfxPackages = {
      'BP-RFQ-2026-0319': RfxPackage(
        id: 'RFX-0319',
        auctionCode: 'BP-RFQ-2026-0319',
        title: 'Bulk Logistics Fleet Prequalification Questionnaire',
        buyerName: 'Adani Logistics Hubs',
        submissionDeadline: now.add(const Duration(days: 2)).toIso8601String(),
        questions: const [
          RfxQuestion(
            id: 'q1',
            section: 'Technical Eligibility',
            questionText: 'Do you own or lease at least 25 dedicated container trucks of 32-ft length?',
            type: RfxQuestionType.boolean,
            responseBool: true,
          ),
          RfxQuestion(
            id: 'q2',
            section: 'Technical Eligibility',
            questionText: 'Total number of active GPS-integrated GPS telematics vehicles in fleet:',
            type: RfxQuestionType.number,
            responseNumber: 42,
          ),
          RfxQuestion(
            id: 'q3',
            section: 'Safety & Compliance',
            questionText: 'Upload valid All India Goods Carriage Permit & Fleet Comprehensive Insurance:',
            type: RfxQuestionType.fileAttachment,
            attachmentUrl: 'https://docs.scrapify.io/fleet-permit-verified.pdf',
          ),
          RfxQuestion(
            id: 'q4',
            section: 'Commercial Capability',
            questionText: 'Expected standard transit turnaround time (hours) for Delhi–Mumbai corridor:',
            type: RfxQuestionType.text,
            responseText: '36 hours via Western Dedicated Corridor',
          ),
        ],
      ),
    };

    // Inspection Bookings
    _inspectionBookings = [
      InspectionBooking(
        bookingId: 'INS-2026-0941',
        auctionCode: 'SC-FWD-2026-1048',
        auctionTitle: 'Industrial Copper Scrap & Armoured Cables',
        facilityAddress: 'Tata Power Yard 3, Jamshedpur Works',
        contactPerson: 'Suresh Verma',
        contactPhone: '+91 98765 43210',
        selectedDate: '28 Aug 2026',
        selectedTimeSlot: '11:30 AM – 12:30 PM',
        visitorName: 'Rahul Sharma',
        visitorMobile: '+91 98765 43210',
        visitorGovtId: 'PAN: ABCDE1234F',
        vehicleNumber: 'JH-05-AB-1234',
        gatePassToken: 'SCRAPIFY-INS-1048-PASS',
      ),
    ];

    // Evidence
    _evidenceList = [
      CapturedEvidence(
        id: 'EV-01',
        type: EvidenceType.photo,
        title: 'Initial Material Yard Inspection',
        fileUrl: 'https://images.unsplash.com/photo-1601275802397-e8f5e5f4d3f4?w=800&q=70',
        timestamp: '28 Aug 2026, 12:10 PM',
        latitude: 22.8046,
        longitude: 86.2029,
        remarks: 'Sample insulated cables inspected. Grade verified.',
      ),
    ];
  }

  // Repository Methods
  List<Auction> getAuctions({String? direction, String? category, String? status, String? search}) {
    return _auctions.where((a) {
      if (direction != null && a.direction.toLowerCase() != direction.toLowerCase()) return false;
      if (category != null && a.category != category) return false;
      if (status != null) {
        if (status == 'live' && !a.isLive) return false;
        if (status == 'upcoming' && a.isLive) return false;
        if (status == 'closed' && a.status != AuctionStatus.closed && a.status != AuctionStatus.awarded) return false;
      }
      if (search != null && search.trim().isNotEmpty) {
        final q = search.toLowerCase();
        return a.title.toLowerCase().contains(q) ||
            a.code.toLowerCase().contains(q) ||
            a.company.toLowerCase().contains(q) ||
            (a.location?.toLowerCase().contains(q) ?? false);
      }
      return true;
    }).toList();
  }

  Auction? getAuction(String code) {
    try {
      return _auctions.firstWhere((a) => a.code == code);
    } catch (_) {
      return _auctions.isNotEmpty ? _auctions.first : null;
    }
  }

  void placeBid(String code, double amount, {bool isReverse = false}) {
    final idx = _auctions.indexWhere((a) => a.code == code);
    if (idx != -1) {
      final current = _auctions[idx];
      _auctions[idx] = current.copyWith(
        currentHighestInr: amount,
        bidders: current.bidders + 1,
        myRank: 1,
        myLastBidInr: amount,
      );
    }
  }

  void acceptTerms(String code) {
    final idx = _auctions.indexWhere((a) => a.code == code);
    if (idx != -1) {
      _auctions[idx] = _auctions[idx].copyWith(termsAccepted: true);
    }
  }

  void lockEmd(String code) {
    final idx = _auctions.indexWhere((a) => a.code == code);
    if (idx != -1) {
      _auctions[idx] = _auctions[idx].copyWith(emdPaid: true);
    }
  }

  List<Award> getAwards({AwardStatus? status}) {
    if (status == null) return _awards;
    return _awards.where((a) => a.status == status).toList();
  }

  Award? getAward(String id) {
    try {
      return _awards.firstWhere((a) => a.id == id);
    } catch (_) {
      return _awards.isNotEmpty ? _awards.first : null;
    }
  }

  void acceptAward(String id) {
    final idx = _awards.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _awards[idx] = _awards[idx].copyWith(
        status: AwardStatus.accepted,
        acceptedAt: DateTime.now().toIso8601String(),
      );
    }
  }

  void declineAward(String id, String reason) {
    final idx = _awards.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _awards[idx] = _awards[idx].copyWith(
        status: AwardStatus.declined,
        declinedReason: reason,
      );
    }
  }

  List<Order> getOrders() => _orders;
  List<FulfilmentRecord> getFulfilments() => _fulfilments;
  List<DisputeItem> getDisputes() => _disputes;
  List<TeamMember> getTeamMembers() => _teamMembers;
  VendorPerformance getPerformance() => _performance;

  RfxPackage? getRfx(String code) => _rfxPackages[code] ?? _rfxPackages.values.firstOrNull;

  void updateRfxQuestion(String code, String questionId, RfxQuestion updated) {
    final pkg = _rfxPackages[code];
    if (pkg != null) {
      final qList = pkg.questions.map((q) => q.id == questionId ? updated : q).toList();
      _rfxPackages[code] = RfxPackage(
        id: pkg.id,
        auctionCode: pkg.auctionCode,
        title: pkg.title,
        buyerName: pkg.buyerName,
        submissionDeadline: pkg.submissionDeadline,
        questions: qList,
      );
    }
  }

  void addInspectionBooking(InspectionBooking booking) {
    _inspectionBookings.add(booking);
  }

  List<InspectionBooking> getInspectionBookings() => _inspectionBookings;

  void addEvidence(CapturedEvidence ev) {
    _evidenceList.add(ev);
  }

  List<CapturedEvidence> getEvidenceList() => _evidenceList;

  void addDispute(DisputeItem item) {
    _disputes.insert(0, item);
  }

  void addTeamMember(TeamMember tm) {
    _teamMembers.add(tm);
  }

  void toggleTeamMember(String id) {
    final idx = _teamMembers.indexWhere((t) => t.id == id);
    if (idx != -1) {
      final cur = _teamMembers[idx];
      _teamMembers[idx] = TeamMember(
        id: cur.id,
        name: cur.name,
        email: cur.email,
        mobile: cur.mobile,
        role: cur.role,
        maxBiddingLimitInr: cur.maxBiddingLimitInr,
        isActive: !cur.isActive,
        joinedAt: cur.joinedAt,
      );
    }
  }
}
