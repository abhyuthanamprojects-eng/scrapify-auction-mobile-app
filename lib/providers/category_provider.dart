import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../services/category_service.dart';

final _categoryService = CategoryService();

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final result = await _categoryService.list();
  return result.tree;
});
