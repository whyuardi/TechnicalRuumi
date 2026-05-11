// lib/features/listing/presentation/widgets/listing_step_scaffold.dart
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import 'listing_app_bar.dart';
import 'step_progress_dots.dart';

/// A consistent scaffold for all listing form steps
class ListingStepScaffold extends StatelessWidget {
  final Widget body;
  final Widget bottomButton;
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;
  final VoidCallback? onClose;
  final bool showBack;
  final bool showProgress;

  const ListingStepScaffold({
    super.key,
    required this.body,
    required this.bottomButton,
    required this.currentStep,
    this.totalSteps = 10,
    this.onBack,
    this.onClose,
    this.showBack = true,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ListingAppBar(
        onBack: showBack ? onBack : null,
        onClose: onClose,
        showBack: showBack,
      ),
      body: Column(
        children: [
          if (showProgress) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: StepProgressDots(
                totalSteps: totalSteps,
                currentStep: currentStep,
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
          ],
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: body,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            child: bottomButton,
          ),
        ],
      ),
    );
  }
}
