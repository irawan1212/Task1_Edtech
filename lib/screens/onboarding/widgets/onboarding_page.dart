import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/screens/onboarding/onboarding_data.dart';
import 'package:flutter_application_1/utils/app_theme.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingData onboardingData;

  const OnboardingPage({
    super.key,
    required this.onboardingData,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor:
            Colors.transparent, 
        statusBarIconBrightness:
            Brightness.light, 
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  Expanded(
                    flex: 6,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(45),
                        bottomRight: Radius.circular(45),
                      ),
                      child: Image.asset(
                        onboardingData.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),
                  const Expanded(flex: 4, child: SizedBox()),
                ],
              ),
            ),

            Positioned(
              top: screenHeight * 0.6 + 32,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    onboardingData.title,
                    textAlign: TextAlign.center,
                    style: AppTheme.headingStyle(size: 24),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    onboardingData.subtitle,
                    textAlign: TextAlign.center,
                    style: AppTheme.contentStyle(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
