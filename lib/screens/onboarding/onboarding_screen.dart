import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/screens/onboarding/onboarding_data.dart';
import 'package:flutter_application_1/screens/onboarding/widgets/onboarding_page.dart';
import 'package:flutter_application_1/screens/auth/login_screen.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/utils/app_theme.dart';
import 'package:flutter_application_1/utils/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPage = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  bool _showAnimation = false;
  Offset _circleStartOffset = Offset.zero;

  final GlobalKey _buttonKey = GlobalKey();

  late Size _screenSize;

  bool _showLoadingAnimation = false;
  final int _totalDots = 5;
  final double _dotSize = 8.0;
  final double _dotSpacing = 30.0;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _animation = Tween<double>(begin: 60, end: 2000).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
          _isLastPage = _currentPage == onboardingPages.length - 1;
        });
      }
    });

    _animationController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasSeenOnboarding', true);

        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) {
            final user = FirebaseAuth.instance.currentUser;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) =>
                    user != null ? const MainScreen() : const LoginScreen(),
              ),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    setState(() {
      _circleStartOffset =
          Offset(_screenSize.width / 2, _screenSize.height / 2);
      _showAnimation = true;
      _showLoadingAnimation = true;
    });

    _animationController.forward();
  }

  void _onButtonPressed() {
    if (_isLastPage) {
      _startAnimation();
    } else {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: onboardingPages.length,
                  itemBuilder: (context, index) {
                    return OnboardingPage(
                      onboardingData: onboardingPages[index],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        onboardingPages.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? AppTheme.primaryColor
                                : AppTheme.primaryColor.withOpacity(0.2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        key: _buttonKey,
                        onPressed: _onButtonPressed,
                        style: AppTheme.primaryButtonStyle,
                        child: Text(
                          _isLastPage
                              ? l10n.translate('start_now')
                              : l10n.translate('next'),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_showAnimation)
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Positioned.fill(
                child: CustomPaint(
                  painter: CirclePainter(
                    center: _circleStartOffset,
                    radius: _animation.value,
                    color: const Color.fromARGB(255, 248, 248, 247),
                  ),
                ),
              );
            },
          ),
        if (_showLoadingAnimation)
          Positioned(
            left:
                (_screenSize.width - (_totalDots * (_dotSize + _dotSpacing))) /
                    2,
            top: _screenSize.height / 2 + 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _totalDots,
                (index) => LoadingDot(
                  size: _dotSize,
                  color: AppTheme.primaryColor,
                  index: index,
                  spacing: _dotSpacing,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class CirclePainter extends CustomPainter {
  final Offset center;
  final double radius;
  final Color color;

  CirclePainter({
    required this.center,
    required this.radius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class LoadingDot extends StatefulWidget {
  final double size;
  final Color color;
  final int index;
  final double spacing;

  const LoadingDot({
    required this.size,
    required this.color,
    required this.index,
    required this.spacing,
    super.key,
  });

  @override
  State<LoadingDot> createState() => _LoadingDotState();
}

class _LoadingDotState extends State<LoadingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _positionAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 2.5, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _positionAnimation = Tween<double>(begin: 0.0, end: -15.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.index * 250), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: widget.index < 4 ? widget.spacing : 0),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _positionAnimation.value),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(_opacityAnimation.value),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
