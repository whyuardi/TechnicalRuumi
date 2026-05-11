// lib/features/listing/presentation/pages/step4e_description_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../domain/providers/listing_provider.dart';
import '../widgets/listing_step_scaffold.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/next_button.dart';

class Step4eDescriptionPage extends ConsumerStatefulWidget {
  const Step4eDescriptionPage({super.key});

  @override
  ConsumerState<Step4eDescriptionPage> createState() => _Step4eDescriptionPageState();
}

class _Step4eDescriptionPageState extends ConsumerState<Step4eDescriptionPage> {
  late TextEditingController _ctrl;
  static const _maxLen = 500;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: ref.read(listingFormProvider).description);
    _ctrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(listingFormProvider);
    final len = _ctrl.text.length;

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
        currentStep: 8,
        totalSteps: 10,
        onBack: () => ref.read(listingFormProvider.notifier).goToPreviousStep(),
        onClose: () => Navigator.pop(context),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create your description for your property.',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Describe the unique qualities that set your location apart.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _ctrl,
              maxLength: _maxLen,
              maxLines: 10,
              minLines: 6,
              onChanged: (v) => ref.read(listingFormProvider.notifier).updateDescription(v),
              style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.5),
              decoration: InputDecoration(
                hintText: 'Describe what makes your property special...',
                hintStyle: const TextStyle(color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.surface,
                counterText: '$len/$_maxLen',
                counterStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
        bottomButton: NextButton(
          onPressed: () async {
            await ref.read(listingFormProvider.notifier).saveDescriptionAndProceed();
          },
          isLoading: state.isLoading,
        ),
      ),
    );
  }
}
