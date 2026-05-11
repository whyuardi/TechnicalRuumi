// lib/features/listing/presentation/pages/listings_home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../data/models/listing_model.dart';
import '../../domain/providers/listing_provider.dart';
import 'getting_started_page.dart';
import 'listing_flow_page.dart';

class ListingsHomePage extends ConsumerWidget {
  const ListingsHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(listingsProvider);

    // Invalidate & re-fetch + reset state when a new listing is published
    ref.listen(listingFormProvider.select((s) => s.isPublished), (prev, next) {
      if (next == true) {
        ref.invalidate(listingsProvider);
        // ✅ FIX: Reset state supaya listing baru mulai dari awal
        ref.read(listingFormProvider.notifier).startFresh();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Your listings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view_rounded, color: AppColors.textPrimary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.textPrimary, size: 28),
            onPressed: () => _onCreateTapped(context, ref),
          ),
        ],
      ),
      body: listingsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textHint),
              const SizedBox(height: 16),
              const Text(
                'Could not load listings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => ref.invalidate(listingsProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (listings) => listings.isEmpty
            ? _EmptyState(onCreateTapped: () => _onCreateTapped(context, ref))
            : _ListingsList(
                listings: listings,
                onRefresh: () => ref.invalidate(listingsProvider),
              ),
      ),
      bottomNavigationBar: const _BottomNav(),
    );
  }

  void _onCreateTapped(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(listingFormProvider.notifier);

    if (notifier.hasSavedDraft) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Resume Draft?'),
          content: Text(
            'You have an unfinished listing at step ${notifier.savedStep}. '
            'Would you like to continue where you left off?',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // ✅ startFresh sudah benar di sini
                await notifier.startFresh();
                if (context.mounted) _openGettingStarted(context);
              },
              child: const Text('Start Over', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(context);
                notifier.resumeDraft();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ListingFlowPage()),
                );
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    } else {
      _openGettingStarted(context);
    }
  }

  void _openGettingStarted(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GettingStartedPage()),
    );
  }
}

// ─── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateTapped;
  const _EmptyState({required this.onCreateTapped});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.apartment_rounded, size: 80, color: AppColors.primary),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cancel, color: AppColors.primary, size: 22),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No listings yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + to create your first listing',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: onCreateTapped,
            icon: const Icon(Icons.add),
            label: const Text('Create a listing', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─── Listings list ────────────────────────────────────────────────────────────

class _ListingsList extends StatelessWidget {
  final List<ListingModel> listings;
  final VoidCallback onRefresh;

  const _ListingsList({required this.listings, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: listings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _ListingCard(listing: listings[i]),
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final ListingModel listing;
  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final status = listing.status;
    final statusColor = switch (status) {
      ListingStatus.published => AppColors.success,
      ListingStatus.draft => const Color(0xFFFF9800),
      ListingStatus.archived => AppColors.textHint,
    };
    final statusLabel = switch (status) {
      ListingStatus.published => 'Published',
      ListingStatus.draft => 'Draft',
      ListingStatus.archived => 'Archived',
    };

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail placeholder
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.primaryLight.withValues(alpha: 0.25),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.apartment_rounded,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title?.isNotEmpty == true
                      ? listing.title!
                      : 'Untitled listing',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (listing.city?.isNotEmpty == true)
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(
                        listing.city!,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (listing.basePrice != null) ...[
                      Text(
                        'RM ${double.parse(listing.basePrice!).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const Text(
                        '/mo',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ] else
                      const Text(
                        'Price not set',
                        style: TextStyle(fontSize: 13, color: AppColors.textHint),
                      ),
                    const Spacer(),
                    if (listing.bedrooms != null)
                      _InfoChip(icon: Icons.bed_outlined, label: '${listing.bedrooms} bd'),
                    if (listing.maxGuests != null) ...[
                      const SizedBox(width: 6),
                      _InfoChip(icon: Icons.people_outline, label: '${listing.maxGuests}'),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Nav ───────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textHint,
      currentIndex: 2,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.today_outlined), label: 'Today'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Calendar'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: 'Listings'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
        BottomNavigationBarItem(icon: Icon(Icons.menu_rounded), label: 'Menu'),
      ],
    );
  }
}