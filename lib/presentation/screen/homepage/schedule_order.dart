import 'package:WashAm/data/models/user_address.dart';
import 'package:WashAm/data/models/washambag.dart';
import 'package:WashAm/presentation/screen/address/widget/adress_selection.dart';
import 'package:WashAm/presentation/screen/homepage/widget/bottom_action_bar.dart';
import 'package:WashAm/presentation/screen/homepage/widget/schedule_card.dart';
import 'package:WashAm/presentation/screen/homepage/widget/service_selection.dart';
import 'package:WashAm/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:get/get.dart'; // Assuming GetX for navigation and state
import 'package:intl/intl.dart'; // For date formatting

class ScheduleOrderScreen extends StatefulWidget {
  const ScheduleOrderScreen({super.key});

  @override
  State<ScheduleOrderScreen> createState() => _ScheduleOrderScreenState();
}

class _ScheduleOrderScreenState extends State<ScheduleOrderScreen> {
  // --- Constants ---
  static const double _nextDayRushCost =
      9.95; // Cost for next-day rush delivery
  static const String _currencySymbol = 'GHS'; // Ghana Cedi symbol

  // Bag types from your provided JSON
  final List<WashAmBag> _washAmBagTypes = [
    WashAmBag(
      id: "6835ae0a385022f56c3f4d35",
      category: "BAG",
      name: "Small Bag",
      description: "Light starch included",
      unitPrice: 20,
      createdAt: DateTime.parse("2025-05-27T12:20:26.000Z"),
      updatedAt: DateTime.parse("2025-05-27T12:20:26.000Z"),
    ),
    WashAmBag(
      id: "6835ae18385022f56c3f4d36",
      category: "BAG",
      name: "Medium Bag",
      description: "Light starch included",
      unitPrice: 40,
      createdAt: DateTime.parse("2025-05-27T12:20:40.544Z"),
      updatedAt: DateTime.parse("2025-05-27T12:20:40.544Z"),
    ),
    WashAmBag(
      id: "6835ae26385022f56c3f4d37",
      category: "BAG",
      name: "Large Bag",
      description: "Light starch included",
      unitPrice: 80,
      createdAt: DateTime.parse("2025-05-27T12:20:54.478Z"),
      updatedAt: DateTime.parse("2025-05-27T12:20:54.478Z"),
    ),
  ];

  // --- State Variables ---
  DateTime _selectedPickupDate = DateTime.now();
  String _selectedPickupTimeSlot = '7 PM - 10 PM';
  String _pickupAddress = 'Apt 4B, 123 Main St, Accra, Ghana';

  DateTime _selectedDeliveryDate = DateTime.now();
  bool _isNextDayRush = false;

  // Service Selection
  bool _washAndFoldAdded = true;
  bool _dryCleaningAdded = false;

  // Estimated Bag Counts (using a Map for flexibility)
  final Map<String, int> _estimatedBagCounts = {
    "Small Bag": 0,
    "Medium Bag": 0,
    "Large Bag": 0,
  };

  @override
  void initState() {
    super.initState();
    _ensureValidPickupDate();
    _calculateDefaultDeliveryDate();
  }

  void _ensureValidPickupDate() {
    final now = DateTime.now();
    DateTime initialDate = DateTime(now.year, now.month, now.day);

    if (now.hour >= 22) {
      initialDate = initialDate.add(const Duration(days: 1));
    }
    _selectedPickupDate = initialDate;
  }

  void _calculateDefaultDeliveryDate() {
    DateTime calculatedDate;
    if (_washAndFoldAdded && _isNextDayRush) {
      calculatedDate = _selectedPickupDate.add(const Duration(days: 1));
    } else {
      calculatedDate = _selectedPickupDate.add(const Duration(days: 2));
    }

    if (_dryCleaningAdded) {
      final dryCleaningMinDate =
          _selectedPickupDate.add(const Duration(days: 2));
      if (calculatedDate.isBefore(dryCleaningMinDate)) {
        calculatedDate = dryCleaningMinDate;
      }
    }

    // Only update if the calculated date is different or if the current date is no longer valid.
    if (!_selectedDeliveryDate.isAtSameMomentAs(calculatedDate) &&
        _selectedDeliveryDate.isBefore(calculatedDate)) {
      _selectedDeliveryDate = calculatedDate;
    } else if (!_washAndFoldAdded && !_dryCleaningAdded) {
      // If no service selected, default to 2 days
      _selectedDeliveryDate = _selectedPickupDate.add(const Duration(days: 2));
    } else if (_selectedDeliveryDate.isBefore(calculatedDate)) {
      _selectedDeliveryDate = calculatedDate;
    }

    setState(() {});
  }

