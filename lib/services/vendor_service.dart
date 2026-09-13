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
    String? businessType,
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
        ...?location == null ? null : {'location': location},
        ...?address == null ? null : {'address': address},
        ...?gstNumber == null ? null : {'gst_number': gstNumber},
        ...?panNumber == null ? null : {'pan_number': panNumber},
        ...?licenseNumber == null ? null : {'license_number': licenseNumber},
        ...?bankName == null ? null : {'bank_name': bankName},
        ...?accountNumber == null ? null : {'account_number': accountNumber},
        ...?ifscCode == null ? null : {'ifsc_code': ifscCode},
        ...?accountHolderName == null
            ? null
            : {'account_holder_name': accountHolderName},
        if (businessType != null && businessType.isNotEmpty)
          'business_type': businessType,
        ...?materialInterest == null
            ? null
            : {'material_interest': materialInterest},
        ...?warehouseDetails == null
            ? null
            : {'warehouse_details': warehouseDetails},
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

  Future<Map<String, dynamic>> getDocuments(String vendorCode) async {
    return await _api.get(Endpoints.vendorDocuments(vendorCode));
  }

  Future<List<int>> downloadDocument(String vendorCode, String documentId) {
    return _api.downloadBytes(
      '${Endpoints.vendorDocuments(vendorCode)}/$documentId/download',
    );
  }

  Future<Map<String, dynamic>> verifyPan({
    required String pan,
    String? name,
    String? dateOfBirth,
  }) => _api.post(
    Endpoints.kybVerifyPan,
    data: {
      'pan': pan,
      if (name != null && name.isNotEmpty) 'name': name,
      if (dateOfBirth != null && dateOfBirth.isNotEmpty)
        'date_of_birth': dateOfBirth,
    },
  );

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
