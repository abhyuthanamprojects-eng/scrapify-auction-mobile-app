import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auction_template.dart';
import '../services/template_service.dart';

final _templateService = TemplateService();

/// Fetch the auction template for a category + direction pair.
final categoryTemplateProvider =
    FutureProvider.family<AuctionTemplate, ({int categoryId, String direction})>(
  (ref, params) async {
    return _templateService.getTemplate(
      params.categoryId,
      direction: params.direction,
    );
  },
);

/// Holds the most recent upload result so the UI can show validation / preview.
final templateUploadResultProvider =
    StateProvider<TemplateUploadResult?>((ref) => null);
