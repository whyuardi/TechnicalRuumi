// lib/features/listing/presentation/pages/listing_flow_page.dart
// This acts as a router/controller for the multi-step form
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/listing_provider.dart';
import 'step1_property_type_page.dart';
import 'step2_location_page.dart';
import 'step3_room_basics_page.dart';
import 'step4a_furnishing_page.dart';
import 'step4b_amenities_page.dart';
import 'step4c_photos_page.dart';
import 'step4d_title_page.dart';
import 'step4e_description_page.dart';
import 'step5a_booking_type_page.dart';
import 'step5b_price_page.dart';
import 'publish_page.dart';

class ListingFlowPage extends ConsumerWidget {
  const ListingFlowPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(listingFormProvider.select((s) => s.currentStep));

    return switch (step) {
      1  => const Step1PropertyTypePage(),
      2  => const Step2LocationPage(),
      3  => const Step3RoomBasicsPage(),
      4  => const Step4aFurnishingPage(),
      5  => const Step4bAmenitiesPage(),
      6  => const Step4cPhotosPage(),
      7  => const Step4dTitlePage(),
      8  => const Step4eDescriptionPage(),
      9  => const Step5aBookingTypePage(),
      10 => const Step5bPricePage(),
      _  => const PublishPage(),
    };
  }
}
