class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String roleLabel;
  final String status;
  final List<String> permissions;
  final VendorInfo? vendor;
  final OrgInfo? organization;
  final String? emailVerifiedAt;
  final String? phoneVerifiedAt;
  final String? lastLoginAt;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = 'buyer',
    this.roleLabel = 'Buyer',
    this.status = 'active',
    this.permissions = const [],
    this.vendor,
    this.organization,
    this.emailVerifiedAt,
    this.phoneVerifiedAt,
    this.lastLoginAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        role: json['role'] as String? ?? 'buyer',
        roleLabel: json['role_label'] as String? ?? 'Buyer',
        status: json['status'] as String? ?? 'active',
        permissions: (json['permissions'] as List?)?.cast<String>() ?? [],
        vendor: json['vendor'] != null
            ? VendorInfo.fromJson(json['vendor'] as Map<String, dynamic>)
            : null,
        organization: json['organization'] != null
            ? OrgInfo.fromJson(json['organization'] as Map<String, dynamic>)
            : null,
        emailVerifiedAt: json['email_verified_at'] as String?,
        phoneVerifiedAt: json['phone_verified_at'] as String?,
        lastLoginAt: json['last_login_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'role_label': roleLabel,
        'status': status,
        'permissions': permissions,
        'vendor': vendor?.toJson(),
        'organization': organization?.toJson(),
        'email_verified_at': emailVerifiedAt,
        'phone_verified_at': phoneVerifiedAt,
        'last_login_at': lastLoginAt,
      };

  bool get isSeller => role == 'seller';
  bool get isBuyer => role == 'buyer';
  bool get isAdmin => role == 'admin' || role == 'super_admin';

  String? get companyName =>
      vendor?.companyName ?? organization?.companyName;

  String get kycStatus => vendor?.status ?? (isAdmin ? 'approved' : 'draft');
  bool get kycVerified => vendor?.status == 'approved' || isAdmin;
  bool get isKycPending => vendor?.status == 'pending' || vendor?.status == 'under_verification' || vendor?.status == 'draft';
  bool get isKycRejected => vendor?.status == 'rejected';
  bool get canBid => (vendor?.canBid ?? false) || isAdmin;
  String? get vendorCode => vendor?.code;
  String? get rejectionReason => vendor?.rejectionReason;

  bool hasPerm(String perm) => permissions.contains(perm) || permissions.contains('*');
}

class VendorInfo {
  final String code;
  final String companyName;
  final String status;
  final bool canBid;
  final String? rejectionReason;
  final int registrationStep;
  final String? gstNumber;
  final String? panNumber;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? accountHolderName;
  final String? addressLine1;
  final String? city;
  final String? state;
  final String? pincode;

  const VendorInfo({
    required this.code,
    required this.companyName,
    required this.status,
    this.canBid = false,
    this.rejectionReason,
    this.registrationStep = 1,
    this.gstNumber,
    this.panNumber,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.accountHolderName,
    this.addressLine1,
    this.city,
    this.state,
    this.pincode,
  });

  bool get isPending => status == 'pending' || status == 'under_verification' || status == 'draft';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  factory VendorInfo.fromJson(Map<String, dynamic> json) => VendorInfo(
        code: json['code'] as String? ?? json['id'] as String? ?? '',
        companyName: json['company_name'] as String? ?? '',
        status: json['status'] as String? ?? 'pending',
        canBid: json['can_bid'] as bool? ?? (json['status'] == 'approved'),
        rejectionReason: json['rejection_reason'] as String?,
        registrationStep: (json['registration_step'] as num?)?.toInt() ?? 1,
        gstNumber: json['gst_number'] as String?,
        panNumber: json['pan_number'] as String?,
        bankName: json['bank_name'] as String?,
        accountNumber: json['account_number'] as String?,
        ifscCode: json['ifsc_code'] as String?,
        accountHolderName: json['account_holder_name'] as String?,
        addressLine1: json['address_line1'] as String? ?? json['address'] as String?,
        city: json['city'] as String?,
        state: json['state'] as String?,
        pincode: json['pincode'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': code,
        'code': code,
        'company_name': companyName,
        'status': status,
        'can_bid': canBid,
        'rejection_reason': rejectionReason,
        'registration_step': registrationStep,
        'gst_number': gstNumber,
        'pan_number': panNumber,
        'bank_name': bankName,
        'account_number': accountNumber,
        'ifsc_code': ifscCode,
        'account_holder_name': accountHolderName,
        'address_line1': addressLine1,
        'city': city,
        'state': state,
        'pincode': pincode,
      };
}

class OrgInfo {
  final String id;
  final String companyName;

  const OrgInfo({required this.id, required this.companyName});

  factory OrgInfo.fromJson(Map<String, dynamic> json) => OrgInfo(
        id: json['id'] as String? ?? '',
        companyName: json['company_name'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'company_name': companyName,
      };
}
