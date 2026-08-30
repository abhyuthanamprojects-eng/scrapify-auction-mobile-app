import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

enum DocStatus { verified, pending, rejected, expiringSoon, expired }

class DocItem {
  final String id;
  final String title;
  final String category;
  final String fileFormat;
  final String fileSize;
  final String uploadedAt;
  final String? expiryDate;
  final DocStatus status;
  final String? rejectionReason;

  const DocItem({
    required this.id,
    required this.title,
    required this.category,
    required this.fileFormat,
    required this.fileSize,
    required this.uploadedAt,
    this.expiryDate,
    required this.status,
    this.rejectionReason,
  });
}

class DocumentCentreScreen extends StatefulWidget {
  const DocumentCentreScreen({super.key});

  @override
  State<DocumentCentreScreen> createState() => _DocumentCentreScreenState();
}

class _DocumentCentreScreenState extends State<DocumentCentreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtl;

  final List<DocItem> _documents = const [
    DocItem(
      id: 'DOC-GST-01',
      title: 'GST Registration Certificate (Form REG-06)',
      category: 'Tax & Statutory',
      fileFormat: 'PDF',
      fileSize: '1.4 MB',
      uploadedAt: '12 Aug 2026',
      status: DocStatus.verified,
    ),
    DocItem(
      id: 'DOC-PAN-01',
      title: 'Company PAN Card',
      category: 'Tax & Statutory',
      fileFormat: 'PDF',
      fileSize: '840 KB',
      uploadedAt: '12 Aug 2026',
      status: DocStatus.verified,
    ),
    DocItem(
      id: 'DOC-PCB-01',
      title: 'State Pollution Control Board (SPCB) Consent to Operate',
      category: 'Environmental & Safety',
      fileFormat: 'PDF',
      fileSize: '3.8 MB',
      uploadedAt: '14 Aug 2026',
      expiryDate: '15 Sep 2026',
      status: DocStatus.expiringSoon,
    ),
    DocItem(
      id: 'DOC-BNK-01',
      title: 'Cancelled Cheque with Printed Name',
      category: 'Financial',
      fileFormat: 'JPEG',
      fileSize: '1.1 MB',
      uploadedAt: '20 Aug 2026',
      status: DocStatus.verified,
    ),
    DocItem(
      id: 'DOC-ISO-01',
      title: 'ISO 9001:2015 Quality Management Certificate',
      category: 'Technical & Quality',
      fileFormat: 'PDF',
      fileSize: '2.2 MB',
      uploadedAt: '24 Aug 2026',
      status: DocStatus.pending,
    ),
    DocItem(
      id: 'DOC-POA-01',
      title: 'Board Resolution & Power of Attorney for Live Bidding',
      category: 'Legal & Governance',
      fileFormat: 'PDF',
      fileSize: '1.9 MB',
      uploadedAt: '18 Aug 2026',
      status: DocStatus.rejected,
      rejectionReason: 'Board resolution document was missing mandatory company seal and 2 director counter-signatures.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtl = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabCtl.dispose();
    super.dispose();
  }

  void _showReplaceDialog(DocItem doc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 14),
            Text('Replace Document', style: AppTextStyles.heading(size: 17, weight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(doc.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navy)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.appBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                border: Border.all(color: AppColors.cardBorder, style: BorderStyle.solid),
              ),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.cloud_upload_outlined, size: 40, color: AppColors.navy),
                    const SizedBox(height: 8),
                    const Text('Tap to choose PDF or Image file', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navy)),
                    const SizedBox(height: 2),
                    const Text('Max file size 10MB • Clear legible scan required', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('✓ ${doc.title} replaced and queued for compliance verification')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
                ),
                child: const Text('Upload & Submit for Review', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewSecureDoc(DocItem doc) {
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Confidential Watermarked Document', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.white)),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.white, size: 20),
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
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.picture_as_pdf, size: 48, color: AppColors.destructive),
                                const SizedBox(height: 8),
                                Text(doc.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navy)),
                                Text('${doc.fileFormat} • ${doc.fileSize}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                              ],
                            ),
                          ),
                          // Watermark Overlay
                          Positioned.fill(
                            child: Center(
                              child: Transform.rotate(
                                angle: -0.3,
                                child: Text(
                                  'SCRAPIFY SECURE • DEVZIGN SOLUTIONS',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black.withValues(alpha: 0.06)),
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
                      decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
                      child: const Row(
                        children: [
                          Icon(Icons.shield_outlined, size: 16, color: Color(0xFFD97706)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Confidentiality Notice: Screenshot and distribution are logged under platform audit trail.',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
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

  @override
  Widget build(BuildContext context) {
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
    final list = filter == null ? _documents : _documents.where((d) => d.status == filter).toList();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
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
        border: Border.all(color: doc.status == DocStatus.rejected ? const Color(0xFFFCA5A5) : AppColors.cardBorder),
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
                decoration: BoxDecoration(color: AppColors.navy.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(4)),
                child: Text(doc.category.toUpperCase(), style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.navy)),
              ),
              _statusBadge(doc.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(doc.title, style: AppTextStyles.heading(size: 14.5, weight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('${doc.fileFormat} • ${doc.fileSize} • Uploaded: ${doc.uploadedAt}', style: AppTextStyles.captionMuted),
          if (doc.expiryDate != null) ...[
            const SizedBox(height: 2),
            Text('Expires on: ${doc.expiryDate}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.auction)),
          ],
          if (doc.status == DocStatus.rejected && doc.rejectionReason != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8)),
              child: Text(
                'Rejection Reason: ${doc.rejectionReason}',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.destructive, height: 1.3),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewSecureDoc(doc),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('View Document', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.navy,
                    side: const BorderSide(color: AppColors.cardBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
                  ),
                ),
              ),
              if (doc.status == DocStatus.rejected || doc.status == DocStatus.expiringSoon) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showReplaceDialog(doc),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Replace Doc', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
                    ),
                  ),
                ),
              ],
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
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}
