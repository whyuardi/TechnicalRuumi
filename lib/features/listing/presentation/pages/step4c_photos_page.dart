// lib/features/listing/presentation/pages/step4c_photos_page.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../domain/providers/listing_provider.dart';
import '../widgets/listing_step_scaffold.dart';
import '../widgets/next_button.dart';

class Step4cPhotosPage extends ConsumerStatefulWidget {
  const Step4cPhotosPage({super.key});

  @override
  ConsumerState<Step4cPhotosPage> createState() => _Step4cPhotosPageState();
}

class _Step4cPhotosPageState extends ConsumerState<Step4cPhotosPage> {
  final _picker = ImagePicker();
  bool _isPicking = false;

  Future<void> _pickImages() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);
    try {
      final images = await _picker.pickMultiImage(imageQuality: 85);
      if (images.isNotEmpty) {
        for (final img in images) {
          ref.read(listingFormProvider.notifier).addPhoto(img);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not pick images: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _takePhoto() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);
    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (image != null) {
        ref.read(listingFormProvider.notifier).addPhoto(image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not take photo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(listingFormProvider);
    final photos = state.photoFiles;
    final hasEnough = photos.length >= 5;

    return ListingStepScaffold(
      currentStep: 6,
      totalSteps: 10,
      onBack: () => ref.read(listingFormProvider.notifier).goToPreviousStep(),
      onClose: () => Navigator.pop(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add some photos of your property',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              children: [
                TextSpan(text: "You'll need "),
                TextSpan(
                  text: '5 photos',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextSpan(text: ' to get started. You can add more or make changes later.'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Progress indicators
          Row(
            children: List.generate(5, (i) {
              final filled = i < photos.length;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 4,
                  decoration: BoxDecoration(
                    color: filled ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Text(
            '${photos.length} / 5 photos added',
            style: TextStyle(
              fontSize: 12,
              color: hasEnough ? AppColors.success : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),

          // Photo grid
          if (photos.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: photos.length,
              itemBuilder: (context, i) => _PhotoTile(
                xfile: photos[i],
                isCover: i == 0,
                onRemove: () => ref.read(listingFormProvider.notifier).removePhoto(i),
              ),
            ),

          if (photos.isNotEmpty) const SizedBox(height: 16),

          // Add photos button
          _AddPhotoButton(
            icon: Icons.add_photo_alternate_outlined,
            label: '+ Add photos',
            isLoading: _isPicking,
            onTap: _pickImages,
          ),
          const SizedBox(height: 12),
          _AddPhotoButton(
            icon: Icons.camera_alt_outlined,
            label: '📷  Take new photo',
            isLoading: _isPicking,
            onTap: _takePhoto,
          ),

          if (!hasEnough && photos.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFCA28)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Color(0xFFE65100)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Add ${5 - photos.length} more photo${5 - photos.length == 1 ? '' : 's'} to continue.',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF5D4037)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      bottomButton: NextButton(
        label: 'Next',
        onPressed: hasEnough
            ? () => ref.read(listingFormProvider.notifier).savePhotosAndProceed()
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      photos.isEmpty
                          ? 'Please add at least 5 photos to continue.'
                          : 'Add ${5 - photos.length} more photo${5 - photos.length == 1 ? '' : 's'} to continue.',
                    ),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
        isLoading: state.isLoading,
      ),
    );
  }
}

/// Individual photo tile with real image preview via bytes.
class _PhotoTile extends StatelessWidget {
  final XFile xfile;
  final bool isCover;
  final VoidCallback onRemove;

  const _PhotoTile({
    required this.xfile,
    required this.isCover,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: FutureBuilder<Uint8List>(
            future: xfile.readAsBytes(),
            builder: (context, snap) {
              if (snap.hasData) {
                return Image.memory(
                  snap.data!,
                  fit: BoxFit.cover,
                );
              }
              return Container(
                color: AppColors.surfaceVariant,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              );
            },
          ),
        ),

        // Cover badge
        if (isCover)
          Positioned(
            bottom: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Cover',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        // Remove button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddPhotoButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  const _AddPhotoButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Icon(icon, color: AppColors.textSecondary, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
