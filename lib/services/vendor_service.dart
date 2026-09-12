import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';

class VendorService {
  final _api = ApiClient();

  Future<Map<String, dynamic>> saveStep(Map<String, dynamic> data) async {
    return await _api.post(Endpoints.vendorSaveStep, data: data);
  }

  Future<Map<String, dynamic>> submitKyc(String vendorCode) async {
    return await _api.post(Endpoints.vendorSubmitKyc(vendorCode));
  }

  Future<Map<String, dynamic>> resubmitKyc(String vendorCode) async {
    return await _api.post(Endpoints.vendorResubmitKyc(vendorCode));
  }

  Future<Map<String, dynamic>> getKycStatus(String vendorCode) async {
    return await _api.get(Endpoints.vendorKycStatus(vendorCode));
  }

  Future<Map<String, dynamic>> getBusinessVerification() =>
      _api.get(Endpoints.kybStatus);
  Future<Map<String, dynamic>> getBusinessVerificationHistory() =>
      _api.get(Endpoints.kybHistory);
  Future<Map<String, dynamic>> verifyGstin(
    String gstin, {
    String? businessName,
  }) => _api.post(
    Endpoints.kybVerifyGstin,
    data: {
      'gstin': gstin,
      if (businessName != null && businessName.isNotEmpty)
        'business_name': businessName,
    },
  );
  Future<Map<String, dynamic>> verifyBank({
    required String account,
    required String confirmation,
    required String ifsc,
    String? name,
    String? phone,
  }) => _api.post(
    Endpoints.kybVerifyBank,
    data: {
      'bank_account': account,
      'bank_account_confirmation': confirmation,
      'ifsc': ifsc,
      if (name != null && name.isNotEmpty) 'name': name,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    },
  );
  Future<Map<String, dynamic>> requestBusinessReverification() =>
      _api.post(Endpoints.kybReverify);

  Future<Map<String, dynamic>> register({
    required String companyName,
    required String contactName,
    required String email,
    required String phone,
    String? location,
    String? address,
    String? gstNumber,
    String? panNumber,
    String? licenseNumber,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? accountHolderName,
    List<String>? materialInterest,
    Map<String, dynamic>? warehouseDetails,
    bool termsAccepted = false,
  }) async {
    return await _api.post(
      Endpoints.vendorRegister,
      data: {
        'company_name': companyName,
        'contact_name': contactName,
        'email': email,
        'phone': phone,
        if (location != null) 'location': location,
        if (address != null) 'address': address,
        if (gstNumber != null) 'gst_number': gstNumber,
        if (panNumber != null) 'pan_number': panNumber,
        if (licenseNumber != null) 'license_number': licenseNumber,
        if (bankName != null) 'bank_name': bankName,
        if (accountNumber != null) 'account_number': accountNumber,
        if (ifscCode != null) 'ifsc_code': ifscCode,
        if (accountHolderName != null) 'account_holder_name': accountHolderName,
        if (materialInterest != null) 'material_interest': materialInterest,
        if (warehouseDetails != null) 'warehouse_details': warehouseDetails,
        'terms_accepted': termsAccepted,
      },
    );
  }

  Future<Map<String, dynamic>> uploadDocument({
    required String vendorCode,
    required String docKey,
    required String kind,
    required String filePath,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'doc_key': docKey,
      'kind': kind,
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    return await _api.uploadFile(
      Endpoints.vendorDocuments(vendorCode),
      data: formData,
    );
  }

  Future<Map<String, dynamic>> recordPayment({
    required String vendorCode,
    required String method,
    required String reference,
    required double amount,
  }) async {
    return await _api.post(
      Endpoints.vendorPayment(vendorCode),
      data: {'method': method, 'reference': reference, 'amount': amount},
    );
  }
}
