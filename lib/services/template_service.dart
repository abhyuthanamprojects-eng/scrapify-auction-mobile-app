import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../models/auction_template.dart';

class TemplateService {
  final _api = ApiClient();

  /// Fetch the auction template for a given category and direction.
  Future<AuctionTemplate> getTemplate(
    int categoryId, {
    String direction = 'forward',
  }) async {
    final data = await _api.get(
      Endpoints.categoryTemplate(categoryId),
      queryParameters: {'direction': direction},
    );
    final inner = data['data'] as Map<String, dynamic>?;
    if (inner == null || inner['id'] == null) {
      throw Exception('No active template for this category.');
    }
    return AuctionTemplate.fromJson(inner);
  }

  /// Download the template XLSX as raw bytes.
  Future<List<int>> downloadTemplate(int templateId) {
    return _api.downloadBytes(Endpoints.templateDownload(templateId));
  }

  /// Upload a completed template file for an auction.
  Future<TemplateUploadResult> uploadTemplate({
    required String auctionCode,
    required int templateId,
    required String filePath,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'template_id': templateId,
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    try {
      final data = await _api.uploadFile(
        Endpoints.templateUpload(auctionCode),
        data: formData,
      );
      return TemplateUploadResult.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode == 422 && e.raw != null) {
        return TemplateUploadResult.fromJson(e.raw!);
      }
      rethrow;
    }
  }

  /// Confirm a previously uploaded template import.
  Future<Map<String, dynamic>> confirmUpload({
    required String auctionCode,
    required int uploadId,
  }) async {
    return await _api.post(
      Endpoints.templateUploadConfirm(auctionCode, uploadId),
    );
  }
}
