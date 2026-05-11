// lib/features/listing/presentation/pages/step4b_amenities_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../domain/providers/listing_provider.dart';
import '../widgets/listing_step_scaffold.dart';
import '../widgets/next_button.dart';

class Step4bAmenitiesPage extends ConsumerWidget {
  const Step4bAmenitiesPage({super.key});

  static const _amenities = {
    'Essential Amenities': [
      ('WiFi', Icons.wifi_rounded),
      ('Air Conditioning', Icons.ac_unit_rounded),
      ('Kitchen', Icons.kitchen_rounded),
      ('Dedicated Workspace', Icons.desk_rounded),
      ('TV', Icons.tv_rounded),
    ],
    'Building Facilities': [
      ('Swimming Pool', Icons.pool_rounded),
      ('Gym', Icons.fitness_center_rounded),
      ('Free Parking', Icons.local_parking_rounded),
      ('Elevator', Icons.elevator_rounded),
      ('Security 24/7', Icons.security_rounded),
    ],
    'Safety': [
      ('Smoke Alarm', Icons.smoke_free_rounded),
      ('Fire Extinguisher', Icons.fire_extinguisher_rounded),
      ('Carbon Monoxide Alarm', Icons.warning_amber_rounded),
      ('First Aid Kit', Icons.medical_services_rounded),
    ],
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(listingFormProvider);
    final selected = state.selectedAmenities;

    return ListingStepScaffold(
      currentStep: 5,
      totalSteps: 10,
      onBack: () => ref.read(listingFormProvider.notifier).goToPreviousStep(),
      onClose: () => Navigator.pop(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell guests what your place has to offer',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You can add more amenities after you publish your listing.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ..._amenities.entries.map((entry) {
            return _AmenitySection(
              title: entry.key,
              items: entry.value,
              selected: selected,
              onToggle: (amenity) =>
                  ref.read(listingFormProvider.notifier).toggleAmenity(amenity),
            );
          }),
        ],
      ),
      bottomButton: NextButton(
        onPressed: () => ref.read(listingFormProvider.notifier).saveAmenitiesAndProceed(),
        isLoading: state.isLoading,
      ),
    );
  }
}

class _AmenitySection extends StatefulWidget {
  final String title;
  final List<(String, IconData)> items;
  final List<String> selected;
  final ValueChanged<String> onToggle;

  const _AmenitySection({
    required this.title,
    required this.items,
    required this.selected,
    required this.onToggle,
  });

  @override
  State<_AmenitySection> createState() => _AmenitySectionState();
}

class _AmenitySectionState extends State<_AmenitySection> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final displayItems = _showAll ? widget.items : widget.items.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: displayItems.map((item) {
            final (name, icon) = item;
            final isSelected = widget.selected.contains(name);
            return GestureDetector(
              onTap: () => widget.onToggle(name),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(50),
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.background,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (widget.items.length > 5)
          TextButton(
            onPressed: () => setState(() => _showAll = !_showAll),
            child: Text(
              _showAll ? 'Show less' : 'Show more',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}
