import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_application_1/main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false;
  String? _verificationId;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      _showSnackBar('Google Sign In gagal: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _skipLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red.shade400),
      );
    }
  }

  Future<void> _phoneLogin() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhoneInputScreen(
          onSuccess: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;
    final imageHeight =
        isSmallScreen ? screenHeight * 0.55 : screenHeight * 0.65;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            height: imageHeight,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/image 1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Gradient overlay
          Container(
            height: imageHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Back button
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: IconButton(
                  onPressed: _isLoading ? null : _skipLogin,
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: screenWidth * 0.05,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Main content
          Column(
            children: [
              SizedBox(height: imageHeight * 0.77),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(55),
                      topRight: Radius.circular(55),
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final contentHeight = constraints.maxHeight;
                      final isVerySmallScreen = contentHeight < 400;

                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: contentHeight),
                          child: IntrinsicHeight(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                screenWidth * 0.06,
                                isVerySmallScreen
                                    ? screenHeight * 0.05
                                    : screenHeight * 0.08,
                                screenWidth * 0.06,
                                screenHeight * 0.04,
                              ),
                              child: Column(
                                children: [
                                  // Logo
                                  Container(
                                    height: isSmallScreen ? 30 : 40,
                                    child: Image.asset(
                                      'assets/images/cropped-Logo-US-Header-1 1.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  SizedBox(
                                      height: isSmallScreen
                                          ? screenHeight * 0.04
                                          : screenHeight * 0.06),

                                  // Phone login button
                                  SizedBox(
                                    width: double.infinity,
                                    height: screenHeight * 0.065,
                                    child: ElevatedButton(
                                      onPressed:
                                          _isLoading ? null : _phoneLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFFFD700),
                                        foregroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(90),
                                        ),
                                        elevation: 0,
                                        disabledBackgroundColor:
                                            Colors.grey.shade300,
                                      ),
                                      child: _isLoading
                                          ? SizedBox(
                                              height: screenHeight * 0.025,
                                              width: screenHeight * 0.025,
                                              child:
                                                  const CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  Colors.black,
                                                ),
                                              ),
                                            )
                                          : Text(
                                              'Masuk dengan nomor telepon',
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.04,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ),
                                    ),
                                  ),

                                  SizedBox(height: screenHeight * 0.01),

                                  // "Atau" text
                                  Text(
                                    'Atau',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  SizedBox(height: screenHeight * 0.01),

                                  // Google sign in button
                                  SizedBox(
                                    width: double.infinity,
                                    height: screenHeight * 0.065,
                                    child: OutlinedButton(
                                      onPressed:
                                          _isLoading ? null : _signInWithGoogle,
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: Colors.grey.shade300,
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        backgroundColor: Colors.white,
                                        disabledBackgroundColor:
                                            Colors.grey.shade100,
                                      ),
                                      child: _isLoading
                                          ? SizedBox(
                                              height: screenHeight * 0.025,
                                              width: screenHeight * 0.025,
                                              child:
                                                  const CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  Colors.grey,
                                                ),
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  'assets/images/google-logo-icon-gsuite-hd-701751694791470gzbayltphh.png',
                                                  width: screenWidth * 0.06,
                                                  height: screenWidth * 0.06,
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.02),
                                                Text(
                                                  'Masuk dengan Google',
                                                  style: TextStyle(
                                                    fontSize:
                                                        screenWidth * 0.04,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),

                                  const Spacer(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PhoneInputScreen extends StatefulWidget {
  final VoidCallback onSuccess;

  const PhoneInputScreen({super.key, required this.onSuccess});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  bool _isLoading = false;
  String? _verificationId;

  @override
  void initState() {
    super.initState();
    _phoneController.text = '+62 ';
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red.shade400),
      );
    }
  }

  Future<void> _sendOTP() async {
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty || !phoneNumber.startsWith('+')) {
      _showSnackBar('Masukkan nomor telepon yang valid');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          final userCredential = await _auth.signInWithCredential(credential);
          if (userCredential.user != null) {
            await _database.child('users/${userCredential.user!.uid}').set({
              'phoneNumber': phoneNumber,
              'fullName': '',
              'email': '',
              'birthDate': '',
              'createdAt': DateTime.now().toIso8601String(),
            });
          }
          if (mounted) {
            widget.onSuccess();
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          _showSnackBar('Verifikasi gagal: ${e.message}');
          setState(() {
            _isLoading = false;
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isLoading = false;
            _verificationId = verificationId;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(
                verificationId: verificationId,
                phoneNumber: phoneNumber,
                onSuccess: widget.onSuccess,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: screenWidth * 0.05,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Hallo 👋',
          style: TextStyle(
            color: Colors.black,
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Silahkan masukkan nomor handphone Anda untuk memulai proses verifikasi. Kode OTP akan dikirim melalui SMS.',
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Text(
                'Nomor telepon',
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenHeight * 0.02,
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/indonesia_flag.png',
                            width: screenWidth * 0.06,
                            height: screenWidth * 0.04,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: screenWidth * 0.06,
                              height: screenWidth * 0.04,
                              color: Colors.red,
                              child: Center(
                                child: Text(
                                  'ID',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.02,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Text(
                            '+62',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: screenHeight * 0.025,
                      color: Colors.grey.shade300,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(fontSize: screenWidth * 0.04),
                        decoration: InputDecoration(
                          hintText: '818 1234 5678',
                          hintStyle: TextStyle(fontSize: screenWidth * 0.04),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenHeight * 0.02,
                          ),
                        ),
                        onChanged: (value) {
                          if (!value.startsWith('+62 ')) {
                            _phoneController.text = '+62 ';
                            _phoneController.selection =
                                TextSelection.fromPosition(
                              TextPosition(
                                  offset: _phoneController.text.length),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.grey,
                  ),
                  children: [
                    const TextSpan(text: 'Dengan mendaftar, saya menyetujui '),
                    TextSpan(
                      text: 'syarat dan ketentuan',
                      style: TextStyle(color: Colors.blue.shade600),
                    ),
                    const TextSpan(text: ' serta '),
                    TextSpan(
                      text: 'kebijakan',
                      style: TextStyle(color: Colors.blue.shade600),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: screenHeight * 0.065,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: screenHeight * 0.025,
                          width: screenHeight * 0.025,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black,
                            ),
                          ),
                        )
                      : Text(
                          'Kirimkan OTP',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}

class OTPVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final VoidCallback onSuccess;

  const OTPVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    required this.onSuccess,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _otpCode = '';
  bool _isLoading = false;

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red.shade400),
      );
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpCode.length != 6) {
      _showSnackBar('Masukkan OTP 6 digit');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otpCode,
      );
      await _auth.signInWithCredential(credential);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(onContinue: widget.onSuccess),
          ),
        );
      }
    } catch (e) {
      _showSnackBar('Verifikasi OTP gagal: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onKeypadTap(String value) {
    setState(() {
      if (value == 'backspace') {
        if (_otpCode.isNotEmpty) {
          _otpCode = _otpCode.substring(0, _otpCode.length - 1);
        }
      } else if (_otpCode.length < 6) {
        _otpCode += value;
      }
    });
  }

  Widget _buildOTPBox(int index, double screenWidth) {
    final boxSize = screenWidth * 0.12;
    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        border: Border.all(
          color: index < _otpCode.length
              ? const Color(0xFFFFD700)
              : Colors.grey.shade300,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
        color: index < _otpCode.length
            ? const Color(0xFFFFD700).withOpacity(0.1)
            : Colors.white,
      ),
      child: Center(
        child: Text(
          index < _otpCode.length ? _otpCode[index] : '',
          style: TextStyle(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String value, double screenWidth,
      {bool isBackspace = false}) {
    final buttonSize = screenWidth * 0.18;
    return GestureDetector(
      onTap: () => _onKeypadTap(value),
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(buttonSize / 2),
        ),
        child: Center(
          child: isBackspace
              ? Icon(
                  Icons.backspace_outlined,
                  size: screenWidth * 0.06,
                  color: Colors.black54,
                )
              : Text(
                  value,
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: screenWidth * 0.05,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Verifikasi kode OTP 📱',
          style: TextStyle(
            color: Colors.black,
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Kami telah mengirimkan kode OTP ke nomor telepon ${widget.phoneNumber}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Silakan masukkan kode OTP di bawah untuk melanjutkan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              SizedBox(height: screenHeight * 0.05),

              // OTP Input boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                    6, (index) => _buildOTPBox(index, screenWidth)),
              ),

              SizedBox(height: screenHeight * 0.03),

              GestureDetector(
                onTap: () {
                  // Implement resend OTP logic here
                },
                child: Text(
                  'Tidak menerima OTP?',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              GestureDetector(
                onTap: () {
                  // Implement resend OTP logic here
                },
                child: Text(
                  'Mengirim ulang kode melalui 4x 6',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.05),

              // Custom keypad
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildKeypadButton('1', screenWidth),
                        _buildKeypadButton('2', screenWidth),
                        _buildKeypadButton('3', screenWidth),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildKeypadButton('4', screenWidth),
                        _buildKeypadButton('5', screenWidth),
                        _buildKeypadButton('6', screenWidth),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildKeypadButton('7', screenWidth),
                        _buildKeypadButton('8', screenWidth),
                        _buildKeypadButton('9', screenWidth),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(width: screenWidth * 0.18),
                        _buildKeypadButton('0', screenWidth),
                        _buildKeypadButton('backspace', screenWidth,
                            isBackspace: true),
                      ],
                    ),
                  ],
                ),
              ),

              // Verify button
              if (_otpCode.length == 6)
                SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.065,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: screenHeight * 0.025,
                            width: screenHeight * 0.025,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black,
                              ),
                            ),
                          )
                        : Text(
                            'Verifikasi',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.w600,
                            ),
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

class SuccessScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const SuccessScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.06),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: screenWidth * 0.3,
                height: screenWidth * 0.3,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD700),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: screenWidth * 0.15,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Text(
                'Verifikasi Berhasil!',
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: screenHeight * 0.1),
              SizedBox(
                width: double.infinity,
                height: screenHeight * 0.065,
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Lanjutkan',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                    ),
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
