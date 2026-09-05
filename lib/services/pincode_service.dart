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
      postOffices: (json['post_offices'] as List<dynamic>?)
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

  Future<PincodeResult?> lookup(String pincode) async {
    try {
      final response = await _api.get('/pincode/$pincode');
      return PincodeResult.fromJson(response);
    } catch (_) {
      return null;
    }
  }
}
