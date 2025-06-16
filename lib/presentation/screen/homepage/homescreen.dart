import 'dart:async';
import 'dart:ui';

import 'package:WashAm/configuration/padding_spacing.dart';
import 'package:WashAm/presentation/common_blocs/auth/auth_bloc.dart';
import 'package:WashAm/presentation/common_blocs/auth/auth_state.dart';
import 'package:WashAm/presentation/screen/login/login_screen.dart';
import 'package:WashAm/routes/app_router.dart';
import 'package:WashAm/routes/app_routes_constants.dart';
import 'package:WashAm/utils/colors.dart';
import 'package:WashAm/utils/time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // This would typically come from a Bloc/Provider/GetX controller
  bool _hasActiveOrder = false; // Example state for active order
  String _currentOrderStatus =
      'Picked up, currently cleaning'; // Example status

  @override
  void initState() {
    super.initState();
    // Simulate checking for an active order
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _hasActiveOrder = true; // Set to true to show the status card
        });
      }
    });
  }

  void _showAccountStatsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.45, // Slightly larger initial size
          minChildSize: 0.2,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95), // More opaque white
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Container(
                          width: 60,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          children: [
                            Text(
                              'Account Overview',
                              style: GoogleFonts.poppins(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryNavy,
                              ),
                            ).animate().fade(duration: 500.ms),
                            const SizedBox(height: 24),
                            AccountStatTile(
                                icon: LucideIcons.shoppingBag,
                                label: 'Orders',
                                value: '3 completed'),
                            AccountStatTile(
                                icon: LucideIcons.wallet,
                                label: 'Credits',
                                value: 'GHS 20.00 available'),
                            AccountStatTile(
                                icon: LucideIcons.award,
                                label: 'Loyalty Level',
                                value: 'Silver Tier'),
                            const SizedBox(height: 30),
                            Text(
                              'More detailed analytics and loyalty benefits are coming soon to enhance your WashAm experience!',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: AppColors.mediumGreyText,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ).animate().fade(delay: 200.ms, duration: 600.ms),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.offWhiteBackground,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 1000));
            // Simulate refreshing order status or data
            if (mounted) {
              setState(() {
                _hasActiveOrder = !_hasActiveOrder; // Toggle for demo
                _currentOrderStatus = _hasActiveOrder
                    ? 'Processing at facility'
                    : 'No active order';
              });
            }
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                backgroundColor: AppColors.offWhiteBackground,
                elevation: 0,
                floating: true,
                toolbarHeight: 80,
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.lightBlueGrey,
                          child: Icon(
                            LucideIcons.menu,
                            color: AppColors.primaryNavy,
                            size: 24,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Using a different logo for potentially darker background top bar
                      Image.asset('assets/images/logo (2).png', height: 70),
                      const Spacer(),
                      GestureDetector(
                        onTap: _showAccountStatsSheet,
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.lightBlueGrey,
                          child: Icon(
                            LucideIcons.barChart2,
                            color: AppColors.primaryNavy,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20), // Increased padding
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      const SizedBox(height: 24),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          String? firstName;
                          if (state is AuthSuccessWithProfile) {
                            firstName = state.userProfile.firstName;
                          }
                          return GreetingSection(firstName: firstName)
                              .animate()
                              .fade(duration: 600.ms);
                        },
                      ),
                      const OrderNowHeroCard()
                          .animate()
                          .slideY(begin: 0.1, duration: 600.ms, delay: 100.ms)
                          .fade(duration: 600.ms, delay: 100.ms),
                      const SizedBox(height: 24),
                      const AddressSectionCard()
                          .animate()
                          .slideY(begin: 0.1, duration: 600.ms, delay: 200.ms)
                          .fade(duration: 600.ms, delay: 200.ms),
                      if (_hasActiveOrder) ...[
                        const SizedBox(height: 24),
                        LaundryStatusCard(status: _currentOrderStatus)
                            .animate()
                            .slideY(begin: 0.1, duration: 600.ms, delay: 300.ms)
                            .fade(duration: 600.ms, delay: 300.ms),
                      ],
                      const SizedBox(height: 24),
                      const MyCreditsAndReferralCard()
                          .animate()
                          .slideY(begin: 0.1, duration: 600.ms, delay: 400.ms)
                          .fade(duration: 600.ms, delay: 400.ms),
                      const SizedBox(height: 24),
                      const FirstTimeInfoCard()
                          .animate()
                          .fade(duration: 600.ms, delay: 500.ms)
                          .slideY(begin: 0.05, duration: 600.ms, delay: 500.ms),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Reusable Widgets ---

class AccountStatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const AccountStatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.lightBlueGrey,
            child: Icon(icon, color: AppColors.primaryNavy, size: 22),
          ).animate().scaleXY(duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mediumGreyText,
                ),
              ).animate().fade(duration: 600.ms, delay: 100.ms),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreyText,
                ),
              ).animate().fade(duration: 600.ms, delay: 200.ms),
            ],
          ),
        ],
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: Spacing.widthPercentage80(context), // Assuming Spacing exists
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryNavy, AppColors.darkNavy],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.accentGold,
                        child: Icon(LucideIcons.user,
                            size: 40, color: AppColors.darkGoldText),
                      ).animate().scale(duration: 500.ms),
                      const SizedBox(height: 16),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          String userName = 'Hi, User!';
                          if (state is AuthSuccessWithProfile) {
                            userName = 'Hi, ${state.userProfile.firstName}!';
                          }
                          return Text(
                            userName,
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ).animate().fade(duration: 600.ms, delay: 100.ms);
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ready for clean laundry?',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.white70,
                        ),
                      ).animate().fade(duration: 600.ms, delay: 200.ms),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),
                _DrawerItem(
                    icon: LucideIcons.user,
                    label: 'My Profile',
                    onTap: () {
                      AppRouter()
                          .push(context, ApplicationRoutesConstants.profile);
                    },
                    delay: 300.ms),
                _DrawerItem(
                    icon: LucideIcons.luggage,
                    label: 'Services & Pricing',
                    onTap: () {},
                    delay: 350.ms),
                _DrawerItem(
                    icon: LucideIcons.shoppingBag,
                    label: 'WashAm Repeat',
                    onTap: () {},
                    delay: 400.ms),
                _DrawerItem(
                    icon: LucideIcons.slidersHorizontal,
                    label: 'Preferences',
                    onTap: () {},
                    delay: 450.ms),
                _DrawerItem(
                    icon: LucideIcons.clock,
                    label: 'Order History',
                    onTap: () {},
                    delay: 500.ms),
                _DrawerItem(
                    icon: LucideIcons.helpCircle,
                    label: 'Help & Support',
                    onTap: () {},
                    delay: 550.ms),
                const Spacer(),
                // Removed the embedded referral card here to consolidate to main screen
                _DrawerItem(
                    icon: LucideIcons.logOut,
                    label: 'Log Out',
                    onTap: () {},
                    textColor: Colors.redAccent,
                    iconColor: Colors.redAccent,
                    delay: 650.ms),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color textColor;
  final Color iconColor;
  final Duration delay;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.textColor = Colors.white,
    this.iconColor = Colors.white,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 24, color: iconColor)
          .animate()
          .fade(duration: 500.ms, delay: delay)
          .slideX(begin: -0.2, duration: 500.ms, delay: delay),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ).animate().fade(duration: 500.ms, delay: delay + 100.ms),
      onTap: () {
        Navigator.pop(context); // Close drawer first
        onTap(); // Then execute action
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}

class GreetingSection extends StatelessWidget {
  final String? firstName; // Make firstName nullable

  const GreetingSection({super.key, this.firstName});

