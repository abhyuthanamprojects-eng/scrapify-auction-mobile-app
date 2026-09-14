import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/network/api_config.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/file_picker_service.dart';
import '../../models/auction_template.dart';
import '../../providers/template_provider.dart';
import '../../services/template_service.dart';
import '../../widgets/shared/app_button.dart';

/// Standalone screen for downloading a category template, uploading completed
/// data, previewing the parsed rows, and confirming the import into an auction.
class TemplateUploadScreen extends ConsumerStatefulWidget {
  /// The auction code to attach the import to.
  final String auctionCode;

  /// Category id used to resolve the right template.
  final int categoryId;

  /// forward / reverse -- determines which template variant is fetched.
  final String direction;

  const TemplateUploadScreen({
    super.key,
    required this.auctionCode,
    required this.categoryId,
    this.direction = 'forward',
  });

  @override
  ConsumerState<TemplateUploadScreen> createState() =>
      _TemplateUploadScreenState();
}

class _TemplateUploadScreenState extends ConsumerState<TemplateUploadScreen> {
  final _templateService = TemplateService();

  bool _isDownloading = false;
  bool _isUploading = false;
  bool _isConfirming = false;

  TemplateUploadResult? _uploadResult;

  @override
  Widget build(BuildContext context) {
    final templateAsync = ref.watch(
      categoryTemplateProvider(
        (categoryId: widget.categoryId, direction: widget.direction),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: templateAsync.when(
                data: (template) => _buildBody(template),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No template available for this category.\n\n$e',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPaddingH,
        8,
        AppSpacing.screenPaddingH,
        0,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.navyWithOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 18,
                color: AppColors.navy,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Template Upload', style: AppTextStyles.titleSmall),
              Text(
                'Auction ${widget.auctionCode}',
                style: AppTextStyles.captionMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AuctionTemplate template) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
      children: [
        // --- Template info card ---
        _infoCard(template),
        const SizedBox(height: 16),

        // --- Instructions ---
        if (template.instructions != null &&
            template.instructions!.isNotEmpty) ...[
          Text('Instructions', style: AppTextStyles.labelMedium),
          const SizedBox(height: 6),
          Text(
            template.instructions!,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // --- Download button ---
        _downloadButton(template),
        const SizedBox(height: 12),

        // --- Upload button ---
        _uploadButton(template),
        const SizedBox(height: 20),

        // --- Validation result ---
        if (_uploadResult != null) ...[
          _validationSection(),
          const SizedBox(height: 16),
          if (_uploadResult!.valid && _uploadResult!.rows.isNotEmpty) ...[
            _previewSection(),
            const SizedBox(height: 16),
            _confirmButton(),
          ],
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Template info
  // ---------------------------------------------------------------------------

  Widget _infoCard(AuctionTemplate template) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.appBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.auction.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  size: 20,
                  color: AppColors.auction,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: AppTextStyles.labelMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Version ${template.version}  |  ${template.direction.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Download
  // ---------------------------------------------------------------------------

  Widget _downloadButton(AuctionTemplate template) {
    return OutlinedButton.icon(
      onPressed: _isDownloading ? null : () => _downloadTemplate(template),
      icon: _isDownloading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.download_outlined, size: 18),
      label: Text(_isDownloading ? 'Downloading...' : 'Download Template'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accentBlue,
        side: const BorderSide(color: AppColors.accentBlue),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),
    );
  }

  Future<void> _downloadTemplate(AuctionTemplate template) async {
    setState(() => _isDownloading = true);
    try {
      // Open the download URL in the browser so the OS handles the file save.
      final url = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}${Endpoints.templateDownload(template.id)}',
      );
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open download link.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Upload
  // ---------------------------------------------------------------------------

  Widget _uploadButton(AuctionTemplate template) {
    return AppButton(
      label: _isUploading ? 'Uploading...' : 'Upload Completed Template',
      isLoading: _isUploading,
      onPressed: _isUploading ? null : () => _uploadTemplate(template),
    );
  }

  Future<void> _uploadTemplate(AuctionTemplate template) async {
    final picked = await AppFilePicker.pickDocument(
      allowedExtensions: ['xlsx', 'xls', 'csv'],
    );
    if (picked == null || picked.path == null) return;

    setState(() {
      _isUploading = true;
      _uploadResult = null;
    });

    try {
      final result = await _templateService.uploadTemplate(
        auctionCode: widget.auctionCode,
        templateId: template.id,
        filePath: picked.path!,
        fileName: picked.name,
      );
      setState(() => _uploadResult = result);
      ref.read(templateUploadResultProvider.notifier).state = result;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Validation results
  // ---------------------------------------------------------------------------

  Widget _validationSection() {
    final result = _uploadResult!;
    final isValid = result.valid;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isValid ? AppColors.successLight : AppColors.destructiveLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isValid ? AppColors.success : AppColors.destructive,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isValid ? Icons.check_circle : Icons.error_outline,
                size: 20,
                color: isValid ? AppColors.success : AppColors.destructive,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isValid
                      ? 'Validation Passed'
                      : 'Validation Failed (${result.errors.length} error${result.errors.length == 1 ? '' : 's'})',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isValid ? AppColors.success : AppColors.destructive,
                  ),
                ),
              ),
            ],
          ),
          if (isValid) ...[
            const SizedBox(height: 10),
            _summaryRow('Rows', '${result.rowCount}'),
            _summaryRow('Total Quantity', '${result.totalQuantity}'),
            _summaryRow(
              'Total Reference Value',
              'Rs ${result.totalReferenceValue.toStringAsFixed(2)}',
            ),
          ],
          if (!isValid) ...[
            const SizedBox(height: 10),
            ...result.errors.map((err) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(
                          color: AppColors.destructive,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Row ${err['row'] ?? '?'}, Col ${err['column'] ?? '?'}: ${err['message'] ?? 'Unknown error'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.navy,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Preview
  // ---------------------------------------------------------------------------

  Widget _previewSection() {
    final rows = _uploadResult!.rows;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Import Preview (${rows.length} item${rows.length == 1 ? '' : 's'})',
          style: AppTextStyles.labelMedium,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rows.length > 20 ? 20 : rows.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: AppColors.cardBorder),
              itemBuilder: (_, i) {
                final row = rows[i];
                final name = row['material_name'] ??
                    row['name'] ??
                    row['item'] ??
                    'Item ${i + 1}';
                final qty = row['quantity'] ?? '';
                final uom = row['uom'] ?? '';
                final ref = row['reference_value'] ?? row['reserve_price'] ?? '';
                return ListTile(
                  dense: true,
                  title: Text(
                    name.toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
                  ),
                  subtitle: Text(
                    'Qty: $qty $uom   Ref: Rs $ref',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.auction.withValues(alpha: 0.1),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.auction,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (rows.length > 20) ...[
          const SizedBox(height: 6),
          Text(
            '+ ${rows.length - 20} more items not shown',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Confirm
  // ---------------------------------------------------------------------------

  Widget _confirmButton() {
    return AppButton(
      label: _isConfirming ? 'Confirming...' : 'Confirm Import',
      isLoading: _isConfirming,
      onPressed: _isConfirming ? null : _confirmImport,
    );
  }

  Future<void> _confirmImport() async {
    final uploadId = _uploadResult?.uploadId;
    if (uploadId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No upload to confirm.')),
      );
      return;
    }

    setState(() => _isConfirming = true);
    try {
      await _templateService.confirmUpload(
        auctionCode: widget.auctionCode,
        uploadId: uploadId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Template import confirmed successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop(true); // pop with success flag
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Confirm failed: $e'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }
}
