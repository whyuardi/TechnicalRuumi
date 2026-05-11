// lib/features/listing/presentation/pages/step5b_price_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../domain/providers/listing_provider.dart';
import '../widgets/listing_step_scaffold.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/next_button.dart';

class Step5bPricePage extends ConsumerStatefulWidget {
  const Step5bPricePage({super.key});

  @override
  ConsumerState<Step5bPricePage> createState() => _Step5bPricePageState();
}

class _Step5bPricePageState extends ConsumerState<Step5bPricePage> {
  final _priceCtrl = TextEditingController();
  bool _showBreakdown = false;

  @override
  void initState() {
    super.initState();
    final price = ref.read(listingFormProvider).basePrice;
    if (price != null) _priceCtrl.text = price.toStringAsFixed(0);
    _priceCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  double? get _price => double.tryParse(_priceCtrl.text.replaceAll(',', ''));
  bool get _isValid => _price != null && _price! > 0;

  double get _guestServiceFee => (_price ?? 0) * 0.075;
  double get _taxes => (_price ?? 0) * 0.10;
  double get _guestPrice => (_price ?? 0) + _guestServiceFee + _taxes;
  double get _hostServiceFee => (_price ?? 0) * 0.03;
  double get _youEarn => (_price ?? 0) - _hostServiceFee;

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
        currentStep: 10,
        totalSteps: 10,
        onBack: () => ref.read(listingFormProvider.notifier).goToPreviousStep(),
        onClose: () => Navigator.pop(context),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Now, set the base price for property rent',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You can change this at any time.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 40),

            // Big price display
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text(
                        'RM',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      IntrinsicWidth(
                        child: TextField(
                          controller: _priceCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                            hintStyle: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDisabled,
                            ),
                            isCollapsed: true,
                          ),
                        ),
                      ),
                      const Text(
                        ' /mo',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                    ],
                  ),
                  if (_isValid) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Guest price RM${_guestPrice.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            if (_isValid) ...[
              // Price breakdown toggle
              GestureDetector(
                onTap: () => setState(() => _showBreakdown = !_showBreakdown),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _showBreakdown ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.primary,
                    ),
                    Text(
                      _showBreakdown ? 'Show less' : 'Show breakdown',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (_showBreakdown) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _PriceRow('Base price', 'RM${_price!.toStringAsFixed(0)}'),
                      _PriceRow('Guest service fee', 'RM${_guestServiceFee.toStringAsFixed(0)}'),
                      _PriceRow('Taxes', 'RM${_taxes.toStringAsFixed(0)}'),
                      const Divider(color: AppColors.divider),
                      _PriceRow('Guest price', 'RM${_guestPrice.toStringAsFixed(0)}', bold: true),
                      const SizedBox(height: 12),
                      _PriceRow('Base price', 'RM${_price!.toStringAsFixed(0)}'),
                      _PriceRow('Host service fee', '-RM${_hostServiceFee.toStringAsFixed(0)}',
                          valueColor: AppColors.error),
                      const Divider(color: AppColors.divider),
                      _PriceRow('You earn', 'RM${_youEarn.toStringAsFixed(0)}',
                          bold: true, valueColor: AppColors.success),
                    ],
                  ),
                ),
              ],
            ],

            const SizedBox(height: 20),
            if (!_isValid && _priceCtrl.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Price must be greater than 0',
                      style: TextStyle(color: AppColors.error, fontSize: 13),
                    ),
                  ],
                ),
              ),
          ],
        ),
        bottomButton: NextButton(
          label: 'Next',
          onPressed: () async {
            ref.read(listingFormProvider.notifier).updateBasePrice(_price);
            await ref.read(listingFormProvider.notifier).savePriceAndProceed();
          },
          isLoading: state.isLoading,
          enabled: _isValid,
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _PriceRow(this.label, this.value, {this.bold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
