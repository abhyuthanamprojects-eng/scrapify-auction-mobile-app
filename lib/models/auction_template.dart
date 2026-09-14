class AuctionTemplate {
  final int id;
  final String code;
  final String templateCode;
  final String name;
  final int categoryId;
  final int? subcategoryId;
  final String direction;
  final String version;
  final String status;
  final Map<String, dynamic> schemaDefinition;
  final String? instructions;

  AuctionTemplate({
    required this.id,
    required this.code,
    required this.templateCode,
    required this.name,
    required this.categoryId,
    this.subcategoryId,
    required this.direction,
    required this.version,
    required this.status,
    required this.schemaDefinition,
    this.instructions,
  });

  factory AuctionTemplate.fromJson(Map<String, dynamic> json) {
    return AuctionTemplate(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      templateCode: json['template_code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      categoryId: json['category_id'] as int? ?? 0,
      subcategoryId: json['subcategory_id'] as int?,
      direction: json['direction'] as String? ?? 'both',
      version: json['version'] as String? ?? '1.0',
      status: json['status'] as String? ?? 'draft',
      schemaDefinition: (json['schema_definition'] as Map<String, dynamic>?) ?? {},
      instructions: json['instructions'] as String?,
    );
  }
}

class TemplateUploadResult {
  final bool valid;
  final List<Map<String, dynamic>> errors;
  final int rowCount;
  final double totalQuantity;
  final double totalReferenceValue;
  final int? uploadId;
  final List<Map<String, dynamic>> rows;

  TemplateUploadResult({
    required this.valid,
    required this.errors,
    required this.rowCount,
    required this.totalQuantity,
    required this.totalReferenceValue,
    this.uploadId,
    required this.rows,
  });

  factory TemplateUploadResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return TemplateUploadResult(
      valid: data['valid'] as bool? ?? false,
      errors: List<Map<String, dynamic>>.from(data['errors'] as List? ?? []),
      rowCount: data['row_count'] as int? ?? 0,
      totalQuantity: (data['total_quantity'] as num?)?.toDouble() ?? 0,
      totalReferenceValue: (data['total_reference_value'] as num?)?.toDouble() ?? 0,
      uploadId: (data['upload'] as Map<String, dynamic>?)?['id'] as int?,
      rows: List<Map<String, dynamic>>.from(data['rows'] as List? ?? []),
    );
  }
}