  String _formatPickupDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Tonight, ${DateFormat('MMM d').format(date)}';
    } else if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow, ${DateFormat('MMM d').format(date)}';
    } else {
      return DateFormat('EEE, MMM d, yyyy').format(date);
    }
  }

  String _formatDeliveryDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today, ${DateFormat('MMM d, yyyy').format(date)}';
    } else if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow, ${DateFormat('MMM d, yyyy').format(date)}';
    } else {
      return DateFormat('EEE, MMM d, yyyy').format(date);
    }
  }

  Future<void> _selectPickupDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    DateTime initialDate = _selectedPickupDate;

    DateTime firstPickableDate = DateTime(now.year, now.month, now.day);
    if (now.hour >= 22) {
      firstPickableDate = firstPickableDate.add(const Duration(days: 1));
    }

    if (initialDate.isBefore(firstPickableDate)) {
      initialDate = firstPickableDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstPickableDate,
      lastDate: DateTime(now.year + 1, 12, 31),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryNavy,
              onPrimary: Colors.white,
              onSurface: AppColors.darkGreyText,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryNavy,
                textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
            textTheme: TextTheme(
              bodyLarge: GoogleFonts.poppins(),
              bodyMedium: GoogleFonts.poppins(),
              titleMedium: GoogleFonts.poppins(),
              labelLarge: GoogleFonts.poppins(),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedPickupDate) {
      setState(() {
        _selectedPickupDate = picked;
        _calculateDefaultDeliveryDate();
      });
    }
  }

  Future<void> _selectDeliveryDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    DateTime earliestDeliveryDate;

    if (_washAndFoldAdded && _isNextDayRush) {
      earliestDeliveryDate = _selectedPickupDate.add(const Duration(days: 1));
    } else {
      earliestDeliveryDate = _selectedPickupDate.add(const Duration(days: 2));
    }

    if (_dryCleaningAdded) {
      final dryCleaningMinDate =
          _selectedPickupDate.add(const Duration(days: 2));
      if (earliestDeliveryDate.isBefore(dryCleaningMinDate)) {
        earliestDeliveryDate = dryCleaningMinDate;
      }
    }

    DateTime initialDate = _selectedDeliveryDate;
    if (initialDate.isBefore(earliestDeliveryDate)) {
      initialDate = earliestDeliveryDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: earliestDeliveryDate,
      lastDate: _selectedPickupDate.add(const Duration(days: 7)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryNavy,
              onPrimary: Colors.white,
              onSurface: AppColors.darkGreyText,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryNavy,
                textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
            textTheme: TextTheme(
              bodyLarge: GoogleFonts.poppins(),
              bodyMedium: GoogleFonts.poppins(),
              titleMedium: GoogleFonts.poppins(),
              labelLarge: GoogleFonts.poppins(),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDeliveryDate) {
      setState(() {
        _selectedDeliveryDate = picked;

        if (_washAndFoldAdded &&
            picked.isAtSameMomentAs(
                _selectedPickupDate.add(const Duration(days: 1)))) {
          _isNextDayRush = true;
        } else {
          _isNextDayRush = false;
        }
      });
    }
  }

// --- Assume these exist in the class where showAddressSelectionScreen is called ---
// You would typically have a selected address object stored in your state/controller
  Address? _currentSelectedPickupAddress;
// String _pickupAddress; // This string would ideally be derived from _currentSelectedPickupAddress
// String _currentDescription; // This string would ideally be derived from _currentSelectedPickupAddress
// --- End of assumed class members ---

  void showAddressSelectionScreen() async {
    // The AddressSelectionScreen now returns a CreateAddressDto when an address is saved.
    final CreateAddressDto? resultDto = await Get.to<CreateAddressDto>(
      () => AddressSelectionScreen(
        // Pass the actual Address object for editing.
        // If _currentSelectedPickupAddress is null, it means we're adding a new address.
        initialAddress: _currentSelectedPickupAddress,
      ),
    );

    if (resultDto != null) {
      // A CreateAddressDto was returned, meaning the user saved/updated an address.
      // Now you should send this DTO to your backend API to either:
      // 1. Create a new address (if initialAddress was null).
      // 2. Update an existing address (if initialAddress was provided).

      print("Address saved/updated with DTO: ${resultDto.toJson()}");

      // After a successful API call, you would typically:
      // - Get the full Address object back from the backend response (with its ID, etc.).
      // - Update your local state (_currentSelectedPickupAddress) with this new/updated Address object.
      // - Update any UI elements that display the address (like _pickupAddress string).

      // For demonstration, let's just show a snackbar and simulate updating the label.
      Get.snackbar(
        'Address Saved!',
        'Label: ${resultDto.label}, Description: ${resultDto.description ?? "N/A"}',
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
        icon: const Icon(LucideIcons.checkCircle, color: Colors.green),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(20),
        borderRadius: 15,
        animationDuration: const Duration(milliseconds: 300),
      );

      // Example of how you *might* update your local state.
      // In a real app, this would involve calling a repository/service.
      // This is a simplified, non-persistent update for UI feedback.
      _currentSelectedPickupAddress = Address(
        id: _currentSelectedPickupAddress?.id ??
            'temp_new_id', // Use existing ID or dummy for new
        userId: _currentSelectedPickupAddress?.userId ??
            'current_user_id', // Use existing or dummy user ID
        label: resultDto.label,
        description: resultDto.description,
        placeId: resultDto.placeId,
        // For other fields (street, city, lat, long etc.),
        // you would ideally fetch them from a geocoding service using resultDto.placeId
        // or receive them from your backend after the address is persisted.
        // For now, we'll keep them null or use placeholders.
        street: _currentSelectedPickupAddress?.street,
        city: _currentSelectedPickupAddress?.city,
        state: _currentSelectedPickupAddress?.state,
        postalCode: _currentSelectedPickupAddress?.postalCode,
        country: _currentSelectedPickupAddress?.country,
        latitude: _currentSelectedPickupAddress?.latitude,
        longitude: _currentSelectedPickupAddress?.longitude,
        isPrimary: _currentSelectedPickupAddress?.isPrimary ?? false,
        createdAt: _currentSelectedPickupAddress?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // If you have a separate _pickupAddress string for display:
      // You'd update it based on the _currentSelectedPickupAddress or a new API response.
      // _pickupAddress = _currentSelectedPickupAddress != null ? _currentSelectedPickupAddress!.street ?? 'Unknown Address' : 'Unknown Address';
      // _currentDescription = _currentSelectedPickupAddress?.description ?? '';
    } else {
      print("Address selection cancelled.");
    }
  }

  void _toggleService(String service) {
    setState(() {
      if (service == 'Wash & Fold') {
        _washAndFoldAdded = !_washAndFoldAdded;
        if (!_washAndFoldAdded) {
          _isNextDayRush = false;
        }
      } else if (service == 'Dry Cleaning') {
        _dryCleaningAdded = !_dryCleaningAdded;
      }
      _calculateDefaultDeliveryDate();
    });
  }

  void _toggleNextDayRush(bool? value) {
    if (value != null) {
      setState(() {
        _isNextDayRush = value;
        _calculateDefaultDeliveryDate();
      });
    }
  }

  // Updates the estimated bag count for a specific bag type
  void _updateEstimatedBagCount(String bagName, int count) {
    setState(() {
      _estimatedBagCounts[bagName] = count;
    });
  }

  double _calculateEstimatedCost() {
    double cost = 0.0;

    if (_washAndFoldAdded) {
      cost += 30.0; // Base cost for Wash & Fold
      if (_isNextDayRush) {
        cost += _nextDayRushCost;
      }
    }
    if (_dryCleaningAdded) {
      cost += 50.0; // Base cost for Dry Cleaning
    }

    // Add cost for estimated bags if Wash & Fold is added (bags are usually for W&F)
    if (_washAndFoldAdded) {
      for (var bagType in _washAmBagTypes) {
        cost += (_estimatedBagCounts[bagType.name] ?? 0) * bagType.unitPrice;
      }
    }

    return cost;
  }

  // --- Popup for Bag Types ---
  void _showBagTypesInfo(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lightGreyText,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'WashAm Bag Types & Prices',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 15),
            ..._washAmBagTypes
                .map((bag) => Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(LucideIcons.baggageClaim,
                              color: AppColors.accentGold, size: 30),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bag.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkGreyText,
                                  ),
                                ),
                                Text(
                                  bag.description,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.mediumGreyText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${_currencySymbol} ${bag.unitPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
            const SizedBox(height: 10),
            Text(
              'Prices are per bag. We\'ll provide you with complimentary WashAm bags on pickup!',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: AppColors.mediumGreyText,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  'Got It!',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhiteBackground,
      appBar: AppBar(
        backgroundColor: AppColors.offWhiteBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft,
              color: AppColors.primaryNavy, size: 28),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Schedule Your Order',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryNavy,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Pickup Details',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreyText,
                  ),
                ).animate().fade(duration: 500.ms),
                const SizedBox(height: 16),
                ScheduleCard(
                  icon: LucideIcons.calendar,
                  title: 'PICKUP DATE',
                  subtitle: _formatPickupDate(_selectedPickupDate),
                  actionText: 'Edit',
                  onEditPressed: () => _selectPickupDate(context),
                )
                    .animate()
                    .slideX(begin: -0.1, duration: 600.ms, delay: 100.ms)
                    .fade(duration: 600.ms, delay: 100.ms),
                const SizedBox(height: 16),
                ScheduleCard(
                  icon: LucideIcons.clock,
                  title: 'TIME SLOT',
                  subtitle: _selectedPickupTimeSlot,
                  actionText: 'Details',
                  onEditPressed: () {
                    Get.snackbar(
                      'Pickup Window',
                      'All pickups are between 7 PM and 10 PM. You\'ll receive a 30-minute arrival window notification.',
                      backgroundColor: Colors.white,
                      colorText: AppColors.darkGreyText,
                      icon: const Icon(LucideIcons.info,
                          color: AppColors.primaryNavy),
                      snackPosition: SnackPosition.TOP,
                      margin: const EdgeInsets.all(20),
                      borderRadius: 15,
                      animationDuration: const Duration(milliseconds: 300),
                    );
                  },
                )
                    .animate()
                    .slideX(begin: 0.1, duration: 600.ms, delay: 200.ms)
                    .fade(duration: 600.ms, delay: 200.ms),
                const SizedBox(height: 16),
                ScheduleCard(
                  icon: LucideIcons.mapPin,
                  title: 'PICKUP ADDRESS',
                  subtitle: _pickupAddress,
                  actionText: 'Change',
                  onEditPressed: showAddressSelectionScreen,
                )
                    .animate()
                    .slideX(begin: -0.1, duration: 600.ms, delay: 300.ms)
                    .fade(duration: 600.ms, delay: 300.ms),

                const SizedBox(height: 32),
                Text(
                  'Choose Your Services',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreyText,
                  ),
                ).animate().fade(duration: 500.ms, delay: 400.ms),
                const SizedBox(height: 16),
                ServiceSelectionCard(
                  icon: LucideIcons.shirt,
                  serviceName: 'Wash & Fold',
                  isAdded: _washAndFoldAdded,
                  onAddRemovePressed: () => _toggleService('Wash & Fold'),
                )
                    .animate()
                    .slideX(begin: 0.1, duration: 600.ms, delay: 500.ms)
                    .fade(duration: 600.ms, delay: 500.ms),
                if (_washAndFoldAdded) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Next-Day Rush Delivery',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.darkGreyText,
                            ),
                          ),
                        ),
                        Text(
                          '+$_currencySymbol${_nextDayRushCost.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: _isNextDayRush,
                          onChanged: _toggleNextDayRush,
                          activeColor: AppColors.primaryNavy,
                          inactiveThumbColor: AppColors.lightGreyText,
                          inactiveTrackColor: AppColors.lightBlueGrey,
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .slideY(begin: 0.1, duration: 400.ms, delay: 600.ms)
                      .fade(duration: 400.ms, delay: 600.ms),
                ],
                const SizedBox(height: 16),
                ServiceSelectionCard(
                  icon: LucideIcons.handMetal,
                  serviceName: 'Dry Cleaning',
                  priceOrTag: 'Standard Delivery Only',
                  isAdded: _dryCleaningAdded,
                  onAddRemovePressed: () => _toggleService('Dry Cleaning'),
                )
                    .animate()
                    .slideX(begin: -0.1, duration: 600.ms, delay: 700.ms)
                    .fade(duration: 600.ms, delay: 700.ms),

                // --- Estimated WashAm Bags Section ---
                if (_washAndFoldAdded) ...[
                  // Only show if Wash & Fold is selected
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Estimated WashAm Bags',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreyText,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.info,
                            color: AppColors.mediumGreyText, size: 24),
                        onPressed: () => _showBagTypesInfo(context),
                        tooltip: 'Learn about WashAm bag types',
                      ),
                    ],
                  ).animate().fade(duration: 500.ms, delay: 800.ms),
                  const SizedBox(height: 16),
                  // Loop through bag types to create estimation fields
                  ..._washAmBagTypes
                      .map((bagType) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${bagType.name} (${_currencySymbol}${bagType.unitPrice.toStringAsFixed(2)}/bag)',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.darkGreyText,
                                          ),
                                        ),
                                        Text(
                                          bagType.description,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: AppColors.mediumGreyText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildQuantityStepper(bagType.name),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ],

                const SizedBox(height: 32),
                Text(
                  'Delivery Details',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreyText,
                  ),
                )
                    .animate()
                    .fade(duration: 500.ms, delay: 1300.ms), // Adjust delay
                const SizedBox(height: 16),
                ScheduleCard(
                  icon: LucideIcons.truck,
                  title: 'DELIVERY DATE',
                  subtitle: _formatDeliveryDate(_selectedDeliveryDate),
                  actionText: 'Edit',
                  onEditPressed: () => _selectDeliveryDate(context),
                  trailingWidget: Text(
                    _isNextDayRush && _washAndFoldAdded
                        ? 'NEXT-DAY'
                        : 'STANDARD',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: (_isNextDayRush && _washAndFoldAdded)
                          ? AppColors.primaryNavy
                          : AppColors.mediumGreyText,
                    ),
                  ),
                )
                    .animate()
                    .slideX(begin: 0.1, duration: 600.ms, delay: 1400.ms)
                    .fade(duration: 600.ms, delay: 1400.ms),

                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                        color: AppColors.successGreen.withOpacity(0.3),
                        width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.checkCircle,
                          color: AppColors.successGreenDark, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your $_currencySymbol 20.00 first-order credit will be automatically applied!',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.successGreenDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fade(duration: 600.ms, delay: 1500.ms),

                const SizedBox(height: 24),
                _buildInfoRow(
                    LucideIcons.refreshCcw, 'Reschedule or cancel anytime.',
                    delay: 1600.ms),
                const SizedBox(height: 12),
                _buildInfoRow(LucideIcons.award, 'Satisfaction guaranteed.',
                    delay: 1700.ms),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomActionBar(
              buttonText: 'Schedule My Order',
              onButtonPressed: () {},
              infoText:
                  'Total Estimated Cost: $_currencySymbol${_calculateEstimatedCost().toStringAsFixed(2)}',
            ),
          ),
        ],
      ),
    );
  }

  // Custom Quantity Stepper Widget
  Widget _buildQuantityStepper(String bagName) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if ((_estimatedBagCounts[bagName] ?? 0) > 0) {
              _updateEstimatedBagCount(
                  bagName, (_estimatedBagCounts[bagName] ?? 0) - 1);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.lightBlueGrey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(LucideIcons.minus,
                size: 20, color: AppColors.primaryNavy),
          ),
        ),
        SizedBox(
          width: 40,
          child: Center(
            child: Text(
              '${_estimatedBagCounts[bagName] ?? 0}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreyText,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            _updateEstimatedBagCount(
                bagName, (_estimatedBagCounts[bagName] ?? 0) + 1);
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.accentGold,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(LucideIcons.plus,
                size: 20, color: AppColors.darkGoldText),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {required Duration delay}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.mediumGreyText),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: AppColors.mediumGreyText,
              ),
            ),
          ),
        ],
      ).animate().fade(duration: 600.ms, delay: delay),
    );
  }
}
