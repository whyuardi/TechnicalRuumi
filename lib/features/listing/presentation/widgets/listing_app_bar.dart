// lib/features/listing/presentation/widgets/listing_app_bar.dart
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class ListingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBack;
  final VoidCallback? onClose;
  final bool showBack;

  const ListingAppBar({
    super.key,
    this.onBack,
    this.onClose,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Text(
        'Create a listing',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              color: AppColors.textPrimary,
              onPressed: onBack,
            )
          : null,
      actions: [
        if (onClose != null)
          IconButton(
            icon: const Icon(Icons.close, size: 22),
            color: AppColors.textPrimary,
            onPressed: onClose,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
