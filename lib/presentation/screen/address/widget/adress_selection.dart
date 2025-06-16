import 'package:WashAm/data/models/user_address.dart';
import 'package:WashAm/presentation/screen/address/widget/address_chip.dart';
import 'package:WashAm/presentation/screen/homepage/widget/bottom_action_bar.dart';
import 'package:WashAm/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:get/get.dart'; // For navigation and snackbars

class AddressSelectionScreen extends StatefulWidget {
  // Change initialAddress to the new Address model for editing
  final Address? initialAddress;

  const AddressSelectionScreen({super.key, this.initialAddress});

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _newLabelController = TextEditingController();
  final FocusNode _addressFocusNode = FocusNode();

  String _selectedLabel = 'Home'; // Default selected label
  List<String> _addressLabels = ['Home', 'Work', 'Other']; // Default labels

  // Dummy suggestions for the Google Places-like input
  List<String> _addressSuggestions = [];
  final List<String> _dummyAllAddresses = [
    'Apt 4B, 123 Main St, Osu, Accra',
    'Ghana Post Office, Independence Ave, Accra',
    'Accra Mall, Spintex Rd, Accra',
    'Kwame Nkrumah Circle, Accra',
    'University of Ghana, Legon, Accra',
    'Labadi Beach Hotel, Labadi Rd, Accra',
    'Kotoka International Airport, Accra',
    'Embassy of the United States, Accra',
    'Independence Square, Accra',
    'National Theatre, Accra'
  ];

