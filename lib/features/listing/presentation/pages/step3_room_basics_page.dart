// lib/features/listing/presentation/pages/step3_room_basics_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../domain/providers/listing_provider.dart';
import '../widgets/counter_field.dart';
import '../widgets/listing_step_scaffold.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/next_button.dart';

class Step3RoomBasicsPage extends ConsumerStatefulWidget {
  const Step3RoomBasicsPage({super.key});

  @override
  ConsumerState<Step3RoomBasicsPage> createState() => _Step3RoomBasicsPageState();
}

class _Step3RoomBasicsPageState extends ConsumerState<Step3RoomBasicsPage> {
  late int _maxGuests;
  late int _bedrooms;
  late int _bathrooms; // stored as int * 2 for halves (e.g., 1.5 = 3)
  late int _propertySize;

  @override
  void initState() {
    super.initState();
    final state = ref.read(listingFormProvider);
    _maxGuests = state.maxGuests;
    _bedrooms = state.bedrooms;
    _bathrooms = (state.bathrooms * 2).round();
    _propertySize = state.propertySize ?? 0;
  }

  @override
  Widget build(BuildContext context) {
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
        currentStep: 3,
        totalSteps: 10,
        onBack: () => ref.read(listingFormProvider.notifier).goToPreviousStep(),
        onClose: () => Navigator.pop(context),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share some basics about your property',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "You'll add more details later, like bed types.",
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 28),
            CounterField(
              label: 'Guest Capacity',
              value: _maxGuests,
              min: 1,
              max: 50,
              onChanged: (v) => setState(() => _maxGuests = v),
            ),
            const Divider(color: AppColors.divider),
            CounterField(
              label: 'Bedrooms',
              value: _bedrooms,
              min: 0,
              max: 20,
              onChanged: (v) => setState(() => _bedrooms = v),
            ),
            const Divider(color: AppColors.divider),
            CounterField(
              label: 'Bathrooms',
              subtitle: 'Can be 1, 1.5, 2, etc.',
              value: _bathrooms,
              min: 1,
              max: 40,
              onChanged: (v) => setState(() => _bathrooms = v),
            ),
            // Show bathroom value
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'Value: ${_bathrooms / 2}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 8),
            const Text(
              'Indoor area (m²)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _propertySize > 0 ? _propertySize.toString() : '',
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _propertySize = int.tryParse(v) ?? 0,
                    decoration: InputDecoration(
                      hintText: '0',
                      suffixText: 'sqft',
                      filled: true,
                      fillColor: AppColors.surface,
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        bottomButton: NextButton(
          onPressed: () {
            ref.read(listingFormProvider.notifier).updateRoomBasics(
              maxGuests: _maxGuests,
              bedrooms: _bedrooms,
              bathrooms: _bathrooms / 2,
              propertySize: _propertySize > 0 ? _propertySize : null,
            );
            ref.read(listingFormProvider.notifier).saveRoomBasicsAndProceed();
          },
          isLoading: state.isLoading,
        ),
      ),
    );
  }
}
