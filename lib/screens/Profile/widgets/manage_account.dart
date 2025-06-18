import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_application_1/utils/app_localizations.dart';
import 'package:intl/intl.dart';

class ManageAccountScreen extends StatefulWidget {
  const ManageAccountScreen({super.key});

  @override
  State<ManageAccountScreen> createState() => _ManageAccountScreenState();
}

class _ManageAccountScreenState extends State<ManageAccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLogin = false;
  bool _isPhoneLogin = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _checkLoginMethod();
  }

  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final snapshot = await _database.child('users/${user.uid}').get();
        if (snapshot.exists) {
          final data = Map<String, dynamic>.from(snapshot.value as Map);
          setState(() {
            _fullNameController.text = data['fullName'] ?? '';
            _emailController.text = data['email'] ?? user.email ?? '';
            _birthDateController.text = data['birthDate'] ?? '';
            _phoneNumberController.text =
                data['phoneNumber'] ?? user.phoneNumber ?? '';
          });
        } else {
          // Jika data tidak ada di database, gunakan data dari Auth
          setState(() {
            _fullNameController.text = '';
            _emailController.text = user.email ?? '';
            _birthDateController.text = '';
            _phoneNumberController.text = user.phoneNumber ?? '';
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching user data: $e')),
        );
      }
    }
  }

  Future<void> _checkLoginMethod() async {
    final user = _auth.currentUser;
    if (user != null) {
      final providerData = user.providerData;
      setState(() {
        _isGoogleLogin =
            providerData.any((provider) => provider.providerId == 'google.com');
        _isPhoneLogin =
            providerData.any((provider) => provider.providerId == 'phone');
      });
    }
  }

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name cannot be empty';
    }
    if (value.length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  String? _validateBirthDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Birth date cannot be empty';
    }
    try {
      final date = DateFormat('dd/MM/yyyy').parseStrict(value);
      if (date.year < 1900 || date.isAfter(DateTime.now())) {
        return 'Invalid birth date';
      }
    } catch (e) {
      return 'Invalid date format (dd/MM/yyyy)';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number cannot be empty';
    }
    if (!RegExp(r'^\+?[1-9]\d{9,14}$').hasMatch(value)) {
      return 'Invalid phone number format';
    }
    return null;
  }


  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _database.child('users/${user.uid}').update({
          'fullName': _fullNameController.text.trim(),
          'birthDate': _birthDateController.text,
          'phoneNumber': _phoneNumberController.text.trim().isEmpty
              ? user.phoneNumber ?? ''
              : _phoneNumberController.text.trim(),
          'email': _emailController.text.trim().isEmpty
              ? user.email ?? ''
              : _emailController.text.trim(),
        });

        if (!_isGoogleLogin &&
            _emailController.text.trim() != user.email &&
            _emailController.text.trim().isNotEmpty) {
          await user.updateEmail(_emailController.text.trim());
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved successfully')),
        );
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Error saving changes';
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'Email is already in use';
            break;
          case 'requires-recent-login':
            errorMessage = 'Please log in again to update email or password';
            break;
          default:
            errorMessage = e.message ?? 'Error saving changes';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
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
          l10n.translate('Manage'),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  label: l10n.translate('full_name'),
                  controller: _fullNameController,
                  validator: _validateFullName,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: l10n.translate('phone_number'),
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  enabled: _isGoogleLogin,
                  validator: _isGoogleLogin ? _validatePhoneNumber : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: l10n.translate('email'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: _isPhoneLogin,
                  validator: _isPhoneLogin ? _validateEmail : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: l10n.translate('birth_date'),
                  controller: _birthDateController,
                  readOnly: true,
                  onTap: _selectDate,
                  validator: _validateBirthDate,
                ),
              
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            l10n.translate('save'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    TextInputType? keyboardType,
    bool readOnly = false,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      validator: validator,
      enabled: enabled,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      
      ),
    );
  }
}