  @override
  Widget build(BuildContext context) {
    final greeting = TimeUtils.getGreeting(); // Assuming TimeUtils exists
    final displayFirstName =
        firstName ?? 'User'; // Use "User" if firstName is null

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, $displayFirstName!', // Use dynamic name
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryNavy,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Ready to transform your laundry day? Get started now!',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.mediumGreyText,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// --- NEW/Refined Components ---

class OrderNowHeroCard extends StatefulWidget {
  const OrderNowHeroCard({super.key});

  @override
  State<OrderNowHeroCard> createState() => _OrderNowHeroCardState();
}

// Inside your OrderNowHeroCard's build method
class _OrderNowHeroCardState extends State<OrderNowHeroCard> {
  late Duration _timeLeft;
  late Timer _timer;
  late PickupWindow _currentWindow;
  bool _isWindowOverToday = false;

  @override
  void initState() {
    super.initState();
    _updatePickupInfo();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updatePickupInfo();
        });
      }
    });
  }

  void _updatePickupInfo() {
    _currentWindow = TimeUtils.getCurrentWindow();
    _timeLeft = TimeUtils.timeLeftInCurrentWindow();
    _isWindowOverToday = TimeUtils.isWindowOverForToday();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... (existing code for OrderNowHeroCard up to the last SizedBox(height: 20))

    return GestureDetector(
      onTap: () {
        AppRouter().push(context, ApplicationRoutesConstants.schedule);
        print('Order Now Tapped!');
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryNavy, AppColors.darkNavy],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryNavy.withOpacity(0.3),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Schedule Your Pickup',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Effortless laundry service at your doorstep.',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.accentGold,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentGold.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                'Order Now',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGoldText,
                  letterSpacing: 0.5,
                ),
              ),
            )
                .animate()
                .slideY(begin: 0.2, duration: 500.ms, curve: Curves.easeOut),
            const SizedBox(height: 20),
            // START OF MODIFIED LOGIC
            _isWindowOverToday
                ? Text(
                    'No more pickups available for today. You can place an order for tomorrow\'s 7 PM - 10 PM slot.',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fade(duration: 400.ms)
                : _currentWindow == PickupWindow.evening
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.clock,
                              size: 18, color: Colors.white.withOpacity(0.7)),
                          const SizedBox(width: 8),
                          Text(
                            'Current pickup window closes in ${TimeUtils.formatDuration(_timeLeft)}',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                        .animate()
                        .fade(duration: 400.ms)
                        .scale(curve: Curves.easeOutBack)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.clock,
                              size: 18, color: Colors.white.withOpacity(0.7)),
                          const SizedBox(width: 8),
                          Text(
                            'Next pickup window: 7 PM - 10 PM today',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                        .animate()
                        .fade(duration: 400.ms)
                        .scale(curve: Curves.easeOutBack),
            // END OF MODIFIED LOGIC
          ],
        ),
      ),
    );
  }
}

class AddressSectionCard extends StatelessWidget {
  const AddressSectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pickup Address',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreyText,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to address selection/edit screen
                  // Get.toNamed('/address_edit');
                  print('Edit Address Tapped!');
                },
                child: Row(
                  children: [
                    Text(
                      'Edit',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: AppColors.primaryNavy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(LucideIcons.chevronRight,
                        size: 20, color: AppColors.primaryNavy),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Apt 4B, 123 Main St, Accra, Ghana', // Replace with dynamic address
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.mediumGreyText,
            ),
          ),
        ],
      ),
    );
  }
}

class LaundryStatusCard extends StatelessWidget {
  final String status;

  const LaundryStatusCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    IconData statusIcon;
    Color iconColor;
    Color statusColor;

    switch (status) {
      case 'Processing at facility':
        statusIcon = LucideIcons.loader; // Or a custom spinning icon
        iconColor = AppColors.primaryNavy;
        statusColor = AppColors.primaryNavy;
        break;
      case 'Picked up, currently cleaning':
        statusIcon = LucideIcons.backpack;
        iconColor = AppColors.primaryNavy;
        statusColor = AppColors.primaryNavy;
        break;
      case 'Ready for delivery':
        statusIcon = LucideIcons.package;
        iconColor = AppColors.accentGold;
        statusColor = AppColors.darkGoldText;
        break;
      case 'Delivered':
        statusIcon = LucideIcons.checkCircle;
        iconColor = Colors.green;
        statusColor = Colors.green.shade700;
        break;
      default:
        statusIcon = LucideIcons.info;
        iconColor = AppColors.mediumGreyText;
        statusColor = AppColors.mediumGreyText;
    }

