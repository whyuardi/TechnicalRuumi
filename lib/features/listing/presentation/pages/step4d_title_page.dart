// lib/features/listing/presentation/pages/step4d_title_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../domain/providers/listing_provider.dart';
import '../widgets/listing_step_scaffold.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/next_button.dart';

class Step4dTitlePage extends ConsumerStatefulWidget {
  const Step4dTitlePage({super.key});

  @override
  ConsumerState<Step4dTitlePage> createState() => _Step4dTitlePageState();
}

class _Step4dTitlePageState extends ConsumerState<Step4dTitlePage> {
  late TextEditingController _ctrl;
  static const _minLen = 10;
  static const _maxLen = 32;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: ref.read(listingFormProvider).title);
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
    final isValid = len >= _minLen && len <= _maxLen;

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
        currentStep: 7,
        totalSteps: 10,
        onBack: () => ref.read(listingFormProvider.notifier).goToPreviousStep(),
        onClose: () => Navigator.pop(context),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Let's create a title for your property.",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Catchy titles are most effective. Enjoy the process, you can modify it later.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _ctrl,
              maxLength: _maxLen,
              onChanged: (v) => ref.read(listingFormProvider.notifier).updateTitle(v),
              style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. Cozy Studio Near City Center',
                hintStyle: const TextStyle(color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.surface,
                counterText: '$len/$_maxLen',
                counterStyle: TextStyle(
                  color: len > _maxLen ? AppColors.error : AppColors.textSecondary,
                  fontSize: 13,
                ),
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
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),
            if (len > 0 && len < _minLen)
              Text(
                'Minimum $_minLen characters (${_minLen - len} more needed)',
                style: const TextStyle(fontSize: 12, color: AppColors.error),
              ),
          ],
        ),
        bottomButton: NextButton(
          onPressed: () async {
            await ref.read(listingFormProvider.notifier).saveTitleAndProceed();
          },
          isLoading: state.isLoading,
          enabled: isValid,
        ),
      ),
    );
  }
}
