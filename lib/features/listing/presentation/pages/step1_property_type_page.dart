// lib/features/listing/presentation/pages/step1_property_type_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../data/models/property_type_model.dart';
import '../../data/models/listing_model.dart';
import '../../domain/providers/listing_provider.dart';
import '../widgets/listing_step_scaffold.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/next_button.dart';

class Step1PropertyTypePage extends ConsumerStatefulWidget {
  const Step1PropertyTypePage({super.key});

  @override
  ConsumerState<Step1PropertyTypePage> createState() => _Step1PropertyTypePageState();
}

class _Step1PropertyTypePageState extends ConsumerState<Step1PropertyTypePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(listingFormProvider.notifier).loadPropertyTypes();
    });
  }

  IconData _iconForType(String name) {
    final n = name.toLowerCase();
    if (n.contains('house')) return Icons.house_outlined;
    if (n.contains('villa')) return Icons.villa_outlined;
    if (n.contains('condo')) return Icons.apartment_outlined;
    if (n.contains('townhouse')) return Icons.home_outlined;
    if (n.contains('apartment')) return Icons.domain_outlined;
    if (n.contains('land')) return Icons.landscape_outlined;
    if (n.contains('shop')) return Icons.storefront_outlined;
    if (n.contains('retail')) return Icons.store_outlined;
    if (n.contains('office')) return Icons.business_outlined;
    if (n.contains('hotel')) return Icons.hotel_outlined;
    if (n.contains('warehouse')) return Icons.warehouse_outlined;
    return Icons.home_work_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(listingFormProvider);

    // Show error snackbar
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
        currentStep: 1,
        totalSteps: 10,
        showBack: false,
        onClose: () => Navigator.pop(context),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How would you describe your property?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 24),
            if (state.propertyTypes.isEmpty && !state.isLoading)
              _buildRetryWidget()
            else
              _buildPropertyTypeGrid(state.propertyTypes, state.selectedPropertyType),
            const SizedBox(height: 28),
            const Text(
              'What kind of space?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildSpaceTypeSelector(state.selectedSpaceType),
          ],
        ),
        bottomButton: NextButton(
          onPressed: () async {
            final success = await ref.read(listingFormProvider.notifier).createDraftAndProceed();
            if (!success && context.mounted) {
              // Error already shown via listener
            }
          },
          isLoading: state.isLoading,
          enabled: state.selectedPropertyType != null,
        ),
      ),
    );
  }

  Widget _buildRetryWidget() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.wifi_off, size: 48, color: AppColors.textHint),
          const SizedBox(height: 12),
          const Text('Gagal memuat tipe properti', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => ref.read(listingFormProvider.notifier).loadPropertyTypes(),
            child: const Text('Coba lagi', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyTypeGrid(
    List<PropertyTypeModel> types,
    PropertyTypeModel? selected,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        final isSelected = selected?.id == type.id;
        return GestureDetector(
          onTap: () => ref.read(listingFormProvider.notifier).selectPropertyType(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : AppColors.background,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _iconForType(type.name),
                  size: 28,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(height: 8),
                Text(
                  type.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpaceTypeSelector(SpaceType selected) {
    return Column(
      children: SpaceType.values.map((type) {
        final isSelected = selected == type;
        return GestureDetector(
          onTap: () => ref.read(listingFormProvider.notifier).selectSpaceType(type),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(10),
              color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : AppColors.background,
            ),
            child: Row(
              children: [
                Icon(
                  type == SpaceType.entirePlace
                      ? Icons.home_rounded
                      : type == SpaceType.privateRoom
                          ? Icons.bed_rounded
                          : Icons.people_rounded,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    type.label,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
