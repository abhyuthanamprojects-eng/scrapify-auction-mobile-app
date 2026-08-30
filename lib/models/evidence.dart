import 'package:equatable/equatable.dart';

enum EvidenceType {
  photo,
  document,
  documentPdf,
  signature,
  digitalSignature,
  weighbridge,
  weighbridgeSlip,
  serialNumberScan,
  gpsLocation;

  String get label => switch (this) {
        photo => 'Site / Item Photo',
        document || documentPdf => 'Invoice / Challan Doc',
        signature || digitalSignature => 'Authorized Signature',
        weighbridge || weighbridgeSlip => 'Weighbridge Slip',
        serialNumberScan => 'Serial Number Scan',
        gpsLocation => 'GPS Geo-stamp',
      };
}

class CapturedEvidence extends Equatable {
  final String id;
  final EvidenceType type;
  final String title;
  final String? fileUrl;
  final String? localPath;
  final double? latitude;
  final double? longitude;
  final String timestamp;
  final String? remarks;
  final double? recordedWeightKg;
  final String? signerName;
  final String? capturedBy;
  final String? geoCoordinates;
  final String? status;
  final String? metricValue;
  final bool isUploaded;

  const CapturedEvidence({
    required this.id,
    required this.type,
    required this.title,
    this.fileUrl,
    this.localPath,
    this.latitude,
    this.longitude,
    required this.timestamp,
    this.remarks,
    this.recordedWeightKg,
    this.signerName,
    this.capturedBy,
    this.geoCoordinates,
    this.status,
    this.metricValue,
    this.isUploaded = true,
  });

  factory CapturedEvidence.fromJson(Map<String, dynamic> json) => CapturedEvidence(
        id: json['id'] as String? ?? 'EV-${DateTime.now().millisecondsSinceEpoch}',
        type: EvidenceType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => EvidenceType.photo,
        ),
        title: json['title'] as String? ?? 'Evidence Item',
        fileUrl: json['file_url'] as String?,
        localPath: json['local_path'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
        remarks: json['remarks'] as String?,
        recordedWeightKg: (json['recorded_weight_kg'] as num?)?.toDouble(),
        signerName: json['signer_name'] as String?,
        capturedBy: json['captured_by'] as String?,
        geoCoordinates: json['geo_coordinates'] as String?,
        status: json['status'] as String?,
        metricValue: json['metric_value'] as String?,
        isUploaded: json['is_uploaded'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'file_url': fileUrl,
        'local_path': localPath,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp,
        'remarks': remarks,
        'recorded_weight_kg': recordedWeightKg,
        'signer_name': signerName,
        'captured_by': capturedBy,
        'geo_coordinates': geoCoordinates,
        'status': status,
        'metric_value': metricValue,
        'is_uploaded': isUploaded,
      };

  @override
  List<Object?> get props => [id, type, timestamp, isUploaded];
}
