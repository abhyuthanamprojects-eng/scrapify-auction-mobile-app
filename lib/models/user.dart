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

  bool get kycVerified => vendor?.status == 'approved';
  bool get canBid => vendor?.canBid ?? false;
  String? get vendorCode => vendor?.code;

  bool hasPerm(String perm) => permissions.contains(perm) || permissions.contains('*');
}

class VendorInfo {
  final String code;
  final String companyName;
  final String status;
  final bool canBid;

  const VendorInfo({
    required this.code,
    required this.companyName,
    required this.status,
    this.canBid = false,
  });

  factory VendorInfo.fromJson(Map<String, dynamic> json) => VendorInfo(
        code: json['id'] as String? ?? json['code'] as String? ?? '',
        companyName: json['company_name'] as String? ?? '',
        status: json['status'] as String? ?? 'pending',
        canBid: json['can_bid'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': code,
        'code': code,
        'company_name': companyName,
        'status': status,
        'can_bid': canBid,
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
