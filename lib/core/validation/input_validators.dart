String normalizeIndianMobile(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  return digits.startsWith('91') && digits.length == 12
      ? digits.substring(2)
      : digits;
}

bool isIndianMobile(String value) =>
    RegExp(r'^[6-9]\d{9}$').hasMatch(normalizeIndianMobile(value));

bool isEmail(String value) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim());

bool isIndianPincode(String value) =>
    RegExp(r'^[1-9]\d{5}$').hasMatch(value.trim());

bool isGstin(String value) => RegExp(
  r'^\d{2}[A-Z]{5}\d{4}[A-Z][1-9A-Z]Z[0-9A-Z]$',
).hasMatch(value.trim().toUpperCase());

bool isPan(String value) =>
    RegExp(r'^[A-Z]{5}\d{4}[A-Z]$').hasMatch(value.trim().toUpperCase());

bool isIfsc(String value) =>
    RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(value.trim().toUpperCase());

bool isStrongPassword(String value) =>
    value.length >= 8 &&
    RegExp(r'[A-Z]').hasMatch(value) &&
    RegExp(r'\d').hasMatch(value) &&
    RegExp(r'[^A-Za-z0-9]').hasMatch(value);