  // In a real app, this would come from Google Places API or similar
  String? _selectedPlaceId; // To store the placeId obtained from a suggestion

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null) {
      // When editing an existing address
      // Assuming 'fullAddress' is a conceptual concatenation for display
      // In a real app, you'd populate individual fields (street, city, etc.)
      // or directly use a 'fullAddress' if your Address model supported it.
      // For now, I'll use a placeholder/concatenation for _addressController.
      // The actual placeId will be from initialAddress.
      _addressController.text = _buildFullAddress(widget.initialAddress!);
      _descriptionController.text = widget.initialAddress!.description ?? '';
      _selectedLabel = widget.initialAddress!.label;
      _selectedPlaceId = widget.initialAddress!.placeId; // Crucial for update

      // Add the initial address's label if it's custom
      if (!_addressLabels.contains(_selectedLabel)) {
        _addressLabels.add(_selectedLabel);
      }
    }
  }

  // Helper to build a displayable full address from the granular fields
  String _buildFullAddress(Address address) {
    List<String> parts = [];
    if (address.street != null && address.street!.isNotEmpty)
      parts.add(address.street!);
    if (address.city != null && address.city!.isNotEmpty)
      parts.add(address.city!);
    if (address.state != null && address.state!.isNotEmpty)
      parts.add(address.state!);
    if (address.country != null && address.country!.isNotEmpty)
      parts.add(address.country!);
    return parts.join(', ');
  }

  @override
  void dispose() {
    _addressController.dispose();
    _descriptionController.dispose();
    _newLabelController.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  void _onAddressChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _addressSuggestions = [];
        _selectedPlaceId = null; // Clear placeId if input is cleared
      } else {
        // Filter dummy addresses based on query
        _addressSuggestions = _dummyAllAddresses
            .where((address) =>
                address.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _selectSuggestion(String suggestion) {
    _addressController.text = suggestion;
    _addressSuggestions = []; // Clear suggestions after selection
    _addressFocusNode.unfocus(); // Dismiss keyboard
    // In a real app, this is where you'd get the actual placeId from Google Places API
    // For this dummy, we'll generate a consistent 'dummy' placeId for each unique address string
    _selectedPlaceId =
        'dummy_place_id_${suggestion.replaceAll(RegExp(r'\W+'), '_').toLowerCase()}';
  }

  void _saveAddress() {
    if (_addressController.text.isEmpty || _selectedPlaceId == null) {
      Get.snackbar(
        'Address Required',
        'Please enter the full address and select from suggestions.',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
        icon: const Icon(LucideIcons.alertCircle, color: Colors.red),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(20),
        borderRadius: 15,
        animationDuration: const Duration(milliseconds: 300),
      );
      return;
    }

    final String finalPlaceId = _selectedPlaceId!; // Use the selected placeId

    final CreateAddressDto newAddressDto = CreateAddressDto(
      placeId: finalPlaceId,
      label: _selectedLabel,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
    );

    // If editing, you might need a different DTO or approach depending on backend
    // For simplicity, we'll return a CreateAddressDto for both new and edit
    // and let the calling screen decide if it's an update or creation.
    // However, if you're returning an Address object for consistency,
    // you'd need to mock or fetch the full Address details.
    // For now, let's return the CreateAddressDto as the result.
    Get.back(result: newAddressDto); // Return the DTO
  }

  void _addNewLabelDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Add New Label',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryNavy,
          ),
        ),
        content: TextField(
          controller: _newLabelController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g., Office, Vacation Home',
            hintStyle: GoogleFonts.poppins(color: AppColors.lightGreyText),
            filled: true,
            fillColor: AppColors.lightBlueGrey.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primaryNavy, width: 1.5),
            ),
          ),
          style: GoogleFonts.poppins(color: AppColors.darkGreyText),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _newLabelController.clear();
              Get.back();
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.mediumGreyText),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newLabel = _newLabelController.text.trim();
              if (newLabel.isNotEmpty && !_addressLabels.contains(newLabel)) {
                setState(() {
                  _addressLabels.add(newLabel);
                  _selectedLabel = newLabel; // Select the new label
                });
                _newLabelController.clear();
                Get.back();
              } else if (newLabel.isEmpty) {
                Get.snackbar('Input Error', 'Label cannot be empty.',
                    backgroundColor: Colors.red.shade50,
                    colorText: Colors.red.shade800);
              } else if (_addressLabels.contains(newLabel)) {
                Get.snackbar('Input Error', 'Label already exists.',
                    backgroundColor: Colors.orange.shade50,
                    colorText: Colors.orange.shade800);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Add',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
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
          widget.initialAddress != null ? 'Edit Address' : 'Add New Address',
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
            padding: const EdgeInsets.fromLTRB(
                20, 0, 20, 100), // Space for bottom bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Full Address',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreyText,
                  ),
                ),
                const SizedBox(height: 12),
                // Google Places-like Address Input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _addressController,
                        focusNode: _addressFocusNode,
                        onChanged: _onAddressChanged,
                        decoration: InputDecoration(
                          hintText:
                              'Search for address, e.g., 123 Main St, Accra',
                          hintStyle: GoogleFonts.poppins(
                              color: AppColors.lightGreyText),
                          prefixIcon: const Icon(LucideIcons.search,
                              color: AppColors.mediumGreyText),
                          filled: true,
                          fillColor:
                              Colors.transparent, // Handled by parent container
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                                color: AppColors.primaryNavy, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkGreyText,
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      // Address Suggestions
                      if (_addressSuggestions.isNotEmpty &&
                          _addressFocusNode.hasFocus)
                        ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _addressSuggestions.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                ListTile(
                                  leading: const Icon(LucideIcons.mapPin,
                                      size: 20,
                                      color: AppColors.mediumGreyText),
                                  title: Text(
                                    _addressSuggestions[index],
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      color: AppColors.darkGreyText,
                                    ),
                                  ),
                                  onTap: () => _selectSuggestion(
                                      _addressSuggestions[index]),
                                ),
                                if (index < _addressSuggestions.length - 1)
                                  Divider(
                                      height: 1,
                                      color: AppColors.lightBlueGrey
                                          .withOpacity(0.5),
                                      indent: 20,
                                      endIndent: 20),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  'Address Label',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreyText,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 45, // Fixed height for horizontal scroll
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _addressLabels.length + 1, // +1 for "Add New"
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      if (index == _addressLabels.length) {
                        // "Add New" chip
                        return AddressLabelChip(
                          label: 'Add New',
                          isSelected: false,
                          onTap: _addNewLabelDialog,
                        );
                      }
                      final label = _addressLabels[index];
                      return AddressLabelChip(
                        label: label,
                        isSelected: _selectedLabel == label,
                        onTap: () {
                          setState(() {
                            _selectedLabel = label;
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  'Further Details (Optional)',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreyText,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText:
                          'e.g., Apt 4B, Ring the bell twice, Leave at front door',
                      hintStyle:
                          GoogleFonts.poppins(color: AppColors.lightGreyText),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                            color: AppColors.primaryNavy, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkGreyText,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomActionBar(
              buttonText: widget.initialAddress != null
                  ? 'Update Address'
                  : 'Save Address',
              onButtonPressed: _saveAddress,
            ),
          ),
        ],
      ),
    );
  }
}
