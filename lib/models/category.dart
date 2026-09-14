class Category {
  final int id;
  final String name;
  final String slug;
  final int? parentId;
  final String direction;
  final bool templateRequired;
  final bool allowManualItems;
  final bool allowExcel;
  final List<Category> children;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.parentId,
    this.direction = 'both',
    this.templateRequired = false,
    this.allowManualItems = true,
    this.allowExcel = true,
    this.children = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        slug: json['slug'] as String? ?? '',
        parentId: json['parent_id'] as int?,
        direction: json['direction'] as String? ?? 'both',
        templateRequired: json['template_required'] as bool? ?? false,
        allowManualItems: json['allow_manual_items'] as bool? ?? true,
        allowExcel: json['allow_excel'] as bool? ?? true,
        children: (json['children'] as List?)
                ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
