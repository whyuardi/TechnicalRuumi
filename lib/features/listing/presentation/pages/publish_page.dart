// lib/features/listing/presentation/pages/publish_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../domain/providers/listing_provider.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/next_button.dart';

class PublishPage extends ConsumerStatefulWidget {
  const PublishPage({super.key});

  @override
  ConsumerState<PublishPage> createState() => _PublishPageState();
}

class _PublishPageState extends ConsumerState<PublishPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(listingFormProvider);

    ref.listen(listingFormProvider.select((s) => s.errorMessage), (prev, next) {
      if (next != null && next.isNotEmpty) {
        _showErrorDialog(context, next);
        ref.read(listingFormProvider.notifier).clearError();
      }
    });

    ref.listen(listingFormProvider.select((s) => s.isPublished), (prev, next) {
      if (next == true && context.mounted) {
        _showSuccessDialog(context);
      }
    });

    return LoadingOverlay(
      isLoading: state.isLoading,
      message: 'Finalizing Your Uploads...',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: const Text(
            'Create a listing',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: AppColors.textPrimary),
            onPressed: () =>
                ref.read(listingFormProvider.notifier).goToPreviousStep(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).padding.bottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Animated building illustration
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.1),
                        AppColors.primaryLight.withValues(alpha: 0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.apartment_rounded,
                    size: 90,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Finalizing Your Uploads...',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please stay on this screen while we prepare your property files for the listing.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Summary card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _SummaryRow(
                      icon: Icons.home_work_outlined,
                      label: 'Property',
                      value: state.selectedPropertyType?.name ?? 'Not set',
                    ),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: state.city.isEmpty ? 'Not set' : state.city,
                    ),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      icon: Icons.title_rounded,
                      label: 'Title',
                      value: state.title.isEmpty ? 'Not set' : state.title,
                    ),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      icon: Icons.payments_outlined,
                      label: 'Price',
                      value: state.basePrice != null
                          ? 'RM ${state.basePrice!.toStringAsFixed(0)}/mo'
                          : 'Not set',
                    ),
                  ],
                ),
              ),

              // Coordinates warning banner
              if (state.latitude == null || state.longitude == null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.fromBorderSide(
                      BorderSide(color: Color(0xFFFFCA28)),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 18, color: Color(0xFFE65100)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Coordinates (latitude & longitude) are required to publish. '
                          'Go back to Step 2 to add them.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5D4037),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline,
                      size: 14, color: AppColors.textHint),
                  SizedBox(width: 6),
                  Text(
                    'We handle all data per our privacy policy',
                    style: TextStyle(fontSize: 12, color: AppColors.textHint),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              NextButton(
                label: 'Create listing',
                onPressed: () async {
                  await ref
                      .read(listingFormProvider.notifier)
                      .publishListing();
                },
                isLoading: state.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    final notifier = ref.read(listingFormProvider.notifier);
    final needsCoords = message.contains('Latitude and longitude');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, color: AppColors.error),
            ),
            const SizedBox(width: 12),
            const Text(
              'Cannot Publish',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5),
        ),
        actions: [
          if (needsCoords)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                notifier.navigateToStep(2);
              },
              child: const Text(
                'Go to Step 2',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: AppColors.success, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Listing Published! 🎉',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your property listing is now live and visible to potential guests.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  // ✅ FIX: Reset state sebelum kembali ke home
                  ref.read(listingFormProvider.notifier).startFresh();
                  Navigator.of(context)
                      .popUntil((route) => route.isFirst);
                },
                child: const Text('Back to Listings',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(
              fontSize: 13, color: AppColors.textSecondary),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}