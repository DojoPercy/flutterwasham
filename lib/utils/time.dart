import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum PickupWindow { evening, none } // Simplified to a single window or none

class TimeUtils {
  static PickupWindow getCurrentWindow() {
    final now = DateTime.now();
    final hour = now.hour;

    // Only one pickup window: 7 PM to 10 PM (19:00 to 22:00)
    if (hour >= 19 && hour < 22) {
      return PickupWindow.evening;
    } else {
      return PickupWindow.none;
    }
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  static Duration timeLeftInCurrentWindow() {
    final now = DateTime.now();
    DateTime end;

    switch (getCurrentWindow()) {
      case PickupWindow.evening:
        // End of the evening window is 10 PM (22:00) today
        end = DateTime(now.year, now.month, now.day, 22);
        break;
      case PickupWindow.none:
      default:
        return Duration.zero; // No active window, so no time left
    }

    // Ensure the end time is in the future.
    // If the current time is already past 10 PM, then the window is over.
    if (end.isBefore(now)) {
      return Duration.zero;
    }

    return end.difference(now);
  }

  // New method to check if today's window is completely over
  static bool isWindowOverForToday() {
    final now = DateTime.now();
    // The window ends at 22:00 (10 PM). If current hour is 22 or later, it's over.
    return now.hour >= 22;
  }

  static String formatDuration(Duration duration) {
    if (duration.isNegative || duration == Duration.zero) {
      return "00:00:00"; // Or some other indicator for "over"
    }
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  // Helper to get the next valid window start time if today's is over
  static DateTime? getNextPickupStartTime() {
    final now = DateTime.now();
    DateTime nextPickup;

    // If current time is past 10 PM, next pickup is tomorrow at 7 PM
    if (now.hour >= 22) {
      nextPickup =
          DateTime(now.year, now.month, now.day + 1, 19, 0, 0); // Tomorrow 7 PM
    } else if (now.hour < 19) {
      // If current time is before 7 PM but not in the window, it's today at 7 PM
      nextPickup =
          DateTime(now.year, now.month, now.day, 19, 0, 0); // Today 7 PM
    } else {
      // If we are currently in the window, this function isn't meant to be used.
      return null;
    }
    return nextPickup;
  }
}
