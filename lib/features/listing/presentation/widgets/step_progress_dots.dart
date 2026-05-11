// lib/features/listing/presentation/widgets/step_progress_dots.dart
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class StepProgressDots extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const StepProgressDots({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index < currentStep;
        final isCurrent = index == currentStep - 1;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isCurrent ? 24 : 8,
          height: 4,
          decoration: BoxDecoration(
            color: isActive ? AppColors.stepActive : AppColors.stepInactive,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
