// lib/features/listing/presentation/pages/step2_location_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../domain/providers/listing_provider.dart';
import '../widgets/listing_step_scaffold.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/next_button.dart';

class Step2LocationPage extends ConsumerStatefulWidget {
  const Step2LocationPage({super.key});

  @override
  ConsumerState<Step2LocationPage> createState() => _Step2LocationPageState();
}

class _Step2LocationPageState extends ConsumerState<Step2LocationPage> {
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showCoords = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(listingFormProvider);
    _addressCtrl.text = state.addressLine1;
    _cityCtrl.text = state.city;
    _postalCtrl.text = state.postalCode;
    if (state.latitude != null) _latCtrl.text = state.latitude.toString();
    if (state.longitude != null) _lngCtrl.text = state.longitude.toString();
    if (state.latitude != null || state.longitude != null) {
      _showCoords = true;
    }
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _postalCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
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
        currentStep: 2,
        totalSteps: 10,
        onBack: () => ref.read(listingFormProvider.notifier).goToPreviousStep(),
        onClose: () => Navigator.pop(context),
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Where's your place located?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your exact address is only shared with guests after they have a confirmed booking.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 28),
              _buildField(
                label: 'Street address',
                controller: _addressCtrl,
                hint: 'e.g. Jl. Sudirman No. 1',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'City / Town',
                controller: _cityCtrl,
                hint: 'e.g. Jakarta Selatan',
                icon: Icons.location_city_outlined,
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'ZIP Code',
                controller: _postalCtrl,
                hint: 'e.g. 12190',
                icon: Icons.markunread_mailbox_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // Optional coordinates section
              GestureDetector(
                onTap: () => setState(() => _showCoords = !_showCoords),
                child: Row(
                  children: [
                    Icon(
                      _showCoords ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _showCoords ? 'Hide coordinates' : 'Add coordinates (optional)',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (_showCoords) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, size: 14, color: AppColors.info),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Latitude and longitude must both be provided or both left empty.',
                              style: TextStyle(fontSize: 12, color: AppColors.info),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              label: 'Latitude',
                              controller: _latCtrl,
                              hint: '-6.175',
                              icon: Icons.straighten_outlined,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true, signed: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildField(
                              label: 'Longitude',
                              controller: _lngCtrl,
                              hint: '106.827',
                              icon: Icons.straighten_outlined,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true, signed: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        bottomButton: NextButton(
          onPressed: () async {
            double? lat;
            double? lng;

            if (_showCoords && _latCtrl.text.isNotEmpty && _lngCtrl.text.isNotEmpty) {
              lat = double.tryParse(_latCtrl.text);
              lng = double.tryParse(_lngCtrl.text);
              if (lat == null || lng == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Koordinat harus berupa angka yang valid.'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
            } else if (_showCoords && (_latCtrl.text.isNotEmpty || _lngCtrl.text.isNotEmpty)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Latitude dan longitude harus diisi bersama-sama.'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }

            ref.read(listingFormProvider.notifier).updateLocation(
              addressLine1: _addressCtrl.text,
              city: _cityCtrl.text,
              postalCode: _postalCtrl.text,
              latitude: lat,
              longitude: lng,
            );
            await ref.read(listingFormProvider.notifier).saveLocationAndProceed();
          },
          isLoading: state.isLoading,
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
            prefixIcon: Icon(icon, size: 18, color: AppColors.textHint),
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
      ],
    );
  }
}
