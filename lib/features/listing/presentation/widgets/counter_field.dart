// lib/features/listing/presentation/widgets/counter_field.dart
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class CounterField extends StatelessWidget {
  final String label;
  final String? subtitle;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const CounterField({
    super.key,
    required this.label,
    this.subtitle,
    required this.value,
    this.min = 0,
    this.max = 99,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              _StepButton(
                icon: Icons.remove,
                onPressed: value > min ? () => onChanged(value - 1) : null,
              ),
              SizedBox(
                width: 36,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _StepButton(
                icon: Icons.add,
                onPressed: value < max ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _StepButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isEnabled ? AppColors.textPrimary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isEnabled ? AppColors.textPrimary : AppColors.border,
        ),
      ),
    );
  }
}
