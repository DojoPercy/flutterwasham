import 'package:WashAm/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ServiceSelectionCard extends StatelessWidget {
  final IconData icon;
  final String serviceName;
  final String? priceOrTag; // e.g., "+$9.95" or "Added"
  final bool isAdded;
  final VoidCallback onAddRemovePressed;

  const ServiceSelectionCard({
    super.key,
    required this.icon,
    required this.serviceName,
    this.priceOrTag,
    this.isAdded = false,
    required this.onAddRemovePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.lightBlueGrey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 28, color: AppColors.primaryNavy),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceName,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGreyText,
                  ),
                ),
                if (priceOrTag != null && !isAdded)
                  Text(
                    priceOrTag!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.mediumGreyText,
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAddRemovePressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isAdded ? AppColors.successGreen : AppColors.accentGold,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isAdded ? 'Added' : 'Add',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isAdded ? Colors.white : AppColors.darkGoldText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
