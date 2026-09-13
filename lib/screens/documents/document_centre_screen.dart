import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/file_picker_service.dart';
import '../../providers/auth_provider.dart';
import '../../services/vendor_service.dart';

enum DocStatus { verified, pending, rejected, expiringSoon, expired }

class DocItem {
  final String id;
  final String key;
  final String title;
  final String category;
  final bool available;
  final String fileFormat;
  final String fileSize;
  final String uploadedAt;
  final String? expiryDate;
  final DocStatus status;
  final String? rejectionReason;

  const DocItem({
    required this.id,
    required this.key,
    required this.title,
    required this.category,
    required this.available,
    required this.fileFormat,
    required this.fileSize,
    required this.uploadedAt,
    this.expiryDate,
    required this.status,
    this.rejectionReason,
  });
}

class DocumentCentreScreen extends ConsumerStatefulWidget {
  const DocumentCentreScreen({super.key});

  @override
  ConsumerState<DocumentCentreScreen> createState() => _DocumentCentreScreenState();
}

class _DocumentCentreScreenState extends ConsumerState<DocumentCentreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtl;

  List<DocItem> _documents = [];
  bool _loading = true;
  final _vendorService = VendorService();
  Uint8List? _previewBytes;
  bool _documentBusy = false;

  @override
  void initState() {
    super.initState();
    _tabCtl = TabController(length: 5, vsync: this);
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    final vendorCode = ref.read(authProvider).user?.vendorCode;
    if (vendorCode == null || vendorCode.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final response = await _vendorService.getDocuments(vendorCode);
      final rows = (response['data'] as List<dynamic>? ?? const []);
      final docs = rows.whereType<Map<String, dynamic>>().map((row) {
        final rawStatus = '${row['status'] ?? 'pending'}'.toLowerCase();
        return DocItem(
          id: '${row['id']}',
          key: '${row['key'] ?? row['doc_key'] ?? row['kind'] ?? 'document'}',
          title: '${row['name'] ?? row['file_name'] ?? row['kind'] ?? 'Document'}',
          category: '${row['kind'] ?? row['key'] ?? 'Document'}',
          available: row['available'] != false,
          fileFormat: '${row['file_name'] ?? ''}'.split('.').last.toUpperCase(),
          fileSize: row['size_kb'] == null ? '—' : '${row['size_kb']} KB',
          uploadedAt: '${row['uploaded_at'] ?? ''}'.split('T').first,
          expiryDate: null,
          status: rawStatus == 'approved' ? DocStatus.verified : rawStatus == 'rejected' ? DocStatus.rejected : DocStatus.pending,
          rejectionReason: row['reason']?.toString(),
        );
      }).toList();
      if (mounted) setState(() => _documents = docs);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not load your documents.')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _tabCtl.dispose();
    super.dispose();
  }

  void _showReplaceDialog(DocItem doc) {
    final vendorCode = ref.read(authProvider).user?.vendorCode;
    if (vendorCode == null || vendorCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your vendor account is not available.')),
      );
      return;
    }

    PickedAttachment? selectedFile;
    var uploading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Replace Document',
                  style: AppTextStyles.heading(
                    size: 17,
                    weight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doc.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final picked = await AppFilePicker.showPickerBottomSheet(
                      context,
                      title: 'Upload ${doc.title}',
                    );
                    if (picked != null) {
                      setSheetState(() => selectedFile = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: selectedFile != null
                          ? AppColors.success.withValues(alpha: 0.05)
                          : AppColors.appBg,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                      border: Border.all(
                        color: selectedFile != null
                            ? AppColors.success
                            : AppColors.cardBorder,
                        width: selectedFile != null ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: selectedFile != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  selectedFile!.isImage
                                      ? Icons.image_rounded
                                      : Icons.description_rounded,
                                  size: 36,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedFile!.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.navy,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${selectedFile!.extension.toUpperCase()} • ${selectedFile!.formattedSize} • Ready to upload',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.success,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.success,
                                  size: 22,
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                const Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 40,
                                  color: AppColors.navy,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Tap to choose PDF or Image file',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.navy,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Max file size 10MB • Clear legible scan required',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: selectedFile == null ||
                            selectedFile!.path == null
                        ? null
                        : () async {
                            setSheetState(() => uploading = true);
                            try {
                              await _vendorService.uploadDocument(
                                vendorCode: vendorCode,
                                docKey: doc.key,
                                kind: doc.category,
                                filePath: selectedFile!.path!,
                                fileName: selectedFile!.name,
                              );
                              if (!mounted || !ctx.mounted) return;
                              Navigator.of(ctx).pop();
                              await _loadDocuments();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '✓ ${doc.title} replaced and queued for compliance verification',
                                    ),
                                  ),
                                );
                              }
                            } catch (_) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Could not upload this document.'),
                                  ),
                                );
                              }
                            } finally {
                              if (ctx.mounted) {
                                setSheetState(() => uploading = false);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusXl,
                        ),
                      ),
                    ),
                    child: uploading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : const Text(
                            'Upload & Submit for Review',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _viewSecureDoc(DocItem doc) async {
    final vendorCode = ref.read(authProvider).user?.vendorCode;
    if (vendorCode == null || vendorCode.isEmpty) return;
    setState(() => _documentBusy = true);
    try {
      final bytes = await _vendorService.downloadDocument(vendorCode, doc.id);
      if (!mounted) return;
      _previewBytes = Uint8List.fromList(bytes);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load this document.')),
        );
      }
      return;
    } finally {
      if (mounted) setState(() => _documentBusy = false);
    }
    if (!mounted || _previewBytes == null) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Confidential Watermarked Document',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Stack(
                        children: [
                          if (doc.fileFormat == 'JPG' ||
                              doc.fileFormat == 'JPEG' ||
                              doc.fileFormat == 'PNG' ||
                              doc.fileFormat == 'WEBP')
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.memory(
                                  _previewBytes!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          if (!['JPG', 'JPEG', 'PNG', 'WEBP'].contains(
                            doc.fileFormat,
                          ))
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.picture_as_pdf,
                                    size: 48,
                                    color: AppColors.destructive,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    doc.title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.navy,
                                    ),
                                  ),
                                  Text(
                                    '${doc.fileFormat} • ${doc.fileSize}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (['JPG', 'JPEG', 'PNG', 'WEBP'].contains(
                            doc.fileFormat,
                          ))
                            Positioned(
                              left: 12,
                              right: 12,
                              bottom: 10,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  child: Text(
                                    '${doc.title} • ${doc.fileFormat}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.navy,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Watermark Overlay
                          Positioned.fill(
                            child: Center(
                              child: Transform.rotate(
                                angle: -0.3,
                                child: Text(
                                  'SCRAPIFY SECURE • DEVZIGN SOLUTIONS',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black.withValues(alpha: 0.06),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 16,
                            color: Color(0xFFD97706),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Confidentiality Notice: Screenshot and distribution are logged under platform audit trail.',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadDocument(DocItem doc) async {
    final vendorCode = ref.read(authProvider).user?.vendorCode;
    if (vendorCode == null || vendorCode.isEmpty) return;
    setState(() => _documentBusy = true);
    try {
      final bytes = await _vendorService.downloadDocument(vendorCode, doc.id);
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save document',
        fileName: doc.title,
      );
      if (path != null) await File(path).writeAsBytes(bytes, flush: true);
      if (mounted && path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document saved successfully.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not download this document.')),
        );
      }
    } finally {
      if (mounted) setState(() => _documentBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.appBg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        title: const Text('Enterprise Document Vault'),
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabCtl,
          isScrollable: true,
          labelColor: AppColors.auction,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
          indicatorColor: AppColors.auction,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'All Docs (6)'),
            Tab(text: 'Verified (3)'),
            Tab(text: 'Pending (1)'),
            Tab(text: 'Expiring Soon (1)'),
            Tab(text: 'Rejected (1)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtl,
        children: [
          _buildDocList(null),
          _buildDocList(DocStatus.verified),
          _buildDocList(DocStatus.pending),
          _buildDocList(DocStatus.expiringSoon),
          _buildDocList(DocStatus.rejected),
        ],
      ),
    );
  }

  Widget _buildDocList(DocStatus? filter) {
    final list = filter == null
        ? _documents
        : _documents.where((d) => d.status == filter).toList();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final doc = list[i];
        return _docCard(doc);
      },
    );
  }

  Widget _docCard(DocItem doc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        border: Border.all(
          color: doc.status == DocStatus.rejected
              ? const Color(0xFFFCA5A5)
              : AppColors.cardBorder,
        ),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.navy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  doc.category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
              ),
              _statusBadge(doc.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            doc.title,
            style: AppTextStyles.heading(size: 14.5, weight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            '${doc.fileFormat} • ${doc.fileSize} • Uploaded: ${doc.uploadedAt}',
            style: AppTextStyles.captionMuted,
          ),
          if (doc.expiryDate != null) ...[
            const SizedBox(height: 2),
            Text(
              'Expires on: ${doc.expiryDate}',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.auction,
              ),
            ),
          ],
          if (doc.status == DocStatus.rejected &&
              doc.rejectionReason != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Rejection Reason: ${doc.rejectionReason}',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.destructive,
                  height: 1.3,
                ),
              ),
            ),
          ],
          if (!doc.available) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'This document is unavailable on the server. Please replace it.',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF92400E),
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              if (doc.available) Expanded(
                child: OutlinedButton.icon(
                  onPressed: _documentBusy ? null : () => _viewSecureDoc(doc),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text(
                    'View Document',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.navy,
                    side: const BorderSide(color: AppColors.cardBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                  ),
                ),
              ),
              if (doc.available) const SizedBox(width: 8),
              if (doc.available) Expanded(
                child: OutlinedButton.icon(
                  onPressed: _documentBusy ? null : () => _downloadDocument(doc),
                  icon: const Icon(Icons.download_outlined, size: 16),
                  label: const Text(
                    'Download',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.navy,
                    side: const BorderSide(color: AppColors.cardBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showReplaceDialog(doc),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text(
                    'Replace Doc',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusLg,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(DocStatus st) {
    Color bg;
    Color fg;
    String label;

    switch (st) {
      case DocStatus.verified:
        bg = AppColors.success.withValues(alpha: 0.12);
        fg = AppColors.success;
        label = 'Verified';
        break;
      case DocStatus.pending:
        bg = AppColors.accentBlue.withValues(alpha: 0.12);
        fg = AppColors.accentBlue;
        label = 'Under Review';
        break;
      case DocStatus.expiringSoon:
        bg = AppColors.auction.withValues(alpha: 0.12);
        fg = AppColors.auction;
        label = 'Expiring in 16 Days';
        break;
      case DocStatus.rejected:
        bg = AppColors.destructive.withValues(alpha: 0.12);
        fg = AppColors.destructive;
        label = 'Rejected';
        break;
      case DocStatus.expired:
        bg = const Color(0xFFE2E8F0);
        fg = const Color(0xFF64748B);
        label = 'Expired';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}
