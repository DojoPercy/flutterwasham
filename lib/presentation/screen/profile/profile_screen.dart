import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:WashAm/data/models/auth_models.dart'; // Your UserProfile model
import 'package:WashAm/presentation/common_blocs/auth/auth_bloc.dart';
import 'package:WashAm/presentation/common_blocs/auth/auth_state.dart';
import 'package:WashAm/presentation/common_blocs/auth/auth_events.dart'; // Import AuthEvent if sending events
import 'package:flutter/services.dart'; // For Clipboard functionality

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({Key? key}) : super(key: key);

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(LoadUserProfileFromStorage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.grey[50], // Very light background for overall page
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 4,
        iconTheme: const IconThemeData(color: Colors.black54),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (previous, current) =>
                current is AuthSuccessWithProfile ||
                current is AuthLoading ||
                current is AuthFailure,
            builder: (context, state) {
              if (state is AuthSuccessWithProfile) {
                return IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditProfilePage(userProfile: state.userProfile),
                      ),
                    ).then((updatedProfile) {
                      if (updatedProfile != null &&
                          updatedProfile is UserProfile) {
                        context
                            .read<AuthBloc>()
                            .add(UserProfileUpdated(updatedProfile));
                      }
                    });
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Settings icon might be part of a general app settings, not specifically profile settings
          // IconButton(
          //   icon: const Icon(Icons.settings_outlined),
          //   onPressed: () {
          //     // Navigate to app settings
          //   },
          // ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AuthSuccessWithProfile) {
            final UserProfile userProfile = state.userProfile;
            return SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- Profile Header Section ---
                  _buildProfileHeader(context, userProfile),
                  const SizedBox(height: 30),

                  // --- User ID (More subtle, but still accessible for support) ---
                  // It's often good practice to keep the user ID accessible for support purposes,
                  // but maybe not as a primary info card.

                  // --- Contact Information Section ---
                  _buildSectionTitle(context, 'Contact Information'),
                  _buildModernInfoTile(context, Icons.email_outlined, 'Email',
                      userProfile.email),
                  _buildModernInfoTile(
                      context,
                      Icons.phone_outlined,
                      'Phone Number',
                      userProfile.phoneNumber ?? 'Not provided'),

                  const SizedBox(height: 24),

                  // --- Personal Details Section ---
                  _buildSectionTitle(context, 'Personal Details'),
                  _buildModernInfoTile(context, Icons.person_outline, 'Gender',
                      userProfile.gender ?? 'Not specified'),
                  _buildModernInfoTile(
                      context,
                      Icons.calendar_today_outlined,
                      'Member Since',
                      DateFormat('MMMM d, Букмекерлар')
                          .format(userProfile.createdAt)),
                  // Removed 'Last Updated' as it's not typically user-facing

                  const SizedBox(height: 40),

                  // --- Action Buttons ---
                  _buildActionButton(
                    context,
                    'Change Password',
                    () {
                      print('Change Password button pressed');
                      // Navigate to change password page
                    },
                    isPrimary: true,
                  ),
                  const SizedBox(height: 16),
                  _buildActionButton(
                    context,
                    'Logout',
                    () {
                      _showLogoutConfirmationDialog(context);
                    },
                    isPrimary: false,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          } else if (state is AuthFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load profile: ${state}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(FetchUserProfile());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(
              child: Text('Please log in to view your profile.'));
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile userProfile) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: userProfile.firstName.isNotEmpty &&
                    userProfile.lastName.isNotEmpty
                ? Center(
                    child: Text(
                      '${userProfile.firstName[0]}${userProfile.lastName[0]}',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                : const Icon(Icons.person, size: 70, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '${userProfile.firstName} ${userProfile.lastName}',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          userProfile.role,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  // --- MODIFIED: User ID Display (Less prominent, but still present) ---
  // You might want to put this in a "Help & Support" or "About" section in a real app.

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0, left: 8.0),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildModernInfoTile(
      BuildContext context, IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 28),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, String text, VoidCallback onPressed,
      {required bool isPrimary}) {
    return SizedBox(
      width: double.infinity,
      child: isPrimary
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
                shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
              child: Text(
                text,
                style: const TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.red.shade400, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                    fontSize: 17,
                    color: Colors.red.shade400,
                    fontWeight: FontWeight.w600),
              ),
            ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Confirm Logout',
              style: TextStyle(fontWeight: FontWeight.w600)),
          content: const Text(
              'Are you sure you want to log out from your account?',
              style: TextStyle(color: Colors.grey)),
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Dispatch Logout event to AuthBloc
                // context.read<AuthBloc>().add(LogoutRequested());
                print('User logged out!');
                // Example: Navigate to login screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child:
                  const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

// Dummy EditProfilePage remains the same
class EditProfilePage extends StatefulWidget {
  final UserProfile userProfile;
  const EditProfilePage({Key? key, required this.userProfile})
      : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _genderController;

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.userProfile.firstName);
    _lastNameController =
        TextEditingController(text: widget.userProfile.lastName);
    _emailController = TextEditingController(text: widget.userProfile.email);
    _phoneNumberController =
        TextEditingController(text: widget.userProfile.phoneNumber ?? '');
    _genderController =
        TextEditingController(text: widget.userProfile.gender ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 4,
        iconTheme: const IconThemeData(color: Colors.black54),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            onPressed: () {
              final updatedProfile = UserProfile(
                id: widget.userProfile.id,
                email: _emailController.text,
                firstName: _firstNameController.text,
                lastName: _lastNameController.text,
                role: widget.userProfile.role,
                gender: _genderController.text.isNotEmpty
                    ? _genderController.text
                    : null,
                phoneNumber: _phoneNumberController.text.isNotEmpty
                    ? _phoneNumberController.text
                    : null,
                createdAt: widget.userProfile.createdAt,
                updatedAt: DateTime.now(),
              );
              Navigator.pop(context, updatedProfile);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    width: 2),
              ),
              child: ClipOval(
                child: Center(
                  child: Text(
                    '${widget.userProfile.firstName[0]}${widget.userProfile.lastName[0]}',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildModernTextField(context, 'First Name', _firstNameController,
                Icons.person_outline),
            _buildModernTextField(context, 'Last Name', _lastNameController,
                Icons.person_outline),
            _buildModernTextField(
                context, 'Email', _emailController, Icons.email_outlined,
                readOnly: true),
            _buildModernTextField(context, 'Phone Number',
                _phoneNumberController, Icons.phone_outlined,
                keyboardType: TextInputType.phone),
            _buildModernTextField(
                context, 'Gender', _genderController, Icons.person_outline),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField(BuildContext context, String label,
      TextEditingController controller, IconData icon,
      {TextInputType keyboardType = TextInputType.text,
      bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          prefixIcon:
              Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }
}
