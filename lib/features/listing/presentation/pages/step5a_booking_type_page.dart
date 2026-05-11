// lib/features/listing/presentation/pages/step5a_booking_type_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../data/models/listing_model.dart';
import '../../domain/providers/listing_provider.dart';
import '../widgets/listing_step_scaffold.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/next_button.dart';

class Step5aBookingTypePage extends ConsumerWidget {
  const Step5aBookingTypePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(listingFormProvider);

    ref.listen(listingFormProvider.select((s) => s.errorMessage), (prev, next) {
      if (next != null && next.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        ref.read(listingFormProvider.notifier).clearError();
      }
    });

    return LoadingOverlay(
      isLoading: state.isLoading,
      child: ListingStepScaffold(
        currentStep: 9,
        totalSteps: 10,
        onBack: () => ref.read(listingFormProvider.notifier).goToPreviousStep(),
        onClose: () => Navigator.pop(context),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pick your booking settings',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You can change this at any time.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 28),
            _BookingOptionCard(
              type: BookingType.request,
              title: 'Approve your bookings manually',
              subtitle: 'Recommended\nStart by reviewing reservation requests, then switch to Instant Book so guests can book automatically.',
              icon: Icons.calendar_today_outlined,
              isSelected: state.bookingType == BookingType.request,
              badge: 'Recommended',
              onTap: () => ref.read(listingFormProvider.notifier).selectBookingType(BookingType.request),
            ),
            const SizedBox(height: 14),
            _BookingOptionCard(
              type: BookingType.instant,
              title: 'Use Instant Book',
              subtitle: 'Let guests book automatically without requiring your approval.',
              icon: Icons.flash_on_rounded,
              isSelected: state.bookingType == BookingType.instant,
              badge: null,
              onTap: () => ref.read(listingFormProvider.notifier).selectBookingType(BookingType.instant),
            ),
          ],
        ),
        bottomButton: NextButton(
          onPressed: () async {
            await ref.read(listingFormProvider.notifier).saveBookingTypeAndProceed();
          },
          isLoading: state.isLoading,
        ),
      ),
    );
  }
}

class _BookingOptionCard extends StatelessWidget {
  final BookingType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final String? badge;
  final VoidCallback onTap;

  const _BookingOptionCard({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
          color: isSelected ? AppColors.primary.withValues(alpha: 0.04) : AppColors.background,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
