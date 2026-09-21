import '../core/network/api_client.dart';

class PincodeResult {
  final String pincode;
  final String city;
  final String state;
  final String country;
  final List<PostOffice> postOffices;

  PincodeResult({
    required this.pincode,
    required this.city,
    required this.state,
    required this.country,
    required this.postOffices,
  });

  factory PincodeResult.fromJson(Map<String, dynamic> json) {
    return PincodeResult(
      pincode: json['pincode'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String? ?? 'India',
      postOffices:
          (json['post_offices'] as List<dynamic>?)
              ?.map((e) => PostOffice.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class PostOffice {
  final String name;
  final String type;
  final String delivery;

  PostOffice({required this.name, required this.type, required this.delivery});

  factory PostOffice.fromJson(Map<String, dynamic> json) {
    return PostOffice(
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      delivery: json['delivery'] as String? ?? '',
    );
  }
}

class PincodeService {
  final ApiClient _api = ApiClient();
  static final Map<String, Future<PincodeResult?>> _inFlight = {};
  static final Map<String, ({PincodeResult result, DateTime expiresAt})>
  _cache = {};

  Future<PincodeResult?> lookup(String pincode) async {
    final normalized = pincode.trim();
    final cached = _cache[normalized];
    if (cached != null && cached.expiresAt.isAfter(DateTime.now())) {
      return cached.result;
    }
    final pending = _inFlight[normalized];
    if (pending != null) return pending;
    final request = _lookup(normalized);
    _inFlight[normalized] = request;
    request.then(
      (_) => _inFlight.remove(normalized),
      onError: (_, _) => _inFlight.remove(normalized),
    );
    return request;
  }

  Future<PincodeResult?> _lookup(String pincode) async {
    try {
      final response = await _api.get('/pincode/$pincode');
      final result = PincodeResult.fromJson(response);
      _cache[pincode] = (
        result: result,
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );
      return result;
    } catch (_) {
      return null;
    }
  }
}
