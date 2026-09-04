import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class PickedAttachment {
  final String name;
  final int sizeInBytes;
  final String? path;
  final String extension;
  final bool isImage;

  const PickedAttachment({
    required this.name,
    required this.sizeInBytes,
    this.path,
    required this.extension,
    required this.isImage,
  });

  String get formattedSize {
    if (sizeInBytes < 1024) return '$sizeInBytes B';
    if (sizeInBytes < 1024 * 1024) return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

enum PickerAction { document, gallery, camera }

class AppFilePicker {
  static final _imagePicker = ImagePicker();

  /// Pick single PDF, Document or Image using system file picker
  static Future<PickedAttachment?> pickDocument({List<String>? allowedExtensions}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions ?? ['pdf', 'png', 'jpg', 'jpeg', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final f = result.files.first;
        final ext = (f.extension ?? f.name.split('.').last).toLowerCase();
        final isImg = ['png', 'jpg', 'jpeg', 'webp'].contains(ext);
        return PickedAttachment(
          name: f.name,
          sizeInBytes: f.size,
          path: f.path,
          extension: ext,
          isImage: isImg,
        );
      }
    } catch (e) {
      debugPrint('Error picking document: $e');
    }
    return null;
  }

  /// Pick image from camera or gallery
  static Future<PickedAttachment?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final xfile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (xfile != null) {
        final file = File(xfile.path);
        final length = await file.length();
        final ext = xfile.name.split('.').last.toLowerCase();
        return PickedAttachment(
          name: xfile.name,
          sizeInBytes: length,
          path: xfile.path,
          extension: ext,
          isImage: true,
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
    return null;
  }

  /// Pick multiple images from gallery
  static Future<List<PickedAttachment>> pickMultiImages() async {
    try {
      final xfiles = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      final List<PickedAttachment> picked = [];
      for (final xf in xfiles) {
        final file = File(xf.path);
        final length = await file.length();
        final ext = xf.name.split('.').last.toLowerCase();
        picked.add(PickedAttachment(
          name: xf.name,
          sizeInBytes: length,
          path: xf.path,
          extension: ext,
          isImage: true,
        ));
      }
      return picked;
    } catch (e) {
      debugPrint('Error picking multi images: $e');
      return [];
    }
  }

  /// Shows an attractive bottom sheet letting the user choose Camera, Gallery or Document file
  static Future<PickedAttachment?> showPickerBottomSheet(
    BuildContext context, {
    String title = 'Upload Document or Photo',
    List<String>? allowedExtensions,
  }) async {
    final action = await showModalBottomSheet<PickerAction>(
      context: context,
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
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.heading(size: 17, weight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text(
              'Select file source for upload (PDF, PNG, JPG supported up to 10MB)',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _pickerOption(
                    icon: Icons.description_outlined,
                    label: 'Browse PDF / Files',
                    color: AppColors.auction,
                    onTap: () => Navigator.of(ctx).pop(PickerAction.document),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _pickerOption(
                    icon: Icons.photo_library_outlined,
                    label: 'Photo Gallery',
                    color: AppColors.accentBlue,
                    onTap: () => Navigator.of(ctx).pop(PickerAction.gallery),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _pickerOption(
                    icon: Icons.camera_alt_outlined,
                    label: 'Take Photo',
                    color: AppColors.navy,
                    onTap: () => Navigator.of(ctx).pop(PickerAction.camera),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (action == null) return null;

    switch (action) {
      case PickerAction.document:
        return await pickDocument(allowedExtensions: allowedExtensions);
      case PickerAction.gallery:
        return await pickImage(source: ImageSource.gallery);
      case PickerAction.camera:
        return await pickImage(source: ImageSource.camera);
    }
  }

  static Widget _pickerOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.white, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
