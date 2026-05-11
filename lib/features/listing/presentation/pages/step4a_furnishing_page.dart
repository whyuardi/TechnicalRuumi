// lib/features/listing/presentation/pages/step4a_furnishing_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../domain/providers/listing_provider.dart';
import '../widgets/listing_step_scaffold.dart';
import '../widgets/next_button.dart';

class Step4aFurnishingPage extends ConsumerStatefulWidget {
  const Step4aFurnishingPage({super.key});

  @override
  ConsumerState<Step4aFurnishingPage> createState() => _Step4aFurnishingPageState();
}

class _Step4aFurnishingPageState extends ConsumerState<Step4aFurnishingPage> {
  static const _options = ['Unfurnished', 'Partly furnished', 'Fully furnished'];
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = ref.read(listingFormProvider).furnishingType;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(listingFormProvider);

    return ListingStepScaffold(
      currentStep: 4,
      totalSteps: 10,
      onBack: () => ref.read(listingFormProvider.notifier).goToPreviousStep(),
      onClose: () => Navigator.pop(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How is your house available?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enhance your listing with additional information',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          ..._options.map((option) {
            final isSelected = _selected == option;
            return GestureDetector(
              onTap: () => setState(() => _selected = option),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    _RadioCircle(isSelected: isSelected),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
      bottomButton: NextButton(
        onPressed: () {
          ref.read(listingFormProvider.notifier).selectFurnishing(_selected);
          ref.read(listingFormProvider.notifier).saveFurnishingAndProceed();
        },
        isLoading: state.isLoading,
      ),
    );
  }
}

class _RadioCircle extends StatelessWidget {
  final bool isSelected;
  const _RadioCircle({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: 2,
        ),
        color: isSelected ? AppColors.primary : Colors.transparent,
      ),
      child: isSelected
          ? const Icon(Icons.check, size: 12, color: Colors.white)
          : null,
    );
  }
}
