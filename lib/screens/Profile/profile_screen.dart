import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_application_1/screens/Profile/widgets/language.dart';
import 'package:flutter_application_1/screens/Profile/widgets/manage_account.dart';
import 'package:flutter_application_1/screens/Profile/widgets/about.dart';
import 'package:flutter_application_1/screens/Profile/widgets/contact_us.dart';
import 'package:flutter_application_1/screens/Profile/widgets/privacy_policy.dart';
import 'package:flutter_application_1/screens/Profile/widgets/terms_conditions.dart';
import 'package:flutter_application_1/utils/app_localizations.dart';
import 'package:flutter_application_1/screens/Auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  String _fullName = 'Belum Login';
  String _initial = '';
  bool _isLoggedIn = false;
  StreamSubscription<DatabaseEvent>?
      _userDataSubscription; // Add this to manage subscription

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _listenToUserData();
  }

  @override
  void dispose() {
    // Cancel subscription when widget is disposed
    _userDataSubscription?.cancel();
    super.dispose();
  }

  void _checkLoginStatus() {
    final user = _auth.currentUser;
    setState(() {
      _isLoggedIn = user != null;
    });
  }

  void _listenToUserData() {
    // Cancel existing subscription if any
    _userDataSubscription?.cancel();

    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _isLoggedIn = true;
      });

      _userDataSubscription =
          _database.child('users/${user.uid}').onValue.listen((event) {
        if (mounted) {
          // Check if widget is still mounted
          if (event.snapshot.exists) {
            final data = Map<String, dynamic>.from(event.snapshot.value as Map);
            setState(() {
              String displayName = '';
              String loginMethod = data['loginMethod'] ?? '';

              if (loginMethod == 'google') {
                // For Google login, use email or display name
                displayName = data['email']?.isNotEmpty == true
                    ? data['fullName']
                    : (data['fullName']?.isNotEmpty == true
                        ? data['fullName']
                        : user.email ?? 'Google User');
              } else if (loginMethod == 'phone') {
                // For phone login, use phone number
                displayName = data['phoneNumber']?.isNotEmpty == true
                    ? data['phoneNumber']
                    : (user.phoneNumber ?? 'Phone User');
              } else {
                // Fallback logic for existing users without loginMethod
                if (data['email']?.isNotEmpty == true) {
                  displayName = data['fullName']?.isNotEmpty == true
                      ? data['fullName']
                      : data['email'];
                } else if (data['phoneNumber']?.isNotEmpty == true) {
                  displayName = data['fullName']?.isNotEmpty == true
                      ? data['fullName']
                      : data['phoneNumber'];
                } else {
                  displayName = 'User';
                }
              }

              _fullName = displayName;
              _initial =
                  _fullName.isNotEmpty ? _fullName[0].toUpperCase() : 'U';
            });
          } else {
            // Fallback when no database record exists
            setState(() {
              if (user.email?.isNotEmpty == true) {
                _fullName = user.email!;
              } else if (user.phoneNumber?.isNotEmpty == true) {
                _fullName = user.phoneNumber!;
              } else {
                _fullName = 'User';
              }
              _initial =
                  _fullName.isNotEmpty ? _fullName[0].toUpperCase() : 'U';
            });
          }
        }
      }, onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching user data: $error')),
          );
        }
      });
    } else {
      // Clear user data when not logged in
      _clearUserData();
    }
  }

  void _clearUserData() {
    setState(() {
      _isLoggedIn = false;
      _fullName = 'Belum Login';
      _initial = '';
    });
  }

  Future<void> _navigateToLogin() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );

    // Refresh the screen after returning from login
    if (result != null) {
      _checkLoginStatus();
      _listenToUserData();
    }
  }

  Future<void> _logout() async {
    try {
      // Cancel the user data subscription first
      _userDataSubscription?.cancel();

      // Sign out from Firebase
      await _auth.signOut();

      if (mounted) {
        // Clear user data immediately
        _clearUserData();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil logout')),
        );

        // Navigate to login screen and clear navigation stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text(
                'Apakah Anda yakin ingin menghapus akun? Tindakan ini tidak dapat dibatalkan.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Batal'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );

      if (confirmed == true) {
        try {
          // Cancel subscription first
          _userDataSubscription?.cancel();

          // Delete user data from database
          await _database.child('users/${user.uid}').remove();

          // Delete user account
          await user.delete();

          if (mounted) {
            // Clear user data
            _clearUserData();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account deleted successfully')),
            );

            // Navigate to login screen and clear navigation stack
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false,
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error deleting account: $e')),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.translate('profile'),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Avatar and Name Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _isLoggedIn ? Colors.black : Colors.grey[400],
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Center(
                      child: _isLoggedIn && _initial.isNotEmpty
                          ? Text(
                              _initial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 40,
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _fullName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: _isLoggedIn ? Colors.black : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),

            // Menu Items Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Show Manage Account only if logged in
                  if (_isLoggedIn)
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: l10n.translate('manage_account'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageAccountScreen(),
                          ),
                        ).then((_) {
                          // Refresh data after returning from ManageAccountScreen
                          _listenToUserData();
                        });
                      },
                    ),

                  _buildMenuItem(
                    icon: Icons.language_outlined,
                    title: l10n.translate('language'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LanguageScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.headset_mic_outlined,
                    title: l10n.translate('contact_unionspace'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ContactUsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: l10n.translate('about profile'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.privacy_tip_outlined,
                    title: l10n.translate('privacy_policy'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.description_outlined,
                    title: l10n.translate('terms_conditions'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsConditionsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Action Buttons Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  if (!_isLoggedIn) ...[
                    // Show Login button when not logged in
                    Container(
                      width: double.infinity,
                      height: 50,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ElevatedButton(
                        onPressed: _navigateToLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          l10n.translate('login') ?? 'Login',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Show Logout and Delete Account buttons when logged in
                    Container(
                      width: double.infinity,
                      height: 50,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 108, 107, 107),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          l10n.translate('logout'),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        leading: Icon(
          icon,
          color: Colors.grey[600],
          size: 24,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
          size: 24,
        ),
        onTap: onTap,
      ),
    );
  }
}