    return Container(
      padding: const EdgeInsets.all(20),
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
          Icon(statusIcon, size: 28, color: iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Laundry Status',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreyText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Optional: Add a button to view order details
          IconButton(
            icon: Icon(LucideIcons.arrowRight,
                color: AppColors.mediumGreyText, size: 24),
            onPressed: () {
              // Get.toNamed('/order_details');
              print('View Order Details Tapped!');
            },
          ),
        ],
      ),
    );
  }
}

class MyCreditsAndReferralCard extends StatelessWidget {
  const MyCreditsAndReferralCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Wallet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreyText,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(LucideIcons.wallet, size: 24, color: AppColors.primaryNavy),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Credits',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: AppColors.mediumGreyText,
                      ),
                    ),
                    Text(
                      'GHS 20.00',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(LucideIcons.plusCircle,
                    color: AppColors.primaryNavy, size: 24),
                onPressed: () {
                  // Navigate to add credits screen
                  print('Add Credits Tapped!');
                },
              )
            ],
          ),
          const Divider(
              height: 30, thickness: 0.8, color: AppColors.lightBlueGrey),
          GestureDetector(
            onTap: () {
              // Navigate to referral program details
              // Get.toNamed('/referral_program');
              print('Referral program tapped!');
            },
            child: Row(
              children: [
                Image.asset('assets/images/refer.png',
                    height: 30, width: 30), // Use a suitable icon
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Refer a Friend',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGreyText,
                        ),
                      ),
                      Text(
                        'Give GHS 20, Get GHS 20!',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.mediumGreyText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(LucideIcons.chevronRight,
                    size: 20, color: AppColors.mediumGreyText),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FirstTimeInfoCard extends StatelessWidget {
  const FirstTimeInfoCard({super.key});

  void _showWalkthroughPopup(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Walkthrough",
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your First WashAm',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x, size: 28),
                        color: AppColors.mediumGreyText,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ).animate().fade(duration: 500.ms),
                  const SizedBox(height: 20),
                  Text(
                    'Here’s what to expect from your seamless laundry experience:',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGreyText,
                      height: 1.5,
                    ),
                  ).animate().fade(duration: 500.ms, delay: 100.ms),
                  const SizedBox(height: 24),
                  _buildStep(
                      "📨", "You’ll get a text when your valet is on the way.",
                      delay: 200.ms),
                  _buildStep(
                      "🧺", "We’ll pick up your laundry in our WashAm bags.",
                      delay: 300.ms),
                  _buildStep("🧼",
                      "Clothes are expertly cleaned based on your preferences.",
                      delay: 400.ms),
                  _buildStep("✨", "Items are folded or pressed with care.",
                      delay: 500.ms),
                  _buildStep(
                      "🚚", "Fresh, clean laundry delivered to your door.",
                      delay: 600.ms),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 8,
                        shadowColor: AppColors.primaryNavy.withOpacity(0.4),
                      ),
                      child: Text(
                        'Got it!',
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  )
                      .animate()
                      .slideY(begin: 0.1, duration: 500.ms, delay: 700.ms),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildStep(String emoji, String text, {required Duration delay}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22))
              .animate()
              .fade(duration: 500.ms, delay: delay)
              .slideX(begin: -0.1, duration: 500.ms, delay: delay),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                height: 1.4,
                color: AppColors.darkGreyText,
              ),
            )
                .animate()
                .fade(duration: 500.ms, delay: delay + 100.ms)
                .slideX(begin: 0.1, duration: 500.ms, delay: delay + 100.ms),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showWalkthroughPopup(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
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
            Icon(LucideIcons.info, size: 28, color: AppColors.primaryNavy),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New to WashAm?',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreyText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap to see how it works and what to expect!',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.mediumGreyText,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight,
                size: 20, color: AppColors.mediumGreyText),
          ],
        ),
      ),
    );
  }
}
