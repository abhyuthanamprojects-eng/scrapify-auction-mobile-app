import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/category.dart';

class CategoryService {
  final _api = ApiClient();

  Future<({List<Category> tree, List<Category> flat})> list() async {
    final data = await _api.get(Endpoints.categories, anonymous: true);

    final tree = (data['data'] as List?)
            ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final flat = (data['flat'] as List?)
            ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return (tree: tree, flat: flat);
  }
}
